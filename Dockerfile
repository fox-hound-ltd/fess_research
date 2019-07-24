
FROM centos:centos6

ENV JAVA_HOME /usr/lib/java-11.0.2
ENV JAVA_DOWNLOAD_URL https://download.java.net/java/GA/jdk11/9/GPL/openjdk-11.0.2_linux-x64_bin.tar.gz

ENV ANT_HOME /usr/share/ant
ENV ANT_DOWNLOAD_URL http://www.apache.org/dist/ant/binaries/apache-ant-1.10.5-bin.tar.gz

ENV PATH $PATH:$JAVA_HOME/bin:$ANT_HOME/bin

ARG FESS_VERSION=13.2.0
ARG ELASTIC_VERSION=7.2.0

ENV ES_DOWNLOAD_URL https://artifacts.elastic.co/downloads/elasticsearch
ENV FESS_APP_TYPE docker

RUN yum -y update && \
    yum install -y imagemagick procps unoconv wget initscripts && \
    yum clean all

RUN wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" ${JAVA_DOWNLOAD_URL} \
        -O /tmp/jdk.tar.gz && \
    tar -zxvf /tmp/jdk.tar.gz && \
    mv jdk-11.0.2 ${JAVA_HOME}

RUN wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" ${ANT_DOWNLOAD_URL} \
        -O /tmp/ant.tar.gz && \
    tar -zxvf /tmp/ant.tar.gz && \
    mv apache-ant-1.10.5 ${ANT_HOME}

RUN groupadd -g 1000 elasticsearch && \
    groupadd -g 1001 fess && \
    useradd -u 1000 elasticsearch -g elasticsearch && \
    useradd -u 1001 fess -g fess

RUN set -x && \
    wget --progress=dot:mega ${ES_DOWNLOAD_URL}/elasticsearch-oss-${ELASTIC_VERSION}-x86_64.rpm \
        -O /tmp/elasticsearch-${ELASTIC_VERSION}.rpm && \
    rpm -i /tmp/elasticsearch-${ELASTIC_VERSION}.rpm && \
    rm -rf /tmp/elasticsearch-${ELASTIC_VERSION}.rpm && \
    echo "JAVA_HOME=${JAVA_HOME}" >> /etc/default/elasticsearch && \
    wget --progress=dot:mega https://github.com/codelibs/fess/releases/download/fess-${FESS_VERSION}/fess-${FESS_VERSION}.rpm -O /tmp/fess-${FESS_VERSION}.rpm && \
    rpm -i /tmp/fess-${FESS_VERSION}.rpm && \
    rm -rf /tmp/fess-${FESS_VERSION}.rpm && \
    ant -f /usr/share/fess/bin/plugin.xml -Dtarget.dir=/tmp \
        -Dplugins.dir=/usr/share/elasticsearch/plugins install.plugins && \
    rm -rf /tmp/elasticsearch-* && \
    mkdir /opt/fess && \
    chown -R fess.fess /opt/fess && \
    sed -i -e 's#FESS_CLASSPATH="$FESS_CONF_PATH:$FESS_CLASSPATH"#FESS_CLASSPATH="$FESS_OVERRIDE_CONF_PATH:$FESS_CONF_PATH:$FESS_CLASSPATH"#g' /usr/share/fess/bin/fess && \
    echo "export FESS_APP_TYPE=$FESS_APP_TYPE" >>  /usr/share/fess/bin/fess.in.sh && \
    echo "export FESS_OVERRIDE_CONF_PATH=/opt/fess" >>  /usr/share/fess/bin/fess.in.sh && \
    yum clean all

COPY elasticsearch/config /etc/elasticsearch
RUN chown root:elasticsearch /etc/elasticsearch/* && \
    chmod 660 /etc/elasticsearch/*

WORKDIR /usr/share/fess
EXPOSE 8080 9200 9300

USER root
COPY run.sh /usr/share/fess/run.sh
RUN echo "export PATH=${PATH}" >> ~/.bash_profile && \
    echo "export JAVA_HOME=${JAVA_HOME}" >> ~/.bash_profile && \
    ln -sf ${JAVA_HOME}/bin/java /usr/bin/java && \
    ln -sf ${ANT_HOME}/bin/ant /usr/bin/ant && \
    chown root:fess /usr/share/fess/* && chmod a+x /usr/share/fess/run.sh
ENTRYPOINT /usr/share/fess/run.sh