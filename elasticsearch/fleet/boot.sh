#!/bin/bash
# set -eo pipefail

export ES_NUM_INSTANCES=${ES_NUM_INSTANCES:-2}
echo "stopping elasticsearch_logging"
fleetctl stop -block-attempts=3 \
	$(eval echo "elasticsearch_logging@{1..$ES_NUM_INSTANCES}.service")
# FIXME: sometimes it takes awhile for systemd to stop things... 
# if we go right to destroy this can leave services running...
echo "destroying elasticsearch_logging"
fleetctl destroy \
	$(eval echo "elasticsearch_logging@{1..$ES_NUM_INSTANCES}.service") \
	$(eval echo "elasticsearch_logging-discovery@{1..$ES_NUM_INSTANCES}.service") \
	$(eval echo "elasticsearch_logging-startup_lease@{1..$ES_NUM_INSTANCES}.service")\ 

# FIXME: fleetctl can have a consistancy problem; if we submit and load too soon
#        after a destroy call, it may load up an older version of the service...
echo "sleeping and then submitting elasticsearch_logging"
SCRIPT=`readlink -f "$0"`
SCRIPTPATH=`dirname "$SCRIPT"`
sleep 5
fleetctl load \
	$(eval echo "$SCRIPTPATH/elasticsearch_logging@{1..$ES_NUM_INSTANCES}.service") \
	$(eval echo "$SCRIPTPATH/elasticsearch_logging-discovery@{1..$ES_NUM_INSTANCES}.service") \
	$(eval echo "$SCRIPTPATH/elasticsearch_logging-startup_lease@{1..$ES_NUM_INSTANCES}.service")

echo "starting elasticsearch_logging"
fleetctl start \
	$(eval echo "elasticsearch_logging@{1..$ES_NUM_INSTANCES}.service")
	# elasticsearch_logging-kibana.service
