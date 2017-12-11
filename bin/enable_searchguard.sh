#!/bin/bash

echo $(date -u -Iseconds) "Enabling Search Guard..."

# generate node assets
mkdir -p /elasticsearch/config/tls/nodes
if [ ! -f "/elasticsearch/config/tls/nodes/${NODE_NAME}.pem" ]; then
    echo $(date -u -Iseconds) "Enabling Search Guard - Generating node assets..."
    generate_node_assets.sh
    chown -R elasticsearch:elasticsearch /elasticsearch/config/tls/nodes
else
    echo $(date -u -Iseconds) "Enabling Search Guard - Node assets previously generated"
fi

# add searchguard configs to elasticsearch.yml if not present
cat /elasticsearch/config/elasticsearch.yml | grep searchguard > /dev/null
if [ $? -eq 1 ]; then
    echo $(date -u -Iseconds) "Enabling Search Guard - Adding SG config..."
    add_sg_config.sh
else
    echo $(date -u -Iseconds) "Enabling Search Guard - SG config previously added"
fi

