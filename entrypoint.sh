#!/usr/bin/env bash

envs=(ADMIN_JID DOMAIN CAPTCHA_PRIVATE CAPTCHA_PUBLIC)

function generate_rbl_rules() {
  # https://github.com/JabberSPAM/resources/blob/master/prosody/restrict-proxy-registrations.md#firewall-rules
cat > /etc/prosody/rbl.pfw <<EOF
%LIST whitelist_to: file:/etc/prosody/whitelist_to.txt

############ preroute chain: stanzas from local users ############
::preroute

# allow errors, whitelisted and self-messages
JUMP_CHAIN=user/pass_acceptable

# process stanzas from marked users
USER MARKED: dnsbl_hit
JUMP_CHAIN=user/marked_user

# you can add further rules to restrict non-marked users as well
# ...


############ chain to pass acceptable messages ############
::user/pass_acceptable

# do not firewall error stanzas, or they'll loop
TYPE: error
PASS.

# accept unsubscribe(d) and unavailable (see #1331)
KIND: presence
TYPE: unsubscribe|unsubscribed|unavailable
PASS.

# do not filter whitelisted receivers
CHECK LIST: whitelist_to contains $<@to|bare>
PASS.

# do not filter stanzas to self
TO SELF?
PASS.


############ quarantine for MARKed users ############
::user/marked_user

# reject outgoing subscriptions, allow MUC and normal presence
KIND: presence
TYPE: subscribe
JUMP_CHAIN=user/bounce_marked

# work around issue #1331
KIND: presence
TYPE: unavailable
PASS.

# allow talking to contacts
SUBSCRIBED?
PASS.

# bounce all non-MUC messages
KIND: message
TYPE: chat|normal|headline
NOT SUBSCRIBED?
JUMP_CHAIN=user/bounce_marked


############ rule to reject spam messages and responses ############
::user/bounce_marked
LOG=spam: marked-user \$(stanza)
BOUNCE=not-allowed (Your account is suspended. Contact support.)
EOF
}

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
    -e "s#{captcha_private}#${CAPTCHA_PRIVATE}#g" \
    -e "s#{captcha_public}#${CAPTCHA_PUBLIC}#g" \
    /etc/prosody/prosody.cfg.lua
  # allow legitimate users to talk to admin to get unblocked
  echo "${ADMIN_JID}" > /etc/prosody/whitelist_to.txt
  generate_rbl_rules
  # acme.sh
  (crontab -l | grep -v acme.sh; echo "2 0 * * * /root/.acme.sh/acme.sh --cron --home /root/.acme.sh > /dev/null") | crontab -
  # cert
  /import_certs.sh
  (crontab -l | grep -v import_certs.sh; echo "0 1 * * * /import_certs.sh") | crontab -
  # change acme.sh from standalone mode to webroot mode
  sed -i -e "s#Le_Webroot='no'#Le_Webroot='/www'#g" /root/.acme.sh/${DOMAIN}/${DOMAIN}.conf
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
  exec su -c "/usr/bin/prosody -F" --preserve-environment -s /bin/sh prosody
else
  exec $@
fi
