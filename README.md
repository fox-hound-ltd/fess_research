# fess_research

fessの調査用リポジトリ

## 環境

```bash
$ cat /etc/redhat-release
CentOS release 6.10 (Final)

$ java -version
openjdk version "11.0.2" 2019-01-15
OpenJDK Runtime Environment 18.9 (build 11.0.2+9)
OpenJDK 64-Bit Server VM 18.9 (build 11.0.2+9, mixed mode)
```

- fess 13.2.0
- Elasticsearch 7.2.0
- Docker 18.09.2

## 始める

```bash
git clone https://github.com/fox-hound-ltd/fess_research.git
```

### Dockerで構築

```bash
# dockerなければbrew等で導入してください
brew install docker
# fessサーバー立ち上げ
docker-compose up
```

fessサーバーが立ち上がるので、ホスト側からは`0.0.0.0:8080/login`でアクセスできる。

### CentOS上に構築

```bash
# fess、elasticsearchのインストール
./setup.sh
# fessサーバー立ち上げ
/usr/share/fess/run.sh
```

## 手動でセットアップする手順

[setup.sh](setup.sh)を参考にしてください。

## 関連・補足

`/login`の初期ユーザー名/パスワードは、 admin/admin です。

- [fess ドキュメント](https://fess.codelibs.org/ja/documentation.html)
