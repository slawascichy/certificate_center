#!/bin/bash

# Katalog do któego zostanie wrzucony magazyn PKCS12
export TARGET_DIR=/home/scichy/workspace/ldap
# Katalog pliku z magazynem PKCS12
export CERT_P12_FILE_NAME=infile.p12

#-------------------
# Parametry certyfikatów obsługiwanych prze Let's encrypt
export DOMAIN_NAME=auth-001.hgdb.org
export LETSENCRYPT_FULL="/etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem"
export LETSENCRYPT_KEY="/etc/letsencrypt/live/$DOMAIN_NAME/privkey.pem"
#-------------------

openssl pkcs12 -export -in $LETSENCRYPT_FULL -inkey $LETSENCRYPT_KEY -out $TARGET_DIR/$CERT_P12_FILE_NAME
