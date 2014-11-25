FROM        skippy/base
MAINTAINER  Adam Greene <adam.greene@gmail.com>

# Basic requirements; need to grab the latest redis version
RUN         apt-get install -y python-software-properties
RUN         add-apt-repository ppa:rwky/redis
RUN         apt-get update
RUN         apt-get install -y redis-server

## lets cleanup so the image size is small(er)
RUN         apt-get clean
RUN         rm -rf /tmp/* /var/tmp/*

# redis configs
RUN         sysctl vm.overcommit_memory=1
ADD         redis.conf /etc/redis/conf.d/local.conf
VOLUME      /data/redis

# Supervisor config
ADD         supervisord.conf /etc/supervisor/conf.d/redis.conf

# Redis startup configuration options
ADD         configure_redis.sh /configure_redis.sh
RUN         cat /configure_redis.sh >> /configure_container.sh; rm /configure_redis.sh;

# Expose Redis default ports
EXPOSE      6379

CMD         /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
