#!/bin/bash
##################################
# Skrypt generujący certyfikat uwierzytalniający serwer
##################################

. ./setenv.sh

# Nazwę serwera przyjmujemy jako argument.
DOMAIN=$1 
CN="*.$DOMAIN"
export CN

CN_DIR=`echo "$DOMAIN" | sed -e 's/ *//g'`
OUTPUT_CN_DIR="002.$CN_DIR"
OUTPUT_DIR=$TARGET_DIR/$OUTPUT_CN_DIR
export OUTPUT_DIR
mkdir -p $OUTPUT_DIR

# Usuwanie starych certyfikatów
# rm -rf $OUTPUT_DIR/*.p*

OPENSSL_CONF=$MAIN_CONF
CONFIG_FILE_NAME="$OUTPUT_CN_DIR"
CONFIG_FILE_NAME+=_openssl.cnf

if test -f "$CONFIG_DIR/$CONFIG_FILE_NAME"; then
   # Ktoś przygotował indywidualny plik konfiguracyjny 
   echo "Use custom config file $CONFIG_DIR/$CONFIG_FILE_NAME"
   OPENSSL_CONF=$CONFIG_DIR/$CONFIG_FILE_NAME
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
 -config $MAIN_CONF\
 -in $OUTPUT_DIR/server-req.pem\
 -days $DAYS\
 -out $OUTPUT_DIR/server-cert.pem

echo "Start to create PKCS12..."
openssl pkcs12 -export\
 -out $OUTPUT_DIR/certyfikat.p12\
 -inkey $OUTPUT_DIR/server-key.pem\
 -in $OUTPUT_DIR/server-cert.pem\
 -name "$CN"\
 -certfile $CA_DIR/$CA_CERT_FILE

$TAR_CMD -czvf $TARGET_DIR/$OUTPUT_CN_DIR-certs.tar.gz $OUTPUT_DIR/*.p??
echo "SUCCESS! Certs are available in archive file $TARGET_DIR/$OUTPUT_CN_DIR-certs.tar.gz"
