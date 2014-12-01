#!/bin/bash
# set -eo pipefail

echo " => stopping influxdb servers"
fleetctl stop -block-attempts=3 \
	influxdb@{1..2}.service 

echo " => destroying influxdb servers"
sleep 3
fleetctl destroy \
	influxdb@.service \
	influxdb-startup_lease@.service \
	influxdb-discovery@.service \
	influxdb@{1..2}.service \
	influxdb-startup_lease@{1..2}.service \
	influxdb-discovery@{1..2}.service

echo " => sleeping and then submitting influxdb servers"
SCRIPT=`readlink -f "$0"`
SCRIPTPATH=`dirname "$SCRIPT"`
sleep 5
fleetctl submit \
	$SCRIPTPATH/influxdb@.service \
	$SCRIPTPATH/influxdb-startup_lease@.service \
	$SCRIPTPATH/influxdb-discovery@.service

echo "loading influxdb servers"
fleetctl load \
	influxdb@{1..2}.service \
	influxdb-startup_lease@{1..2}.service \
	influxdb-discovery@{1..2}.service


echo " => starting influxdb servers"
fleetctl start \
	influxdb@{1..2}.service

