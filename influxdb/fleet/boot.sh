#!/bin/bash
# set -eo pipefail

export INFLUX_NUM_INSTANCES=${INFLUX_NUM_INSTANCES:-2}
echo " => stopping influxdb servers"
fleetctl stop -block-attempts=3 \
	$(eval echo "influxdb@{1..$INFLUX_NUM_INSTANCES}.service") \

echo " => destroying influxdb servers"
sleep 3
fleetctl destroy \
	$(eval echo "influxdb@{1..$INFLUX_NUM_INSTANCES}.service") \
	$(eval echo "influxdb-startup_lease@{1..$INFLUX_NUM_INSTANCES}.service") \
	$(eval echo "influxdb-discovery@{1..$INFLUX_NUM_INSTANCES}.service")

echo " => sleeping and then submitting influxdb servers"
SCRIPT=`readlink -f "$0"`
SCRIPTPATH=`dirname "$SCRIPT"`
sleep 5
fleetctl load \
	$(eval echo "$SCRIPTPATH/influxdb@{1..$INFLUX_NUM_INSTANCES}.service") \
	$(eval echo "$SCRIPTPATH/influxdb-startup_lease@{1..$INFLUX_NUM_INSTANCES}.service") \
	$(eval echo "$SCRIPTPATH/influxdb-discovery@{1..$INFLUX_NUM_INSTANCES}.service")

echo " => starting influxdb servers"
fleetctl start \
	$(eval echo "influxdb@{1..$INFLUX_NUM_INSTANCES}.service") \
