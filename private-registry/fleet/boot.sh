#!/bin/bash
# set -eo pipefail

echo "stopping the private docker registry"
fleetctl stop -block-attempts=3 \
	docker-registry-discovery.service \
	docker-registry-registration.service \
	docker-registry.service

# FIXME: sometimes it takes awhile for systemd to stop things... 
# if we go right to destroy this can leave services running...
echo "destroying the fleet record"
fleetctl destroy \
	docker-registry-discovery.service \
	docker-registry-registration.service \
	docker-registry.service

# FIXME: fleetctl can have a consistancy problem; if we submit and load too soon
#        after a destroy call, it may load up an older version of the service...
echo "sleeping and then submitting the fleet records"
SCRIPT=`readlink -f "$0"`
SCRIPTPATH=`dirname "$SCRIPT"`
sleep 5
fleetctl load \
	"$SCRIPTPATH/docker-registry-discovery.service" \
	"$SCRIPTPATH/docker-registry-registration.service" \
	"$SCRIPTPATH/docker-registry.service" \


echo "starting the private docker registry"
fleetctl start \
	docker-registry-discovery.service \
	docker-registry-registration.service \
	docker-registry.service
