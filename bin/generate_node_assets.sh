#!/bin/bash

touch /elasticsearch/config/tls/nodes/certindex
echo $((100000 + RANDOM % 999999)) > /elasticsearch/config/tls/nodes/certserial

cat > /elasticsearch/config/tls/nodes/${NODE_NAME}.cnf <<EOS
[ca]
default_ca=intermediate_ca

[intermediate_ca]
new_certs_dir=/elasticsearch/config/tls/nodes
certificate=/elasticsearch/config/tls/ca_chain/tls.crt
private_key=/elasticsearch/config/tls/ca_chain/tls.key
database=/elasticsearch/config/tls/nodes/certindex
default_md=sha1
policy=intermediate_policy
serial=/elasticsearch/config/tls/nodes/certserial
default_days=365

[intermediate_policy]
commonName=supplied
stateOrProvinceName=optional
countryName=optional
emailAddress=optional
organizationName=optional
organizationalUnitName=optional

[req]
req_extensions=v3_req
distinguished_name=req_distinguished_name

[req_distinguished_name]
[ v3_req ]
keyUsage=critical,digitalSignature,keyEncipherment
basicConstraints=CA:FALSE
extendedKeyUsage=critical,serverAuth,clientAuth
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid
subjectAltName=@alt_names

[alt_names]
DNS.1=${NODE_NAME}
DNS.2=${NODE_IP}
DNS.3=${SERVICE_DNS}
RID=1.2.3.4.5.5

EOS

openssl genrsa \
    -out /elasticsearch/config/tls/nodes/${NODE_NAME}-rsa.pem \
    2048

openssl pkcs8 \
    -topk8 \
    -inform PEM \
    -outform PEM \
    -in /elasticsearch/config/tls/nodes/${NODE_NAME}-rsa.pem \
    -out /elasticsearch/config/tls/nodes/${NODE_NAME}-key.pem \
    -nocrypt

openssl req \
    -new \
    -key /elasticsearch/config/tls/nodes/${NODE_NAME}-key.pem \
    -out /elasticsearch/config/tls/nodes/${NODE_NAME}.csr \
    -subj /CN=${NODE_NAME} \

openssl ca \
    -batch \
    -notext \
    -extensions v3_req \
    -config /elasticsearch/config/tls/nodes/${NODE_NAME}.cnf \
    -in /elasticsearch/config/tls/nodes/${NODE_NAME}.csr \
    -out /elasticsearch/config/tls/nodes/${NODE_NAME}.pem

cat /elasticsearch/config/tls/ca_chain/tls.crt \
    >> /elasticsearch/config/tls/nodes/${NODE_NAME}.pem

