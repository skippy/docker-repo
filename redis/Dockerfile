FROM        skippy/base
MAINTAINER  Adam Greene <adam.greene@gmail.com>

# Basic requirements; need to grab the latest redis version
RUN         apt-get install -y python-software-properties
RUN         add-apt-repository ppa:rwky/redis
RUN         apt-get update
RUN         apt-get install -y redis-server

# redis configs
RUN         sysctl vm.overcommit_memory=1
ADD         redis.conf /etc/redis/conf.d/local.conf
VOLUME      /data/redis

# Supervisor config
ADD         supervisord.conf /etc/supervisor/conf.d/redis.conf

## lets cleanup so the image size is small(er)
RUN         apt-get clean
RUN         rm -rf /tmp/* /var/tmp/*

# Expose Redis default ports
EXPOSE      6379

CMD         /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
