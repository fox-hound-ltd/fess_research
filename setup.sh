#!/bin/bash

## centos6にfessをセットアップする

## 定数系
export JAVA_HOME=/usr/lib/java-11.0.2
JAVA_DOWNLOAD_URL=https://download.java.net/java/GA/jdk11/9/GPL/openjdk-11.0.2_linux-x64_bin.tar.gz

ANT_HOME=/usr/share/ant
ANT_DOWNLOAD_URL=http://www.apache.org/dist/ant/binaries/apache-ant-1.10.5-bin.tar.gz

PATH=$PATH:$JAVA_HOME/bin:$ANT_HOME/bin
FESS_VERSION=13.2.0
ELASTIC_VERSION=7.1.0

ES_DOWNLOAD_URL=https://artifacts.elastic.co/downloads/elasticsearch

## 必要なパッケージをインストール
### yumで導入できるもの
yum update -y && yum install -y imagemagick procps unoconv wget initscripts

### Javaをインストール
wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" ${JAVA_DOWNLOAD_URL} \
        -O /tmp/jdk.tar.gz && \
    tar -zxvf /tmp/jdk.tar.gz && \
    mv jdk-11.0.2 ${JAVA_HOME}

### antをインストール
wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" ${ANT_DOWNLOAD_URL} \
        -O /tmp/ant.tar.gz && \
    tar -zxvf /tmp/ant.tar.gz && \
    mv apache-ant-1.10.5 ${ANT_HOME}

## fess、elasticsearch用のグループとユーザを作成
groupadd -g 1000 elasticsearch && \
    groupadd -g 1001 fess && \
    useradd -u 1000 elasticsearch -g elasticsearch && \
    useradd -u 1001 fess -g fess

## コマンド実行状況を表示するフラグを立てる
# set -x

## elasticsearchをインストール
wget --progress=dot:mega ${ES_DOWNLOAD_URL}/elasticsearch-oss-${ELASTIC_VERSION}-x86_64.rpm -O /tmp/elasticsearch-${ELASTIC_VERSION}.rpm && \
    rpm -i /tmp/elasticsearch-${ELASTIC_VERSION}.rpm && \
    rm -rf /tmp/elasticsearch-${ELASTIC_VERSION}.rpm && \
    echo "JAVA_HOME=${JAVA_HOME}" >> /etc/default/elasticsearch

## fessをインストール
wget --progress=dot:mega https://github.com/codelibs/fess/releases/download/fess-${FESS_VERSION}/fess-${FESS_VERSION}.rpm -O /tmp/fess-${FESS_VERSION}.rpm && \
    rpm -i /tmp/fess-${FESS_VERSION}.rpm && \
    rm -rf /tmp/fess-${FESS_VERSION}.rpm

## fessプラグインをelasticsearchに追加、
${ANT_HOME}/bin/ant -f /usr/share/fess/bin/plugin.xml -Dtarget.dir=/tmp -Dplugins.dir=/usr/share/elasticsearch/plugins install.plugins && \
    mkdir /opt/fess && \
    chown -R fess.fess /opt/fess && \
    sed -i -e 's#FESS_CLASSPATH="$FESS_CONF_PATH:$FESS_CLASSPATH"#FESS_CLASSPATH="$FESS_OVERRIDE_CONF_PATH:$FESS_CONF_PATH:$FESS_CLASSPATH"#g' /usr/share/fess/bin/fess && \
    echo "export FESS_OVERRIDE_CONF_PATH=/opt/fess" >>  /usr/share/fess/bin/fess.in.sh

## 環境変数とシンボリックリンク作成を設定ファイルに出力
echo "export PATH=${PATH}" >> ~/.bash_profile && \
    echo "export JAVA_HOME=${JAVA_HOME}" >> ~/.bash_profile && \
    echo "ln -sf ${JAVA_HOME}/bin/java /usr/bin/java" >> ~/.bash_profile

## elasticsearchのconfigを設置
cp ./elasticsearch/config/* /etc/elasticsearch

## elasticsearch配下の権限付与
chown root:elasticsearch /etc/elasticsearch/* && chmod 660 /etc/elasticsearch/*

## 起動スクリプトを設置
cp ./run.sh /usr/share/fess/run.sh

## fess配下の権限付与
chown root:fess /usr/share/fess/* && chmod a+x /usr/share/fess/run.sh
