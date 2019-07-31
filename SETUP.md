# fessサーバーを構築する

`fess`サーバーの構築手順をドキュメント化しました。
こちらの手順と同様のスクリプトが、[setup.sh](setup.sh) となっています。

## サーバー仕様の想定

構築するサーバーの想定は、以下となっています。

- OS: CentOS6
- Elasticsearchが導入済み

## 導入するライブラリ等のバージョン

| name          | version          |
| ------------- | ---------------- |
| Java          | openjdk "11.0.2" |
| fess          | 13.2.0           |
| Elasticsearch | 7.2.0            |
| *wget         | -                |
| imagemagick   | -                |
| *procps       | -                |
| unoconv       | -                |
| initscripts   | -                |
| *ant          | 1.10.5           |

*付きのものは、導入手順中のみ必要なので、サーバー運用する際には削除して構いません。  
versionが `-` のものは `yum` からの導入です。

## 導入手順

設定、起動スクリプトをコピーするため、このリポジトリを配置し、そのフォルダ内で作業します。  
*必須の手順ではないです、設定・起動スクリプトのコピー、設置ができれば問題ありません。

```bash
git clone https://github.com/fox-hound-ltd/fess_research.git
cd fess_research
```

そうしたら、まず各ライブラリをインストールしていきます。

### yumから導入できるパッケージをインストールする

`yum` でインストールできるものを一括でインストールする。

```bash
yum update -y && \
yum install -y wget \
  imagemagick \
  procps \
  unoconv \
  # serviceコマンドがない場合にインストールが必要
  initscrtipts
```

### Javaのインストール

`yum` にあるjavaは古いので、`wget` で `sdk`を設置する。

```bash
export JAVA_HOME=/usr/lib/java-11.0.2
wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" https://download.java.net/java/GA/jdk11/9/GPL/openjdk-11.0.2_linux-x64_bin.tar.gz \
    -O /tmp/jdk.tar.gz && \
    tar -zxvf /tmp/jdk.tar.gz && \
    mv jdk-11.0.2 ${JAVA_HOME}
```

### グループ、ユーザーの定義

サーバーに、`fess`, `Elasticsearch` 用のグループユーザを追加する。

```bash
groupadd -g 1000 elasticsearch && \
    groupadd -g 1001 fess && \
    useradd -u 1000 elasticsearch -g elasticsearch && \
    useradd -u 1001 fess -g fess
```

### Elasticsearchのインストール (旧Elasticsearchのアンインストール)

旧Elasticsearchが `yum` または `rpm` で導入されていた場合は、それぞれのアンインストールコマンドでアンインストールを行ってください。

```bash
yum uninstall elasticsearch
rpm -e elasticsearch
```

Javaと同様、 `yum` で導入できるElasticsearchはバージョンが古いので、 `wget` で導入します。

```bash
wget --progress=dot:mega https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-oss-7.2.0-x86_64.rpm -O /tmp/elasticsearch-7.2.0.rpm && \
    rpm -i /tmp/elasticsearch-7.2.0.rpm && \
    rm -rf /tmp/elasticsearch-7.2.0.rpm && \
    # Elasticsearchが使うJavaを先述したJavaに設定する
    echo "JAVA_HOME=${JAVA_HOME}" >> /etc/default/elasticsearch
```

### fessのインストール

こちらも`fess`の公式リポジトリからパッケージをダウンロードし、インストールする。

```bash
wget --progress=dot:mega https://github.com/codelibs/fess/releases/download/fess-13.2.0/fess-13.2.0.rpm -O /tmp/fess-13.2.0.rpm && \
    rpm -i /tmp/fess-13.2.0.rpm && \
    rm -rf /tmp/fess-13.2.0.rpm
```

### antのインストール

こちらも `yum` の物はバージョンが古いので、 `wget` でダウンロード、インストールする。

```bash
wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://www.apache.org/dist/ant/binaries/apache-ant-1.10.5-bin.tar.gz \
    -O /tmp/ant.tar.gz && \
    tar -zxvf /tmp/ant.tar.gz && \
    mv apache-ant-1.10.5 /usr/share/ant
```

### fessプラグインをElasticsearchにインストール

`ant` を使って`fess`内の `plugin.xml` に記載されているプラグインをインストールする。それに合わせて、fessのオプション定数、起動スクリプトを更新。

```bash
/usr/share/ant/bin/ant -f /usr/share/fess/bin/plugin.xml -Dtarget.dir=/tmp -Dplugins.dir=/usr/share/elasticsearch/plugins install.plugins && \
    mkdir /opt/fess && \
    chown -R fess.fess /opt/fess && \
    sed -i -e 's#FESS_CLASSPATH="$FESS_CONF_PATH:$FESS_CLASSPATH"#FESS_CLASSPATH="$FESS_OVERRIDE_CONF_PATH:$FESS_CONF_PATH:$FESS_CLASSPATH"#g' /usr/share/fess/bin/fess && \
    echo "export FESS_OVERRIDE_CONF_PATH=/opt/fess" >>  /usr/share/fess/bin/fess.in.sh
```

### 設定ファイルにパス関連を出力する

Javaのパスを通す。

```bash
echo "export PATH=$PATH:/usr/bin" >> ~/.bash_profile && \
echo "export JAVA_HOME=/usr/lib/java-11.0.2" >> ~/.bash_profile
echo "ln -sf ${JAVA_HOME}/bin/java /usr/bin/java" >> ~/.bash_profile
```

### このリポジトリの設定、起動スクリプトのファイルをコピー、設置する

```bash
# Elasticsearchのconfigを設置
cp ./elasticsearch/config/* /etc/elasticsearch

# elasticsearch配下の権限付与
chown root:elasticsearch /etc/elasticsearch/* && chmod 660 /etc/elasticsearch/*

# 起動スクリプトを設置
cp ./run.sh /usr/share/fess/run.sh

### fess配下の権限付与
chown root:fess /usr/share/fess/* && chmod a+x /usr/share/fess/run.sh
```

お疲れさまでした、以上でライブラリ等の導入が完了です。

## サーバーの立ち上げ

起動スクリプトを実行することで、`fess` および `Elasticsearch` が起動されます。デフォルトの公開ポート設定は以下のようになっています。

| name                  | port |
| --------------------- | ---- |
| fess                  | 8080 |
| Elasticsearch         | 9200 |
| Elasticsearch(Export) | 9300 |

サーバーを立ち上げられたら、`nginx` なりで外部公開を行ってください。
`localhost:8080/login`にアクセスすると、管理者ログイン画面が表示されるので　`ID admin / PW admin` で管理者画面にアクセスすることができるので、適宜クローリング設定を行い、動作確認をお願いします。
