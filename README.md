# Prosody
From [616.pub](https://616.pub). Using the following steps to setup a self-hosted
jabber server.

## 0. Requirements
- A linux server with docker installed
  - As low as 1 core, 512MB memory
- A domain under your control
- A pair of [reCaptcha](https://www.google.com/recaptcha/admin/create) keys filter spamming in register page

## 1. Define some varibles

```sh
# You need a domain
DOMAIN=yourdomain.com
# Your jabber account on that server, will be created as admin.
JID="yourname@${DOMAIN}"
# recaptcha keys
RECAPTCHA_PRIVATE=xxx
RECAPTCHA_PUBLIC=yyy
```

## 2. DNS configure

Suppose your server IP is *1.2.3.4*, the following records should be set (
replace *DOMAIN* with your real domain name):

```zone
;; A Records
DOMAIN.	1	IN	A	1.2.3.4
room.DOMAIN.	1	IN	A	1.2.3.4

;; SRV Records
_xmpp-client._tcp.DOMAIN.	1	IN	SRV	0 5 5222 DOMAIN.
_xmpps-client._tcp.DOMAIN.	1	IN	SRV	0 5 5223 DOMAIN.
_xmpps-client._tcp.DOMAIN.	1	IN	SRV	5 0 443 DOMAIN.
_xmpp-server._tcp.DOMAIN.	1	IN	SRV	0 5 5269 DOMAIN.
```

## 3. Obtain domain SSL certs

```sh
mkdir -p acme.sh
docker volume create --driver local --opt type=none --opt device=$PWD/acme.sh --opt o=bind acme.sh
docker run -it --rm --name acme.sh -p 80:80 -v acme.sh:/root/.acme.sh ichuan/prosody \
  /root/.acme.sh/acme.sh --home /root/.acme.sh --issue --standalone -d $DOMAIN
```

Certs will be renewed automatically.

## 4. Running

```bash

# database
mkdir prosody

# datetime when this server goes live
SINCE="2018/9/2"

# ports: 5223:legacy_ssl, 5280:http, 5281:https, 5000:proxy65, 5222:c2s, 5269:s2s
docker run --restart always -itd --name iprosody \
  -p 5223:5223 -p 80:5280 -p 5280:5280 -p 443:5281 -p 5281:5281 \
  -p 5000:5000 -p 5222:5222 -p 5269:5269 \
  -v $PWD/prosody:/var/lib/prosody \
  -v acme.sh:/root/.acme.sh \
  -e ADMIN_JID=$JID -e DOMAIN=$DOMAIN -e SINCE=$SINCE \
  -e RECAPTCHA_PRIVATE=$RECAPTCHA_PRIVATE \
  -e RECAPTCHA_PUBLIC=$RECAPTCHA_PUBLIC \
  ichuan/prosody
```

Now, head to https://*DOMAIN* to see it.

## 5. Maintenance

```sh
# Create your admin JID
docker exec -it iprosody prosodyctl adduser $JID
# or via web: https://${DOMAIN}/register
```


## 6. Upgrading

```sh
docker pull ichuan/prosody
docker stop iprosody && docker rm iprosody
# re-run with previous command line
docker run --restart always ...
```
