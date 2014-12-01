#!/bin/bash
# set -eo pipefail

echo "stopping metric monitoring"
fleetctl stop -block-attempts=3 \
	cadvisor.service \
	collectd.service \
	heapster-agent.service \
	grafana.service \
	heapster.service
# FIXME: sometimes it takes awhile for systemd to stop things... 
# if we go right to destroy this can leave services running...
echo "destroying metric monitoring"
fleetctl destroy \
	cadvisor.service \
	collectd.service \
	heapster-agent.service \
	grafana.service \
	heapster.service

# FIXME: fleetctl can have a consistancy problem; if we submit and load too soon
#        after a destroy call, it may load up an older version of the service...
echo "sleeping and then submitting metric jobs"
SCRIPT=`readlink -f "$0"`
SCRIPTPATH=`dirname "$SCRIPT"`
sleep 5
fleetctl load \
	$SCRIPTPATH/cadvisor.service \
	$SCRIPTPATH/../../collectd-influxdb/fleet/collectd.service \
	$SCRIPTPATH/heapster-agent.service \
	$SCRIPTPATH/grafana.service \
	$SCRIPTPATH/heapster.service

echo "starting metric monitoring"
fleetctl start \
	cadvisor.service \
	collectd.service \
	heapster-agent.service \
	grafana.service \
	heapster.service


