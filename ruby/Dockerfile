# heavily based upon https://registry.hub.docker.com/u/centurylink/ruby-base/
FROM debian:jessie

MAINTAINER Adam Greene <adam.greene@gmail.com>

# libxml-dev2 is not included because nokogiri ships with a specific version itself
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -q \
      build-essential \
      ca-certificates \
      curl \
      libffi-dev \
      libgdbm-dev \
      libncurses-dev \
      libreadline6-dev \
      libssl-dev \
      libyaml-dev \
      zlib1g-dev \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean \
  && truncate -s 0 /var/log/*log


ENV RUBY_MAJOR 2.2
ENV RUBY_VERSION 2.2.1
ENV RUBY_SHA256 5a4de38068eca8919cb087d338c0c2e3d72c9382c804fb27ab746e6c7819ab28

RUN echo 'gem: --no-document --no-rdoc --no-ri' >> /.gemrc

RUN mkdir -p /tmp/ruby \
  && curl -s -o /tmp/ruby-$RUBY_VERSION.tar.gz http://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR/ruby-$RUBY_VERSION.tar.gz \
  && echo "${RUBY_SHA256}  /tmp/ruby-$RUBY_VERSION.tar.gz" > /tmp/ruby-$RUBY_VERSION.sha256 \
  && sha256sum /tmp/ruby-$RUBY_VERSION.sha256 \
  && tar --strip-components=1 -C /tmp/ruby -zxf /tmp/ruby-$RUBY_VERSION.tar.gz \
  && cd /tmp/ruby \
  && ./configure --disable-install-doc \
  && make \
  && make install \
  && gem update --system \
  && rm -r /tmp/*

RUN gem install bundler

CMD [ "irb" ]

