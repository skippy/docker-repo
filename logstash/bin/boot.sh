#!/bin/bash

#
# TODOS:
#  - what if ssl certs already exist?  do we reuse them or assign new ones?
#  - if we assign new certs, we need to bounce all the logstash-forwarder instances
#  - what happens if logstash or elastic search is down?  Do log files get dropped 
#    or is their buffering from somewhere?  Logstash doesn't keep anything...
#  - hook things up through kafka?
#

# Fail hard and fast
set -eo pipefail

export ETCD_PORT=${ETCD_PORT:-4001}
export ETCD_IP=${ETCD_IP:-127.0.0.1}
export ETCD=$ETCD_IP:4001

echo "[logstash] booting container. ETCD: $ETCD"

# Loop until confd has updated the logstash config
until /usr/local/bin/confd -onetime -node $ETCD -config-file /etc/confd/conf.d/logstash.toml; do
  echo "[logstash] waiting for ElasticSearch to be available."
  sleep 5
done

# then going forward, make sure we update every time it changes
/usr/local/bin/confd -interval 10 -node $ETCD -config-file /etc/confd/conf.d/logstash.toml &

# Create a new SSL certificate
# openssl req -x509 -batch -nodes -newkey rsa:2048 -keyout /opt/logstash/ssl/logstash-forwarder.key -out /opt/logstash/ssl/logstash-forwarder.crt

# Publish SSL cert/key to etcd
# curl -L $ETCD/v2/keys/logstash/cert/ssl_certificate -XPUT --data-urlencode value@/opt/logstash/ssl/logstash-forwarder.crt
# curl -L $ETCD/v2/keys/logstash/cert/ssl_private_key -XPUT --data-urlencode value@/opt/logstash/ssl/logstash-forwarder.key

# Start logstash
echo "[logstash] starting logstash agent..."
/opt/logstash/bin/logstash agent -f /etc/logstash.conf