#!/bin/bash
##################################
# Skrypt generujący/podpisujący certyfikat uwierzytalniający 
# serwer na podstawie dostarczonego żądania.
#
# Przed uruchomieniem w katalogu o nazwie $OUTPUT_DIR należy 
# umieścić plik z żądaniem. Plik nalezy nazwać custom-req.pem.
##################################

./setenv.sh

# Nazwę serwera przyjmujemy jako argument. 
CN=$1
export CN

OUTPUT_CN_DIR=`echo "$CN" | sed -e 's/ *//g'`
OUTPUT_DIR=$TARGET_DIR/$OUTPUT_CN_DIR
export OUTPUT_DIR

echo "Start certificate generation..."
openssl ca\
 -config $OPENSSL_CA_CONF\
 -in $OUTPUT_DIR/custom-req.pem\
 -days $DAYS\
 -out $OUTPUT_DIR/server-cert.pem

gtar -czvf $TARGET_DIR/$CN-certs.tar.gz $OUTPUT_DIR/*.p??
echo "SUCCESS! Certs are available in archive file $TARGET_DIR/$CN-certs.tar.gz"
