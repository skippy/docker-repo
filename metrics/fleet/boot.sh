#!/bin/bash
set -eo pipefail

SCRIPT=`readlink -f "$0"`
SCRIPTPATH=`dirname "$SCRIPT"`

echo "setting up influxdb"
$SCRIPTPATH/boot-influxdb.sh

echo "giving influxdb some time to startup"
sleep 10

echo "setting up cadvisor and heapster"
source $SCRIPTPATH/boot-heapster.sh

