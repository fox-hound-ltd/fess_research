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

## 始める

```command
docker-compose up
```

fessサーバーが立ち上がるので`0.0.0.0:8080/login`で管理者画面にログインする。
初期ユーザー名/パスワードは、 admin/admin です。

## 関連

- [fess ドキュメント](https://fess.codelibs.org/ja/documentation.html)
