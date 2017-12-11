#!/bin/bash

cat >> /elasticsearch/config/elasticsearch.yml <<EOS

searchguard:
  ssl:
    transport:
      pemcert_filepath: /elasticsearch/config/tls/nodes/${NODE_NAME}.pem
      pemkey_filepath: /elasticsearch/config/tls/nodes/${NODE_NAME}-key.pem
      pemtrustedcas_filepath: /elasticsearch/config/tls/ca_chain/tls.crt
      enforce_hostname_verification: true
    http:
      enabled: true
      pemcert_filepath: /elasticsearch/config/tls/nodes/${NODE_NAME}.pem
      pemkey_filepath: /elasticsearch/config/tls/nodes/${NODE_NAME}-key.pem
      pemtrustedcas_filepath: /elasticsearch/config/tls/ca_chain/tls.crt
  authcz:
    admin_dn:
      - "CN=${CLUSTER_NAME}-admin"
  audit:
    type: internal_elasticsearch
  enable_snapshot_restore_privilege: true
  check_snapshot_restore_write_privileges: true
  restapi:
    roles_enabled:
      - "sg_all_access"

EOS

