#!/bin/bash
##################################
# Skrypt ładujący ogólne paramtery generacji jako zmienne środowiskowe.
##################################

# Katalog z certyfikatem organizacji podpisującej
CA_DIR=./cacerts
CONFIG_DIR=./config
TARGET_DIR=./target
DATABASE_DIR=./database
export CA_DIR CONFIG_DIR TARGET_DIR DATABASE_DIR

# Czas ważności certyfikatu
DAYS=1095 #3 lata
export DAYS

# Rozmiar klucza
KEY_SIZE=2048
export KEY_SIZE

# Główny plik konfiguracyjny. Nazwanu z prefiksem 001 aby był na początku.
MAIN_CONF=$CONFIG_DIR/001_main_openssl.cnf
CA_CERT_FILE=scisoftware_ca_cert.pem
CA_KEY_FILE=scisoftware_ca_key.pem
export MAIN_CONF CA_CERT_FILE CA_KEY_FILE
