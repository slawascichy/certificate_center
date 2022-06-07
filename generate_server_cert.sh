#!/bin/bash
##################################
# Skrypt generujący certyfikat uwierzytalniający serwer
##################################

. ./setenv.sh

# Nazwę serwera przyjmujemy jako argument. 
CN=$1
export CN

OUTPUT_CN_DIR=`echo "$CN" | sed -e 's/ *//g'`
OUTPUT_DIR=$TARGET_DIR/$OUTPUT_CN_DIR
export OUTPUT_DIR
mkdir -p $OUTPUT_DIR

# Usuwanie starych certyfikatów
# rm -rf $OUTPUT_DIR/*.p*

OPENSSL_CONF=$MAIN_CONF

if test -f "$CONFIG_DIR/$OUTPUT_CN_DIR_openssl.cnf"; then
   # Ktoś przygotował indywidualny plik konfiguracyjny 
   echo "Use custom config file $CONFIG_DIR/$OUTPUT_CN_DIR_openssl.cnf"
   OPENSSL_CONF=$CONFIG_DIR/$OUTPUT_CN_DIR_openssl.cnf
fi


echo "Start key generation..."
openssl genrsa -out $OUTPUT_DIR/server-key.pem 2048

echo "Start request generation..."
openssl req\
 -config $OPENSSL_CONF\
 -new -key $OUTPUT_DIR/server-key.pem\
 -out $OUTPUT_DIR/server-req.pem

echo "Start certificate generation..."
openssl ca\
 -config $OPENSSL_CA_CONF\
 -in $OUTPUT_DIR/server-req.pem\
 -days $DAYS\
 -out $OUTPUT_DIR/server-cert.pem

echo "Start to create PKCS12..."
openssl pkcs12 -export\
 -out $OUTPUT_DIR/certyfikat.p12\
 -inkey $OUTPUT_DIR/server-key.pem\
 -in $OUTPUT_DIR/server-cert.pem\
 -certfile $CA_DIR/$CA_CERT_FILE

gtar -czvf $TARGET_DIR/$CN-certs.tar.gz $OUTPUT_DIR/*.p??
echo "SUCCESS! Certs are available in archive file $TARGET_DIR/$CN-certs.tar.gz"
