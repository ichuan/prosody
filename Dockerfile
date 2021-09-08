
# https://prosody.im/download

FROM debian:10

RUN apt update && apt install -y wget gnupg mercurial netcat cron socat
RUN echo deb http://packages.prosody.im/debian buster main | tee -a /etc/apt/sources.list
RUN wget https://prosody.im/files/prosody-debian-packages.key -O- | apt-key add -
RUN apt update && apt install -y lua5.3 prosody-trunk lua-event lua-sec
RUN hg clone 'https://hg.prosody.im/prosody-modules/' /etc/prosody/prosody-modules
ADD mod_acme_challenge_dir.lua /etc/prosody/prosody-modules/mod_acme_challenge_dir/
RUN wget -O - https://get.acme.sh | sh

# cleanup
RUN apt remove -y mercurial && apt autoremove -y && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh stats.sh import_certs.sh /
COPY www /www
COPY prosody.cfg.lua /etc/prosody/prosody.cfg.lua
RUN chmod +x /entrypoint.sh /stats.sh /import_certs.sh

ENTRYPOINT ["/entrypoint.sh"]
