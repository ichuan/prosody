#!/bin/sh

while true; do
  prosodyctl --root cert import /etc/letsencrypt/live
  sleep 1d
done
