#!/usr/bin/env bash

envs=(ADMIN_JID DOMAIN CONTACT_EMAIL RECAPTCHA_PRIVATE RECAPTCHA_PUBLIC)

if test $# -eq 0; then
  for i in ${envs[@]}; do
    if test -z "${!i}"; then
      echo "Missing env variable: $i"
      exit 1
    fi
    export $i
  done
  # cron
  printenv | grep -v no_proxy > /etc/environment
  /etc/init.d/cron start
  # db
  chown -R prosody:prosody /var/lib/prosody
  chmod -R 750 /var/lib/prosody
  # prosody.cfg.lua
  sed -i -e "s#{domain}#$DOMAIN#g" \
    -e "s#{admin_jid}#${ADMIN_JID}#g" \
    -e "s#{contact_email}#$CONTACT_EMAIL#g" \
    -e "s#{recaptcha_private}#${RECAPTCHA_PRIVATE}#g" \
    -e "s#{recaptcha_public}#${RECAPTCHA_PUBLIC}#g" \
    /etc/prosody/prosody.cfg.lua
  # cert
  /import_certs.sh
  (crontab -l | grep -v import_certs.sh; echo "0 1 * * * /import_certs.sh") | crontab -
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
  (crontab -l | grep -v stats.sh; echo "* * * * * /stats.sh") | crontab -
  # limits
  sysctl fs.file-max=6553560 2>/dev/null
  [ -f /etc/systemd/system.conf ] && sed -i "s/^#DefaultLimitNOFILE=.*/DefaultLimitNOFILE=500000/g" /etc/systemd/system.conf
  echo -e "* soft nofile 500000\n* hard nofile 500000\nroot soft nofile 500000\nroot hard nofile 500000" > /etc/security/limits.conf 2>/dev/null
  echo "MAXFDS=500000" > /etc/default/prosody
  # prosody
  exec su -c "/usr/bin/prosody" --preserve-environment -s /bin/sh prosody
else
  exec $@
fi
