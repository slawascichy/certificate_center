# Serwerowe skrypty pomocnicze
Tutaj znajdziemy szereg skryptów, które wesprą nasze działania na serwerach, na których konfigurujemy usługi SSL

## Opis skryptów i plików

### ./websphere_refresh_cert.sh
Przykładowa implementacja skryptu realizującego zadania:
1. Odświeżenie certyfikatów  [Let's Encrypt](https://letsencrypt.org/) - polecenie `certbot`
2. Załadowanie odświeżonych certyfikatów do magazynów serwera aplikacji WebSphere.