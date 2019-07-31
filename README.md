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

fessサーバーに入る場合は以下

```bash
# CONTAINER IDを調べる
docker ps
# docker execで入る
docker exec -it {CONTAINER ID} bash
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

## 起動スクリプト run.sh について

このスクリプトは、大きく以下3つの処理に別れています。

1. fessの起動
2. ElasticSearchの起動
3. 両者の起動チェック

実行時に、変数を渡すことで制御が可能となっています。変数と制御の関係は以下の表の通りになっています。

| 変数                 | 制御内容等                                                                          |
| -------------------- | ----------------------------------------------------------------------------------- |
| FESS_DICTIONARY_PATH | fessが辞書データを参照するパスを設定する。初期値は`/var/lib/elasticsearch/config`   |
| ES_HTTP_URL          | 起動チェックの際に、ElasticSearchへPingを行うURL。初期値は`localhost:9200`          |
| ES_TRANSPORT_URL     | 起動チェックの際に、ElasticSearchTransportへPingを行うURL。初期値は`localhost:9300` |
| ES_JAVA_OPTS         | ElasticSearchに対するJVMオプション。[Setting JVM options - Elasticsearch Reference 7.2](https://www.elastic.co/guide/en/elasticsearch/reference/current/jvm-options.html) |  |
| PING_RETRIES         | 起動チェックの際のリトライ回数。初期値は `50`                                       |
| PING_INTERVAL        | 起動チェックの際に、連続してPingする時のインターバル。初期値は`3`                   |
| RUN_FESS             | fessを起動するか、`true` or `false`。初期値は`true`                                 |
| RUN_ELASTICSEARCH    | ElasticSearchを起動するか、 `true` or `false`。初期値は`true`                       |
| RUN_SHELL            | 起動チェックを行うかどうか、 `true` or `false`。初期値は`true`                      |

## 関連・補足

`/login`の初期ユーザー名/パスワードは、 admin/admin です。

- [fess ドキュメント](https://fess.codelibs.org/ja/documentation.html)
