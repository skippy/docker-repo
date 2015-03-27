# heavily based upon https://registry.hub.docker.com/u/centurylink/ruby-base/
FROM debian:wheezy

MAINTAINER Adam Greene <adam.greene@gmail.com>

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -q \
      build-essential \
      ca-certificates \
      git \
      ssh \
      libxml2-dev \
      curl \
      libffi-dev \
      libgdbm-dev \
      libncurses-dev \
      libreadline6-dev \
      libssl-dev \
      libyaml-dev \
      zlib1g-dev \
  && rm -rf /var/lib/apt/lists/*


ENV RUBY_MAJOR 2.2
ENV RUBY_VERSION 2.2.0

RUN echo 'gem: --no-document --no-rdoc --no-ri' >> /.gemrc

RUN mkdir -p /tmp/ruby \
  && curl -L "http://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR/ruby-$RUBY_VERSION.tar.bz2" \
      | tar -xjC /tmp/ruby --strip-components=1 \
  && cd /tmp/ruby \
  && ./configure --disable-install-doc \
  && make \
  && make install \
  && gem update --system \
  && rm -r /tmp/ruby

RUN gem install bundler

CMD [ "irb" ]
