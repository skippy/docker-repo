#!/bin/bash
# set -eo pipefail

echo "stopping elasticsearch_logging"
fleetctl stop -block-attempts=3 \
	elasticsearch_logging@{1..2}.service \
	elasticsearch_logging-kibana.service
# FIXME: sometimes it takes awhile for systemd to stop things... 
# if we go right to destroy this can leave services running...
echo "destroying elasticsearch_logging"
fleetctl destroy \
	elasticsearch_logging@{1..2}.service \
	elasticsearch_logging-discovery@{1..2}.service \
	elasticsearch_logging-startup_lease@{1..2}.service \
	elasticsearch_logging-kibana.service

# FIXME: fleetctl can have a consistancy problem; if we submit and load too soon
#        after a destroy call, it may load up an older version of the service...
echo "sleeping and then submitting elasticsearch_logging"
SCRIPT=`readlink -f "$0"`
SCRIPTPATH=`dirname "$SCRIPT"`
sleep 5
fleetctl load \
	"$SCRIPTPATH/elasticsearch_logging@{1..2}.service" \
	"$SCRIPTPATH/elasticsearch_logging-discovery@{1..2}.service" \
	"$SCRIPTPATH/elasticsearch_logging-startup_lease@{1..2}.service" \
	"$SCRIPTPATH/elasticsearch_logging-kibana.service"

echo "starting elasticsearch_logging"
fleetctl start \
	elasticsearch_logging@{1..2}.service
	# elasticsearch_logging-kibana.service
