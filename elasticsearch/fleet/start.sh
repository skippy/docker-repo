#!/bin/bash
set -eo pipefail


fleetctl stop \
	elasticsearch_logging@{1..2}.service \
	elasticsearch_logging-kibana.service

fleetctl destroy \
	elasticsearch_logging@.service \
	elasticsearch_logging-discovery@.service \
	elasticsearch_logging-startup_lease@.service \
	elasticsearch_logging@{1..2}.service \
	elasticsearch_logging-discovery@{1..2}.service \
	elasticsearch_logging-startup_lease@{1..2}.service \
	elasticsearch_logging-kibana.service

fleetctl submit \
	share/elasticsearch/fleet/elasticsearch_logging@.service \
	share/elasticsearch/fleet/elasticsearch_logging-discovery@.service \
	share/elasticsearch/fleet/elasticsearch_logging-startup_lease@.service \
	share/elasticsearch/fleet/elasticsearch_logging-kibana.service

fleetctl load \
	elasticsearch_logging@{1..2}.service \
	elasticsearch_logging-discovery@{1..2}.service \
	elasticsearch_logging-startup_lease@{1..2}.service \
	elasticsearch_logging-kibana.service

fleetctl start elasticsearch_logging@{1..2}.service
