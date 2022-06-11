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
CONFIG_FILE_NAME="$OUTPUT_CN_DIR"
CONFIG_FILE_NAME+=_openssl.cnf

KEY_FILE=server-cert.key
CSR_FILE=server-cert.csr
CERT_FILE=server-cert.crt
PCKS12_FILE=server-cert.p12

if test -f "$CONFIG_DIR/$CONFIG_FILE_NAME"; then
   # Ktoś przygotował indywidualny plik konfiguracyjny 
   echo "Use custom config file $CONFIG_DIR/$CONFIG_FILE_NAME"
   OPENSSL_CONF=$CONFIG_DIR/$CONFIG_FILE_NAME
fi


echo "Start key generation..."
openssl genrsa -out $OUTPUT_DIR/$KEY_FILE 2048

echo "Start request generation..."
openssl req -new -sha256 -nodes\
 -config $OPENSSL_CONF\
 -key $OUTPUT_DIR/$KEY_FILE\
 -out $OUTPUT_DIR/$CSR_FILE

echo "Start certificate generation..."
openssl ca\
 -config $MAIN_CONF\
 -extensions srv_cert\
 -days $DAYS\
 -in $OUTPUT_DIR/$CSR_FILE\
 -out $OUTPUT_DIR/$CERT_FILE
 
echo "Start to create PKCS12..."
openssl pkcs12 -export\
 -name "$CN"\
 -out $OUTPUT_DIR/$PCKS12_FILE\
 -inkey $OUTPUT_DIR/$KEY_FILE\
 -in $OUTPUT_DIR/$CERT_FILE\
 -certfile $CA_DIR/$CA_CERT_FILE

$TAR_CMD --append --file=$TARGET_DIR/$OUTPUT_CN_DIR-certs.tar -C $OUTPUT_DIR $KEY_FILE
$TAR_CMD --append --file=$TARGET_DIR/$OUTPUT_CN_DIR-certs.tar -C $OUTPUT_DIR $PCKS12_FILE
$TAR_CMD --append --file=$TARGET_DIR/$OUTPUT_CN_DIR-certs.tar -C $OUTPUT_DIR $CERT_FILE 
$TAR_CMD --append --file=$TARGET_DIR/$OUTPUT_CN_DIR-certs.tar -C $CA_DIR $CA_ROOT_FILE
$TAR_CMD --append --file=$TARGET_DIR/$OUTPUT_CN_DIR-certs.tar -C $CA_DIR $CA_CERT_FILE

echo "SUCCESS! Certs are available in archive file $TARGET_DIR/$OUTPUT_CN_DIR-certs.tar"
