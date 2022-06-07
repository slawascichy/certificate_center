#!/bin/bash
##################################
# Skrypt tworzący katalog w któym będą generowane skrypty
##################################

. ./setenv.sh

# Nazwę serwera przyjmujemy jako argument. 
CN=$1
export CN

OUTPUT_CN_DIR=`echo "$CN" | sed -e 's/ *//g'`
OUTPUT_DIR=$TARGET_DIR/$OUTPUT_CN_DIR
export OUTPUT_DIR
mkdir -p $OUTPUT_DIR
echo "Folder $OUTPUT_DIR was created."

CONFIG_FILE_NAME="$OUTPUT_CN_DIR"
CONFIG_FILE_NAME+=_openssl.cnf

if test -f "$CONFIG_DIR/$CONFIG_FILE_NAME"; then
   # Ktoś już przygotował indywidualny plik konfiguracyjny 
   echo "Custom config file $CONFIG_DIR/$CONFIG_FILE_NAME exists."
else
   cp $MAIN_CONF $CONFIG_DIR/$CONFIG_FILE_NAME
   echo "Configuration file $CONFIG_DIR/$CONFIG_FILE_NAME was initialized."
fi

echo "Folder docelowy certyfikatów $CN." > "$OUTPUT_DIR/README.txt"

