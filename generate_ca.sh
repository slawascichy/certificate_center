#!/bin/bash
##################################
# Skrypt generujący certyfikat CA
# Główny certyfikat urzędu 
##################################

./setenv.sh

CURR_DATE=`date '+%Y%m%d%H%M%S'`
export CURR_DATE

if [ -f  $CA_DIR/$CA_CERT_FILE ]
then
 #Robię kopie bezpieczenstwa starego certyfikatu...
 echo "Backup of old certs..."
 cp $CA_DIR/$CA_KEY_FILE  $CA_DIR/$CURR_DATE.$CA_KEY_FILE
 cp $CA_DIR/$CA_CERT_FILE $CA_DIR/$CURR_DATE.$CA_CERT_FILE
fi

#CN=$1
CN="Sci Software Private Certification Authority, domain PL"
export CN

DAYS=7300 #20 lata
export DAYS

openssl genrsa $KEY_SIZE > $CA_DIR/$CA_KEY_FILE
openssl req -new -x509 -nodes -key $CA_DIR/$CA_KEY_FILE -days $DAYS -config $MAIN_CONF > $CA_DIR/$CA_CERT_FILE

# Zmieniam uprawnienia do plików z certyfikatami CA
chmod 600 $CA_DIR/$CA_KEY_FILE
chmod 600 $CA_DIR/$CA_CERT_FILE
echo "SUCCESS! Certs are available in folder $CA_DIR"
