#!/bin/bash

if [ -f "/etc/prosody/certs/${DOMAIN}.key" ]; then
  checksums=`md5sum /root/.acme.sh/${DOMAIN}/${DOMAIN}.key /etc/prosody/certs/${DOMAIN}.key | awk '{print $1}' | uniq | wc -l`
  if [ "$checksums" = "1" ]; then
    exit 0
  fi
fi

cp -f /root/.acme.sh/${DOMAIN}/fullchain.cer /etc/prosody/certs/${DOMAIN}.crt
cp -f /root/.acme.sh/${DOMAIN}/${DOMAIN}.key /etc/prosody/certs/${DOMAIN}.key
chmod 777 /etc/prosody/certs/${DOMAIN}.{crt,key}
# try reload http after renew
echo -en "module:reload('c2s')\nmodule:reload('s2s')\nmodule:reload('http')\nbye\n" | nc -w 5 localhost 5582
