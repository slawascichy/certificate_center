#!/bin/bash
############################
# Odświeżanie certyfikatu Let's Encrypt https://letsencrypt.org/
# w magazynach serwera aplikacji WebSphere
#
#root> certbot renew
############################

#------------------------------------
# UWAGA! Sprawdź również aktualność CA w konsoli WebSphere i jeżeli trzeba 
# zaktualizuj ręcznie!
#------------------------------------

# Katalog domowy produktu WebSphere
export WAS_HOME=/opt/IBM/BPM/v8.6
export WEBSPHERE_PROFILES=/opt/IBM/BPM/v8.6/profiles
export JAVA_HOME=$WAS_HOME/java

# Katalog z konfigyracją w DMGR
export CONFIG_ROOT=$WEBSPHERE_PROFILES/DmgrProfile/config

#------------------------------------
HOST_NAME=pw-bpm86-001.ibpm.pro
# Alias certyfikatu, pod taka nazwą certyfikaty są przechowywane 
# w magazynach WebSphere
CERT_ALIAS=pw-bpm86-001
# Dane uwierzytelniajace administratora w konsoli WebSphere
USER='bpmadmin'
PASS='***********'
#------------------------------------

# ulimit -n 8192

start()
{
# Uruchamianie kompnetów WebSphere
        $WEBSPHERE_PROFILES/Node1Profile/bin/startNode.sh
        $WEBSPHERE_PROFILES/Node1Profile/bin/startServer.sh SingleClusterMember1
}

stop()
{
# Zatrzymywanie kompnetów WebSphere
        $WEBSPHERE_PROFILES/Node1Profile/bin/stopServer.sh SingleClusterMember1 -username $USER -password $PASS
        $WEBSPHERE_PROFILES/Node1Profile/bin/stopNode.sh -username $USER -password $PASS
        $WEBSPHERE_PROFILES/DmgrProfile/bin/stopServer.sh dmgr -username $USER -password $PASS

}

# Odświeżenie certyfikatu Let's Encrypt
sudo certbot renew
# Generuję certyfikat na podstawie danych z Let's Encrypt
sudo openssl pkcs12 -export -out server.p12 -in /etc/letsencrypt/live/$HOST_NAME/fullchain.pem -name $CERT_ALIAS -inkey /etc/letsencrypt/live/$HOST_NAME/privkey.pem -password pass:WebAS
sudo chown bpmadmin:bpmadmins server.p12

# Zatrzymuję system (zobacz deklaracja funkcji)
stop

# Wrzucam dane o certyfikacie do megazynów WebSphere
# Dmgr
echo "Destination of cert $CONFIG_ROOT/cells/PCCell1/key.p12"
#$JAVA_HOME/bin/keytool -list -v -keystore $CONFIG_ROOT/cells/PCCell1/key.p12 -storepass WebAS -storetype PKCS12
#$JAVA_HOME/bin/keytool -list -v -keystore server.p12 -storepass WebAS -storetype PKCS12
$JAVA_HOME/jre/bin/ikeycmd -cert -delete -type p12 -db $CONFIG_ROOT/cells/PCCell1/key.p12 -pw WebAS -label $CERT_ALIAS 
$JAVA_HOME/jre/bin/ikeycmd -cert -import -file server.p12 -pw WebAS -type pkcs12 -target $CONFIG_ROOT/cells/PCCell1/key.p12 -target_pw WebAS -target_type pkcs12

# Węzły: Node1
echo "Destination of cert $CONFIG_ROOT/cells/PCCell1/nodes/Node1/key.p12"
$JAVA_HOME/jre/bin/ikeycmd -cert -delete -type p12 -db $CONFIG_ROOT/cells/PCCell1/nodes/Node1/key.p12 -pw WebAS -label $CERT_ALIAS 
$JAVA_HOME/jre/bin/ikeycmd -cert -import -file server.p12 -pw WebAS -type pkcs12 -target $CONFIG_ROOT/cells/PCCell1/nodes/Node1/key.p12 -target_pw WebAS -target_type pkcs12

# Uruchamiam Dmgr
$WEBSPHERE_PROFILES/DmgrProfile/bin/startServer.sh dmgr 
# Synchronizacja węzłów
cd $WEBSPHERE_PROFILES/Node1Profile/bin
./syncNode.sh $HOST_NAME 8879 -username $USER -password $PASS
# Uruchamiam węzła i członków klastra (zobacz deklaracja funkcji)
start

#END


