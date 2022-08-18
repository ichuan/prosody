
# https://prosody.im/download

FROM debian:bullseye

RUN apt update && apt install -y wget gnupg mercurial netcat cron socat libcap2-bin
RUN echo deb http://packages.prosody.im/debian bullseye main | tee /etc/apt/sources.list.d/prosody.list
RUN wget https://prosody.im/files/prosody-debian-packages.key -O- | apt-key add -
# https://prosody.im/doc/depends
RUN apt update && apt install -y lua5.3 lua-readline lua-unbound lua-event lua-socket lua-sec lua-expat lua-filesystem prosody-trunk
RUN update-alternatives --set lua-interpreter /usr/bin/lua5.3 && setcap 'cap_net_bind_service=+eip' /usr/bin/lua5.3
RUN hg clone 'https://hg.prosody.im/prosody-modules/' /etc/prosody/prosody-modules
ADD mod_acme_challenge_dir.lua /etc/prosody/prosody-modules/mod_acme_challenge_dir/
RUN wget -O - https://get.acme.sh | sh -s email=me@me.com

# cleanup
RUN apt remove -y mercurial && apt autoremove -y && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh stats.sh import_certs.sh /
COPY www /www
COPY prosody.cfg.lua /etc/prosody/prosody.cfg.lua
RUN chmod +x /entrypoint.sh /stats.sh /import_certs.sh

ENTRYPOINT ["/entrypoint.sh"]
