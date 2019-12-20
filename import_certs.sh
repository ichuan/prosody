#!/bin/bash

cp -f /root/.acme.sh/${DOMAIN}/fullchain.cer /etc/prosody/certs/${DOMAIN}.crt
cp -f /root/.acme.sh/${DOMAIN}/${DOMAIN}.key /etc/prosody/certs/${DOMAIN}.key
chmod 777 /etc/prosody/certs/${DOMAIN}.{crt,key}
