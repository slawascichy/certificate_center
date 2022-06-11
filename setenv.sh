#!/bin/bash
##################################
# Skrypt ładujący ogólne paramtery generacji jako zmienne środowiskowe.
##################################

# ----------------------------------
# Archiwizator - nie wszędzie jest gtar
# Konfiguracja dla Linux:
#TAR_CMD=gtar
# Konfiguracja dla Cygwin:
TAR_CMD=tar
export TAR_CMD
# ----------------------------------

# Katalog z certyfikatem organizacji podpisującej
CA_DIR=./cacerts
CA_ROOT_FILE=scisoftware_root_ca.crt
CA_CERT_FILE=scisoftware_intermediate_ca.crt
CA_KEY_FILE=scisoftware_intermediate_ca.pem
CONFIG_DIR=./config
TARGET_DIR=./target
DATABASE_DIR=./database
export CA_ROOT_FILE CA_DIR CA_CERT_FILE CA_KEY_FILE CONFIG_DIR TARGET_DIR DATABASE_DIR

# Czas ważności certyfikatu
DAYS=1095 #3 lata
export DAYS

# Rozmiar klucza
KEY_SIZE=2048
export KEY_SIZE

# Główny plik konfiguracyjny. Nazwanu z prefiksem 001 aby był na początku.
MAIN_CONF=$CONFIG_DIR/003_intermediate_ca_openssl.cnf
export MAIN_CONF
