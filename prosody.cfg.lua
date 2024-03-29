-- Prosody XMPP Server Configuration
--
-- Information on configuring Prosody can be found on our
-- website at https://prosody.im/doc/configure
--
-- Tip: You can check that the syntax of this file is correct
-- when you have finished by running this command:
--     prosodyctl check config
-- If there are any errors, it will let you know what and where
-- they are, otherwise it will keep quiet.
--
-- Good luck, and happy Jabbering!


---------- Server-wide settings ----------
-- Settings in this section apply to the whole server and are the default settings
-- for any virtual hosts

-- This is a (by default, empty) list of accounts that are admins
-- for the server. Note that you must create the accounts separately
-- (see https://prosody.im/doc/creating_accounts for info)
-- Example: admins = { "user1@example.com", "user2@example.net" }
admins = { "{admin_jid}" }

-- Enable use of libevent for better performance under high load
-- For more information see: https://prosody.im/doc/libevent
use_libevent = true

-- Prosody will always look in its source directory for modules, but
-- this option allows you to specify additional locations where Prosody
-- will look for modules first. For community modules, see https://modules.prosody.im/
plugin_paths = { "/etc/prosody/prosody-modules" }

-- This is the list of modules Prosody will load on startup.
-- It looks for mod_modulename.lua in the plugins folder, so make sure that exists too.
-- Documentation for bundled modules can be found at: https://prosody.im/doc/modules
modules_enabled = {

  -- Generally required
  "roster"; -- Allow users to have a roster. Recommended ;)
  "saslauth"; -- Authentication for clients and servers. Recommended if you want to log in.
  "tls"; -- Add support for secure TLS on c2s/s2s connections
  "disco"; -- Service discovery

  -- Not essential, but recommended
  "carbons"; -- Keep multiple clients in sync
  "dialback"; -- s2s dialback support
  "limits"; -- Enable bandwidth limiting for XMPP connections
  "pep"; -- Enables users to publish their mood, activity, playing music and more
  "private"; -- Private XML storage (for room bookmarks, etc.)
  "smacks"; -- Stream management and resumption (XEP-0198)
  "blocklist"; -- Allow users to block communications with other users
  "bookmarks"; -- Synchronise the list of open rooms between clients
  "vcard4"; -- User profiles (stored in PEP)
  "vcard_legacy"; -- Conversion between legacy vCard and PEP Avatar, vcard

  -- Nice to have
  "version"; -- Replies to server version requests
  "uptime"; -- Report how long server has been running
  "time"; -- Let others know the time here on this server
  "ping"; -- Replies to XMPP pings with pongs
  "register"; -- Allow users to register on this server using a client and change passwords
  "mam"; -- Store messages in an archive and allow users to access it
  "csi_simple"; -- Simple Mobile optimizations

  -- Admin interfaces
  "admin_adhoc"; -- Allows administration via an XMPP client that supports ad-hoc commands
  "admin_telnet"; -- Opens telnet console interface on localhost port 5582
  "admin_shell"; -- Allow secure administration via 'prosodyctl shell'

  -- HTTP modules
  "bosh"; -- Enable BOSH clients, aka "Jabber over HTTP"
  "websocket"; -- XMPP over WebSockets
  "http_files"; -- Serve static files from a directory over HTTP

  -- Other specific functionality
  "server_contact_info"; -- Publish contact information for this service
  "announce"; -- Send announcement to all online users
  "welcome"; -- Welcome users who register accounts
  "watchregistrations"; -- Alert admins of registrations
  "proxy65"; -- Enables a file transfer proxy service which clients behind NAT can use
  "s2s_bidi"; -- Bi-directional server-to-server (XEP-0288)
  "tombstones"; -- Prevent registration of deleted accounts

  -- Custom
  "cloud_notify";
  "http_altconnect";
  "register_web";
  "listusers";
  "block_registrations";
  "firewall",
  "register_dnsbl_firewall_mark";
  "spam_reporting";
  "watch_spam_reports";
  "s2s_blacklist";
}

-- These modules are auto-loaded, but should you want
-- to disable them then uncomment them here:
modules_disabled = {
  -- "offline"; -- Store offline messages
  -- "c2s"; -- Handle client connections
  -- "s2s"; -- Handle server-to-server connections
  -- "posix"; -- POSIX functionality, sends server to background, enables syslog, etc.
}

contact_info = {
  abuse = { "xmpp:{admin_jid}" };
  admin = { "xmpp:{admin_jid}" };
  feedback = { "xmpp:{admin_jid}" };
  security = { "xmpp:{admin_jid}" };
  support = { "xmpp:{admin_jid}" };
}

limits = {
  c2s = {
    rate = "10kb/s";
    burst = "2s";
  };
  s2sin = {
    rate = "30kb/s";
    burst = "5s";
  }
}

-- Disable account creation by default, for security
-- For more information see https://prosody.im/doc/creating_accounts
allow_registration = false
min_seconds_between_registrations = 60

-- Force clients to use encrypted connections? This option will
-- prevent clients from authenticating unless they are using encryption.

c2s_require_encryption = true

-- Force servers to use encrypted connections? This option will
-- prevent servers from authenticating unless they are using encryption.
-- Note that this is different from authentication

s2s_require_encryption = true


-- Force certificate authentication for server-to-server connections?
-- This provides ideal security, but requires servers you communicate
-- with to support encryption AND present valid, trusted certificates.
-- NOTE: Your version of LuaSec must support certificate verification!
-- For more information see https://prosody.im/doc/s2s#security

s2s_secure_auth = true

-- Some servers have invalid or self-signed certificates. You can list
-- remote domains here that will not be required to authenticate using
-- certificates. They will be authenticated using DNS instead, even
-- when s2s_secure_auth is enabled.

--s2s_insecure_domains = { "gmail.com", "im.rmilk.com" }

-- Even if you leave s2s_secure_auth disabled, you can still require valid
-- certificates for some domains by specifying a list here.

--s2s_secure_domains = { "jabber.org" }

legacy_ssl_ports = { 5223 }
legacy_ssl_ssl = {
  certificate = "/etc/prosody/certs/{domain}.crt";
  key = "/etc/prosody/certs/{domain}.key";
}

-- Required for init scripts and prosodyctl
pidfile = "/tmp/prosody.pid"

-- Select the authentication backend to use. The 'internal' providers
-- use Prosody's configured data storage to store the authentication data.
-- To allow Prosody to offer secure authentication mechanisms to clients, the
-- default provider stores passwords in plaintext. If you do not trust your
-- server please see https://prosody.im/doc/modules/mod_auth_internal_hashed
-- for information about using the hashed backend.

authentication = "internal_hashed"

-- Select the storage backend to use. By default Prosody uses flat files
-- in its configured data directory, but it also supports more backends
-- through modules. An "sql" backend is included by default, but requires
-- additional dependencies. See https://prosody.im/doc/storage for more info.

storage = "internal" -- Default is "internal"

-- For the "sql" backend, you can uncomment *one* of the below to configure:
-- sql = { driver = "SQLite3", database = "prosody.sqlite" } -- Default. 'database' is the filename.
--sql = { driver = "MySQL", database = "prosody", username = "prosody", password = "secret", host = "localhost" }
--sql = { driver = "PostgreSQL", database = "prosody", username = "prosody", password = "secret", host = "localhost" }


-- Archiving configuration
-- If mod_mam is enabled, Prosody will store a copy of every message. This
-- is used to synchronize conversations between multiple clients, even if
-- they are offline. This setting controls how long Prosody will keep
-- messages in the archive before removing them.

default_archive_policy = true
archive_expires_after = "1w" -- Remove archived messages after 1 week

-- You can also configure messages to be stored in-memory only. For more
-- archiving options, see https://prosody.im/doc/modules/mod_mam

-- Logging configuration
-- For advanced logging see https://prosody.im/doc/logging
log = {
  {levels = {min = "info"}, to = "console"};
}

-- Uncomment to enable statistics
-- For more info see https://prosody.im/doc/statistics
-- statistics = "internal"

-- Certificates
-- Every virtual host and component needs a certificate so that clients and
-- servers can securely verify its identity. Prosody will automatically load
-- certificates/keys from the directory specified here.
-- For more information, including how to use 'prosodyctl' to auto-import certificates
-- (from e.g. Let's Encrypt) see https://prosody.im/doc/certificates

-- Location of directory to find certificates in (relative to main config file):
certificates = "certs"
https_certificate = "certs/{domain}.crt"

http_default_host = "{domain}"
http_paths = {
  register_web = "/register";
  files = "/";
}
http_ports = { 80 }
https_ports = { 443 }
-- Allow unencrypted HTTP connections
http_interfaces = { "0.0.0.0", "::" }


block_registrations_users = { "administrator", "admin", "root", "postmaster", "xmpp", "jabber", "contact", "mail", "abuse" }
-- Allow only simple ASCII characters in usernames
block_registrations_require = "^[a-zA-Z0-9_.-]+$"

-- DroneBL
registration_rbl = "dnsbl.dronebl.org"
-- Automatic message to flagged user account, outlining where to find help
-- as well as why the IP was blocked. You can use the following variables:
--   $ip $username $host
registration_rbl_message = "[...] More details: https://dronebl.org/lookup?ip=$ip"
-- Enable firewall marks and load the firewall script
firewall_experimental_user_marks = true
firewall_scripts = {
  "/etc/prosody/rbl.pfw";
  "module:scripts/jabberspam-simple-blocklist.pfw";
}

s2s_blacklist = {
    "chatwith.xyz",
    "exploit.im",
    "jabbim.sk",
    "jabbim.ru",
    "omemo.im",
    "crime.io",
    "xmpp.jp",
    "jabber.cz",
    "draugr.de",
    "jabster.pl",
    "blabber.im",
    "jabbim.cz",
    "jabb.im",
    "jabbim.pl",
    "njs.netlab.cz",
    "jabber.root.cz",
    "0nl1ne.at",
    "jabbim.com",
    "xabber.de",
    "creep.im",
    "ubuntu-jabber.de",
    "ubuntu-jabber.net",
    "verdammung.org",
    "deshalbfrei.org",
    "jabber.sk",
    "0day.im",
    "0day.la",
    "01337.ru",
    "01337.io",
    "c99x.io",
    "c99x.cc",
    "htp.im",
    "hell.la",
    "sqli.io",
    "shad0w.ru",
    "shad0w.la",
    "shad0w.io",
    "shadownet.su",
    "darknet.im",
    "chinwag.im",
    "yourdata.forsale",
    "jabber.ccc.de",
    "thesecure.biz",
    "jabbim.club",
    "jabbim.rocks",
    "xmpp.cz",
}

captcha_options = {
  provider = "hcaptcha";
  captcha_private_key = "{captcha_private}";
  captcha_public_key = "{captcha_public}";
}

registration_notification = "User $username just registered on $host from $ip via $source"

http_files_dir = "/www"

----------- Virtual hosts -----------
-- You need to add a VirtualHost entry for each domain you wish Prosody to serve.
-- Settings under each VirtualHost entry apply *only* to that host.

VirtualHost "{domain}"

--VirtualHost "example.com"
--  certificate = "/path/to/example.crt"

------ Components ------
-- You can specify components to add hosts that provide special services,
-- like multi-user conferences, and transports.
-- For more information on components, see https://prosody.im/doc/components

---Set up a MUC (multi-user chat) room server on conference.example.com:
Component "room.{domain}" "muc"
  name = "{domain} Chatroom"
  restrict_room_creation = "local"
  muc_tombstones = true
  modules_enabled = {
    "muc_mam",
    "muc_limits",
    "vcard_muc",
  }

Component "proxy.{domain}" "proxy65"
  proxy65_address = "{domain}"
  proxy65_acl = { "{domain}" }

Component "upload.{domain}" "http_file_share"
  modules_enabled = {
    "acme_challenge_dir",
  }
  http_file_share_size_limit = 50*1024*1024 -- 50 MiB
  http_file_share_daily_quota = 200*1024*1024 -- 200 MiB per day per user
  http_file_share_global_quota = 512*1024*1024 -- 5 GiB total
  http_file_share_expires_after = 60 * 60 * 24 -- a day

---Set up an external component (default component port is 5347)
--
-- External components allow adding various services, such as gateways/
-- transports to other networks like ICQ, MSN and Yahoo. For more info
-- see: https://prosody.im/doc/components#adding_an_external_component
--
--Component "gateway.example.com"
--  component_secret = "password"
