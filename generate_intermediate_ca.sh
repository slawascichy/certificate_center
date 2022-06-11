#!/bin/bash
##################################
# Skrypt generujący certyfikat CA
# Główny certyfikat urzędu 
##################################

. ./setenv.sh

CURR_DATE=`date '+%Y%m%d%H%M%S'`
export CURR_DATE

OUTPUT_DIR=$CA_DIR
export OUTPUT_DIR

CA_CERT_FILE=scisoftware_root_ca.crt
CA_KEY_FILE=scisoftware_root_ca.pem
export CA_CERT_FILE CA_KEY_FILE

INTER_CA_KEY_FILE=scisoftware_intermediate_ca.pem
INTER_CA_CSR_FILE=scisoftware_intermediate_ca.csr
INTER_CA_CERT_FILE=scisoftware_intermediate_ca.crt
INTER_CA_PKCS12_FILE=scisoftware_intermediate_ca.p12

#CN=$1
#FRENDLY_NAME=$2
CN="Sci Software Intermediate CA"
FRENDLY_NAME="SciSoftwareIntermediateCA"
export CN FRENDLY_NAME

DAYS=3650 #10 lat
export DAYS

ROOT_CONF=$CONFIG_DIR/002_root_ca_openssl.cnf
CA_CONF=$CONFIG_DIR/003_intermediate_ca_openssl.cnf
export CA_CONF ROOT_CONF

if [ -f "$CA_DIR/$INTER_CA_CERT_FILE" ]
then
 #Robię kopie bezpieczenstwa starego certyfikatu...
 echo "Backup of old certs..."
 cp "$CA_DIR/$INTER_CA_KEY_FILE"  "$CA_DIR/$CURR_DATE.$INTER_CA_KEY_FILE"
 cp "$CA_DIR/$INTER_CA_CSR_FILE" "$CA_DIR/$CURR_DATE.$INTER_CA_CSR_FILE"
 cp "$CA_DIR/$INTER_CA_CERT_FILE" "$CA_DIR/$CURR_DATE.$INTER_CA_CERT_FILE"
fi

echo "Start key generation..."
openssl genrsa $KEY_SIZE > "$CA_DIR/$INTER_CA_KEY_FILE"

echo "Start request generation..."
openssl req -new -sha256\
 -config $CA_CONF\
 -key "$CA_DIR/$INTER_CA_KEY_FILE"\
 -out "$CA_DIR/$INTER_CA_CSR_FILE"
 
echo "Start certificate generation..."
openssl ca\
 -config $ROOT_CONF\
 -extensions v3_intermediate_ca\
 -days $DAYS\
 -in "$CA_DIR/$INTER_CA_CSR_FILE"\
 -out "$CA_DIR/$INTER_CA_CERT_FILE"
 
echo "Start to create PKCS12..."
openssl pkcs12 -export\
 -name "$FRENDLY_NAME"\
 -out "$CA_DIR/$INTER_CA_PKCS12_FILE"\
 -inkey "$CA_DIR/$INTER_CA_KEY_FILE"\
 -in "$CA_DIR/$INTER_CA_CERT_FILE"\
 -certfile $CA_DIR/$CA_CERT_FILE
 

# Zmieniam uprawnienia do plików z certyfikatami CA
chmod 600 $CA_DIR/$INTER_CA_KEY_FILE
chmod 600 $CA_DIR/$INTER_CA_CSR_FILE
chmod 600 $CA_DIR/$INTER_CA_CERT_FILE
echo "SUCCESS! Certs are available in folder $CA_DIR"
