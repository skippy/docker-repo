#!/bin/bash
# set -eo pipefail

echo "stopping collectd"
fleetctl stop -block-attempts=3 \
	collectd.service
# FIXME: sometimes it takes awhile for systemd to stop things... 
# if we go right to destroy this can leave services running...
echo "destroying collectd"
fleetctl destroy \
	collectd.service

# FIXME: fleetctl can have a consistancy problem; if we submit and load too soon
#        after a destroy call, it may load up an older version of the service...
echo "sleeping and then submitting fluentd"
SCRIPT=`readlink -f "$0"`
SCRIPTPATH=`dirname "$SCRIPT"`
sleep 5
fleetctl start \
	$SCRIPTPATH/collectd.service
