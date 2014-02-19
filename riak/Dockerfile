FROM        skippy/base
MAINTAINER  Adam Greene <adam.greene@gmail.com>

# Basic requirements; need to grab the latest redis version
RUN         apt-get -y install curl lsb-release

# setup Riak repo
RUN         curl -s http://apt.basho.com/gpg/basho.apt.key | apt-key add --
RUN         echo "deb http://apt.basho.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/basho.list
RUN         apt-get update
RUN         apt-get -y upgrade
RUN         apt-get install -y riak

# Prepare Riak to run
RUN         sed -i 's/127.0.0.1/0.0.0.0/' /etc/riak/app.config
RUN         sed -i 's/%{ring_creation_size, 64}/{ring_creation_size, 128}/' /etc/riak/app.config
RUN         sed -i 's/{storage_backend, riak_kv_bitcask_backend}/{storage_backend, riak_kv_eleveldb_backend}/' /etc/riak/app.config
RUN         sed -i 's/\/var\/lib\/riak/\/data\/riak/' /etc/riak/app.config
RUN         echo "ulimit -n 4096" >> /etc/default/riak
VOLUME      /data/riak

# Supervisor config
ADD         supervisord.conf /etc/supervisor/conf.d/riak.conf

## lets cleanup so the image size is small(er)
RUN         apt-get clean
RUN         rm -rf /tmp/* /var/tmp/*

# Expose Riak Protocol Buffers and HTTP interfaces
EXPOSE 8087 8098

CMD         /usr/bin/supervisord -c /etc/supervisor/supervisord.conf


