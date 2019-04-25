#!/usr/bin/env bash

set -e

envs=(ADMIN_JID DOMAIN CONTACT_EMAIL RECAPTCHA_PRIVATE RECAPTCHA_PUBLIC)

if test $# -eq 0; then
  for i in ${envs[@]}; do
    if test -z "${!i}"; then
      echo "Missing env variable: $i"
      exit 1
    fi
    export $i
  done
  # db
  chown -R prosody:prosody /var/lib/prosody
  chmod -R 750 /var/lib/prosody
  # cert
  sed -i -e "s#{domain}#$DOMAIN#g" \
    -e "s#{admin_jid}#${ADMIN_JID}#g" \
    -e "s#{contact_email}#$CONTACT_EMAIL#g" \
    -e "s#{recaptcha_private}#${RECAPTCHA_PRIVATE}#g" \
    -e "s#{recaptcha_public}#${RECAPTCHA_PUBLIC}#g" \
    /etc/prosody/prosody.cfg.lua
  /import_certs.sh >/dev/null &
  sleep 1
  for sub in room proxy; do
    [ ! -f "/etc/prosody/certs/${sub}.${DOMAIN}.crt" ] && {
      ln -s "/etc/prosody/certs/${DOMAIN}.crt" "/etc/prosody/certs/${sub}.${DOMAIN}.crt"
      ln -s "/etc/prosody/certs/${DOMAIN}.key" "/etc/prosody/certs/${sub}.${DOMAIN}.key"
    }
  done
  # www
  sed -i -e "s#{domain}#$DOMAIN#g" -e "s#{admin_jid}#${ADMIN_JID}#g" \
      -e "s#{since}#$SINCE#g" /www/index.html
  # stats
  /stats.sh >/dev/null &
  exec su -c "/usr/bin/prosody" --preserve-environment -s /bin/sh prosody
else
  exec $@
fi
