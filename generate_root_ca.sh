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

#CN=$1
CN="Sci Software Root CA"
export CN

CA_CONF=$CONFIG_DIR/002_root_ca_openssl.cnf
export CA_CONF

DAYS=7300 #20 lata
export DAYS

if [ -f "$CA_DIR/$CA_CERT_FILE" ]
then
 #Robię kopie bezpieczenstwa starego certyfikatu...
 echo "Backup of old certs..."
 cp "$CA_DIR/$CA_KEY_FILE"  "$CA_DIR/$CURR_DATE.$CA_KEY_FILE"
 cp "$CA_DIR/$CA_CERT_FILE" "$CA_DIR/$CURR_DATE.$CA_CERT_FILE"
fi

openssl genrsa $KEY_SIZE > "$CA_DIR/$CA_KEY_FILE"
openssl req -new -x509 -nodes -key "$CA_DIR/$CA_KEY_FILE" -days $DAYS -config $CA_CONF > "$CA_DIR/$CA_CERT_FILE"

# Zmieniam uprawnienia do plików z certyfikatami CA
chmod 600 $CA_DIR/$CA_KEY_FILE
chmod 600 $CA_DIR/$CA_CERT_FILE
echo "SUCCESS! Certs are available in folder $CA_DIR"
