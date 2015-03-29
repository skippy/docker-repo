# heavily influenced by https://registry.hub.docker.com/u/errordeveloper/oracle-jre/
#  just keeping it more up-to-date
FROM        progrium/busybox
MAINTAINER  Adam Greene <adam.greene@gmail.com>

RUN opkg-install curl ca-certificates

ENV JAVA_HOME /usr/jdk1.8.0_40

RUN curl \
  --silent \
  --location \
  --retry 3 \
  --cacert /etc/ssl/certs/GeoTrust_Global_CA.crt \
  --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
  "http://download.oracle.com/otn-pub/java/jdk/8u40-b26/server-jdk-8u40-linux-x64.tar.gz" \
    | gunzip \
    | tar x -C /usr/ \
    && ln -s $JAVA_HOME /usr/java \
    && rm -rf $JAVA_HOME/man

ENV PATH ${PATH}:${JAVA_HOME}/bin

ENTRYPOINT [ "java" ]
CMD [ "-version" ]
