#!/bin/sh

set -e

ELASTICSEARCH_URL=${ELASTICSEARCH_URL:-http://localhost:9200}
KIBANA_INDEX=${KIBANA_INDEX:-.kibana}

sed -i "s;^elasticsearch:.*;elasticsearch: ${ELASTICSEARCH_URL};" "/usr/kibana/config/kibana.yml"
sed -i "s;^kibanaIndex:.*;kibanaIndex: ${KIBANA_INDEX};" "/usr/kibana/config/kibana.yml"

exec /usr/kibana/bin/kibana