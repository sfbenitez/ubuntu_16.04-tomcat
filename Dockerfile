FROM ubuntu:16.04

ARG TOMCAT_VERSION=8.5.33
ARG MAVEN_VERSION=3.3.9
ARG OPENJDK_VERSION=8

ENV BUILD_TIMESTAMP 201804121321

ENV TOMCAT_VERSION ${TOMCAT_VERSION}
ENV MAVEN_VERSION ${MAVEN_VERSION}
ENV OPENJDK_VERSION ${OPENJDK_VERSION}

ENV CATALINA_HOME /opt/apache-tomcat
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/jre
ENV PATH ${PATH}:${JAVA_HOME}/bin:/opt/apache-maven-${MAVEN_VERSION}/bin:${CATALINA_HOME}/bin

ADD assets/etc/apt /assets/etc/apt

RUN /bin/bash -c 'ln -fns /assets/etc/apt/sources.list /etc/apt/sources.list' && /bin/bash -c 'ln -fns /assets/etc/apt/apt.conf.d/99recommends /etc/apt/apt.conf.d/99recommends'

RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y sudo git wget vim tar net-tools iputils-ping iproute2 sysstat iotop tcpdump tcpick bwm-ng tree strace screen rsync inotify-tools socat \
    curl openssh-server openssh-client supervisor emacs locales \
    build-essential \
    tzdata \
    openjdk-${OPENJDK_VERSION}-jdk && \
    apt-get clean

RUN locale-gen $LOCALE && update-locale LANG=$LOCALE

# sshd bug fixed
RUN mkdir -p /var/run/sshd

## Install Apache Tomcat
RUN wget -q http://apache.rediris.es/tomcat/tomcat-${TOMCAT_VERSION%%.*}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    tar -xzf apache-tomcat-${TOMCAT_VERSION}.tar.gz -C /opt/ && \
    rm -rf apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    mv /opt/apache-tomcat-${TOMCAT_VERSION} ${CATALINA_HOME}

# Install Maven
RUN wget -q http://ftp.cixug.es/apache/maven/maven-${MAVEN_VERSION%%.*}/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
    tar -xzf apache-maven-${MAVEN_VERSION}-bin.tar.gz -C /opt/ && \
    ln -s /opt/apache-maven-${MAVEN_VERSION}/bin/mvn /usr/local/bin && \
    rm -rf apache-maven-${MAVEN_VERSION}-bin.tar.gz

# Configurations for bash.
RUN echo "export TERM=xterm" > /etc/profile.d/set-TERM.sh && \
    echo "export PATH=${PATH}:${JAVA_HOME}/bin:/opt/apache-maven-${MAVEN_VERSION}:${CATALINA_HOME}"> /etc/profile.d/set-PATH.sh

ADD assets /assets

EXPOSE 8009 8080

VOLUME ["${CATALINA_HOME}/logs","/var/log/supervisor"]

ENTRYPOINT ["/assets/bin/entrypoint"]
