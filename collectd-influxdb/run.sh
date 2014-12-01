#!/bin/bash

set -me

export ETCD_PORT=${ETCD_PORT:-4001}
export ETCD_IP=${ETCD_IP:-127.0.0.1}
export ETCD=$ETCD_IP:4001

echo "[collectd] booting container. ETCD: $ETCD"
echo "[collectd] starting."
/usr/local/bin/confd -watch -quiet=false -debug -node $ETCD -config-file /etc/confd/conf.d/collectd.toml &

touch '/var/log/collectd.log'
tail -f /var/log/collectd.log
