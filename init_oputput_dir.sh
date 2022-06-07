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

cp $MAIN_CONF $CONFIG_DIR/$OUTPUT_CN_DIR_openssl.cnf
echo "Configuration file $CONFIG_DIR/$OUTPUT_CN_DIR_openssl.cnf was initialized."

