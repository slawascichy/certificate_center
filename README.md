# Centrum Certyfikacyjne

Centrum zarządzania certyfikatami SSL oparte o openssl oraz skrtypy bash.
Zbiór skryptów wpsiera pracę i rejestrację certyfikatów podpisanych samodzielnie. Narzędzie przydatne gdy chcemy skutecznie, bezkosztowo, zarządzac certyfikatami SSL naszej wewnetrznej infrastruktury. Projekt [Let's Encrypt](https://letsencrypt.org/) pozwala na obsługę certyfikacji naszych serwerów jednakże jego zastosowanie ma takie ograniczenie, że nasze usługi muszą być wystawione na świat - proces walidacji serwera nie pozwala na korzystanie z certyfikatów na serwerach, które nie mają wyjścia na świat.

## Opis skryptów i plików

<details><summary>Opis zawartych w projekcie skryptów będących podstawą oprogramowania twojego Centrum Certyfikacyjnego.</summary>
  <p>
    
  ### ./setenv.sh
Skrypt pozwalający na ogólną konfigurację twojego Centrum Certyfikacyjnego.

  ### ./generate_ca.sh
Skrypt generacji klucza oraz certyfikatu CA - certyfikatu, którym będą podpisywane wszystkie wystawiane przez ciebie certyfikaty. Ustaw swoją konfigurację w pliku [./config/001_main_openssl.cnf](/slawascichy/certificate_center/blob/main/config/001_main_openssl.cnf) tak aby spełniały one twoje wymagania aby certyfikat CA reprezentował twoją organizację. Przykład:
```
[ req_distinguished_name ]
emailAddress             = info@scisoftware.pl
countryName              = PL
stateOrProvinceName      = Pomorskie
localityName             = Bojano
0.organizationName       = Sci Software
0.organizationalUnitName = IT o/Bojano
commonName               = ${ENV::CN}
0.DC                     = scisoftware
1.DC                     = pl
```
  ### ./init_oputput_dir.sh
Skrypt pozwalający nam na zainicjalizowanie katalogu, w którym składowane będą certyfikaty danej usługi/serwera.
    
  ### ./generate_server_cert.sh
Skrypt do generacji certyfikatu serwera. Skrypt generuje certyfikat request'u, klucz prywatny oraz sam certyfikat w katalogu o nazwie `./target/<nazwa_hosta_uslugi>`.

  ### ./generate_server_cert_star.sh
Skrypt do generacji certyfikatu z tzw. "gwiazdką" dla danej domeny serwerów. Skrypt generuje certyfikat request'u, klucz prywatny oraz sam certyfikat w katalogu o nazwie `./target/<nazwa_domeny>`.

  ### ./generate_server_cert_by_req.sh
Skryp pozwalający na generację certyfikatu na podstawie dostarczonego pliku request'u.

  ### ./config/001_main_openssl.cnf
Plik konfiguracji openSSL. Są tam zawarte główne dane o nas, jako zaufanym urzędzie certyfikacji (CA)

  ### ./database/serial
Plik przechowujący kolejny numer wygenerowanego certyfikatu (sekwencja).

  ### ./database/index.txt
Lista wygenerowanych przez ciebie certyfikatów. Ewidencja wydanych poświadczeń.

  ### ./database/index.txt.attr
Parametry uzupełniania listy wygenerowanych certyfikatów.

  </p>
</details>

## Instalacja
    
Aby móc generować klucze wymagane jest oprogramowanie [openSSL](https://wiki.ibpm.pro/index.php/OpenSSL).
Oprogramowanie sprawdzone na systemie operacyjnym CentOS oraz Windows przy użyciu nakładki Cygwin.

Poszczególne kroki instalayjne:
- Umieść pliki projektu w utworzonym przez ciebie katalogu np. `/opt/security`.
- Zmień przykładową konfigurację pliku [./config/001_main_openssl.cnf](/slawascichy/certificate_center/blob/main/config/001_main_openssl.cnf) tak aby spełniały one twoje wymagania.
- Zmien parametry środowiska w skrypcie `setenv.sh`.
- Zmień wartość parametru CN w skrypcie `generate_ca.sh`.
- Wygeneruj swój pierwszy certyfikat CA za pomocą skryptu `generate_ca.sh` - wygenerowany certyfikat będzie służył do podpisywania certyfikatów serwerowych. Odtąd wystaczy, że twoi współpracownicy będą mieli zainstalowany na komputerze ten certyfikat CA w magazynie "Zaufanych głównych urzędów certyfikacji" , a ich przeglądarki będą tolerować/ufać serwerom, które będą obsługiwane przez twoje Centrum Certyfikacyjne.

Koniec instalacji.

## Generowanie certyfikatu dla usługi

Wymagania co do jakości certyfikatów się zwiększają i przez to wymagana jest indywidualna konfiguracja open SSL dla każdego wystawianego certyfikatu i stąd konieczność dodatkowej pracy manualnej. Poszczególne kroki generacji certyfikatu:
1. Przechodzimy do katalogu, w którym zainstalowaliśmy skrypty generacji certyfikatów.
2. Tworzymy (o ile już nie istnieje katalog) docelowy, w którym generowane będą poszczególne składowe certyfikatu.
```bash
# Przygotuj nazwę katalogu w zmiennej środowiskowej. Zmienna $CN reprezentuje pełną nazwę 
# serwera dla którego ma być wygenerowany certyfikat np. *wiki.example.com*
set CN=wiki.example.com
./init_oputput_dir.sh $CN
```
3. Podczas inicjalizacji w katalogu `./target` zostanie utworzony odpowiedni katalog o nazwie `$CN`, a w katalogu `./config` powinien pojawić się plik z konfiguracją o nazwie `$CN_openssl.cnf` gdzie `$CN` reprezentuje pełną nazwę serwera dla którego ma być wygenerowany certyfikat np. *wiki.example.com_openssl.cnf*. Ta dedykowana powinna być teraz dostosowana do potrzeb serwera. Zmieniamy sekcję `[alt_names]` tak aby ustawić wymagane dla certyfikatu alternatywne nazwy, np.:
```text
[alt_names]
DNS.1 = wiki.example.com
DNS.2 = www.wiki.example.com
DNS.3 = ipv4.wiki.example.com
DNS.4 = ipv6.wiki.example.com 
```
4. Generujemy certyfikat za pomocą polecenia:
```bash
./generate_server_cert.sh $CN    
```
Generacja certyfikatu jest interaktywna, tzn. że trzeba będzie odpowiedzieć na pytania:
```
Certificate is to be certified until Jun  6 13:52:54 2025 GMT (1095 days)
Sign the certificate? [y/n]:
```
Należy odpowiedzieć "y"
```
1 out of 1 certificate requests certified, commit? [y/n]
```
Należy odpowiedzieć "y"
```
Enter Export Password:
```
Należy wprowadzić hasło generowanego archiwum PKCS12. Zapamiętaj je by później przekazać odpowiedniej osobie instalującej certyfikaty na serwerze docelowym.

W efekcie końcowym utworzone zostanie archiwum, które należy przekazać osobie instalującej certyfikaty na serwerze docelowym.
```
wiki.example.com/4A.pem
wiki.example.com/certyfikat.p12
wiki.example.com/server-cert.pem
wiki.example.com/server-key.pem
wiki.example.com/server-req.pem
SUCCESS! Certs are available in archive file wiki.ibpm.pro-certs.tar.gz
```

Informacje o wygenerowanym certyfikacie zarejestrowane zostaną w bazie certyfikatów, w pliku `./database/index.txt`.


