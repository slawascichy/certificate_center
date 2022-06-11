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

CA_KEY_FILE=scisoftware_root_ca.pem
CA_CERT_FILE=scisoftware_root_ca.crt
CA_PKCS12_FILE=scisoftware_root_ca.p12

#CN=$1
CN="Sci Software Root CA"
FRENDLY_NAME="SciSoftwareRootCA"
export CN FRENDLY_NAME

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

# -- Pierwsza metoda --
#openssl genrsa $KEY_SIZE > "$CA_DIR/$CA_KEY_FILE"
#openssl req\
# -new -x509 -nodes\
# -config $CA_CONF\
# -key "$CA_DIR/$CA_KEY_FILE"\
# -days $DAYS\
# > "$CA_DIR/$CA_CERT_FILE"

# -- Druga metoda --
openssl req -new -sha256 -x509 -nodes\
 -config $CA_CONF\
 -newkey rsa:$KEY_SIZE\
 -keyout "$CA_DIR/$CA_KEY_FILE"\
 -out "$CA_DIR/$CA_CERT_FILE"
 
echo "Start to create PKCS12..."
openssl pkcs12 -export\
 -name "$FRENDLY_NAME"\
 -out "$CA_DIR/$CA_PKCS12_FILE"\
 -inkey "$CA_DIR/$CA_KEY_FILE"\
 -in "$CA_DIR/$CA_CERT_FILE"
 
# Zmieniam uprawnienia do plików z certyfikatami CA
chmod 600 $CA_DIR/$CA_KEY_FILE
chmod 600 $CA_DIR/$CA_CERT_FILE
echo "SUCCESS! Certs are available in folder $CA_DIR"
