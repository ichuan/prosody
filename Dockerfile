
# https://prosody.im/download

FROM debian:stretch
# legacy_ssl, http, https, proxy65, c2s, s2s
EXPOSE 5223 5280 5281 5000 5222 5269

RUN apt update && apt install -y wget gnupg mercurial netcat cron socat
RUN echo deb http://packages.prosody.im/debian stretch main | tee -a /etc/apt/sources.list
RUN wget https://prosody.im/files/prosody-debian-packages.key -O- | apt-key add -
RUN apt update && apt install -y prosody lua-event lua-sec
RUN hg clone 'https://hg.prosody.im/prosody-modules/' /etc/prosody/prosody-modules
RUN echo MAXFDS=9999 > /etc/default/prosody
RUN wget -O - https://get.acme.sh | sh

# recaptcha
# replace google.com with recaptcha.net, for accessing in China
RUN cp -rf /etc/prosody/prosody-modules/mod_register_web/templates/ /etc/prosody/ && \
    sed -i 's/www.google.com/www.recaptcha.net/g' /etc/prosody/templates/recaptcha.html

# cleanup
RUN apt remove -y mercurial && apt autoremove -y && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh stats.sh import_certs.sh /
COPY www /www
COPY prosody.cfg.lua /etc/prosody/prosody.cfg.lua
RUN chmod +x /entrypoint.sh /stats.sh /import_certs.sh

ENTRYPOINT ["/entrypoint.sh"]
