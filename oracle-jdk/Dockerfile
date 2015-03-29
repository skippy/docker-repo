# heavily influenced by https://registry.hub.docker.com/u/errordeveloper/oracle-jre/
#  just keeping it more up-to-date
FROM        progrium/busybox
MAINTAINER  Adam Greene <adam.greene@gmail.com>

RUN opkg-install curl ca-certificates

ENV JAVA_HOME /usr/jdk1.8.0_40
ENV JAVA_SHA256 d97f0f402bd65a9c26aa266246b0894c8d6762e82373377641ca779c46406299

RUN curl \
  --silent \
  --location \
  --retry 3 \
  --cacert /etc/ssl/certs/GeoTrust_Global_CA.crt \
  --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
  --output /tmp/jdk-8u40-linux-x64.tar.gz \
  "http://download.oracle.com/otn-pub/java/jdk/8u40-b26/jdk-8u40-linux-x64.tar.gz"
    && echo "${JAVA_SHA256}  /tmp/jdk-8u40-linux-x64.tar.gz" > /tmp/jdk-8u40-linux-x64.sha256 \
    && sha256sum -c /tmp/jdk-8u40-linux-x64.sha256 \
    && gunzip -c /tmp/jdk-8u40-linux-x64.tar.gz \
      | tar x -C /usr/ \
    | gunzip \
    | tar x -C /usr/ \
    && ln -s $JAVA_HOME /usr/java \
    && rm -rf $JAVA_HOME/man

ENV PATH ${PATH}:${JAVA_HOME}/bin

ENTRYPOINT [ "java" ]
CMD [ "-version" ]
