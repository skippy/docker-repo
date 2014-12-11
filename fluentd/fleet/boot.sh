#!/bin/bash
# set -eo pipefail

echo "stopping fluentd"
fleetctl stop -block-attempts=3 \
	fluentd-forwarder.service
# FIXME: sometimes it takes awhile for systemd to stop things... 
# if we go right to destroy this can leave services running...
echo "destroying fluentd"
fleetctl destroy \
	fluentd-forwarder.service \
	journald-fluentd.service \
	journald-fluentd-pos.service

# FIXME: fleetctl can have a consistancy problem; if we submit and load too soon
#        after a destroy call, it may load up an older version of the service...
echo "sleeping and then submitting fluentd"
SCRIPT=`readlink -f "$0"`
SCRIPTPATH=`dirname "$SCRIPT"`
sleep 5
fleetctl load \
	$SCRIPTPATH/fluentd-forwarder.service \
	$SCRIPTPATH/journald-fluentd.service \
	$SCRIPTPATH/journald-fluentd-pos.service



echo "starting fluentd"
fleetctl start \
	$SCRIPTPATH/fluentd-forwarder.service \
	$SCRIPTPATH/journald-fluentd.service \
	$SCRIPTPATH/journald-fluentd-pos.service
