# heavily influenced by https://registry.hub.docker.com/u/errordeveloper/oracle-jre/
#  just keeping it more up-to-date
FROM        jeanblanchard/busybox-java:8
MAINTAINER  Adam Greene <adam.greene@gmail.com>

ENV JRUBY_VERSION 9.0.0.0.pre1
ENV JRUBY_SHA256 381da389b07c4692db5feeeeb6a21963cbdc86ee5172bd3f170bd081cc607354

RUN opkg-install bash ca-certificates \
  && rm -rf /tmp/*

RUN curl -sSL -o /tmp/jruby-bin-${JRUBY_VERSION}.tar.gz \
       https://s3.amazonaws.com/jruby.org/downloads/${JRUBY_VERSION}/jruby-bin-${JRUBY_VERSION}.tar.gz \
  && echo "${JRUBY_SHA256}  /tmp/jruby-bin-${JRUBY_VERSION}.tar.gz" > /tmp/jruby-bin-${JRUBY_VERSION}.sha256 \
  && sha256sum -c /tmp/jruby-bin-${JRUBY_VERSION}.sha256 \
  && gunzip -c /tmp/jruby-bin-${JRUBY_VERSION}.tar.gz \
     | tar -xC /opt \
  && ln -s /opt/jruby-${JRUBY_VERSION} /opt/jruby \
  && rm -rf /tmp/* \
  && update-alternatives --install /usr/local/bin/ruby ruby /opt/jruby/bin/jruby 1

ENV PATH /opt/jruby/bin:$PATH
RUN echo 'gem: --no-rdoc --no-ri' >> /.gemrc

ENV GEM_HOME /usr/local/bundle
ENV PATH $GEM_HOME/bin:$PATH
RUN gem install bundler \
  && bundle config --global path "$GEM_HOME" \
  && bundle config --global bin "$GEM_HOME/bin"

# don't create ".bundle" in all our apps
ENV BUNDLE_APP_CONFIG $GEM_HOME

CMD [ "irb" ]
