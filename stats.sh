#!/bin/bash

make_stats () {
  total_users=$(echo -e "user:list(\"$DOMAIN\")\nbye\n" | nc -w 5 localhost 5582 | sed '/Showing all/!d' | grep -o --color=never '[0-9]*')
  online_users=$(echo -e "c2s:show()\nbye\n" | nc -w 5 localhost 5582 | sed "/@$DOMAIN/!d" | awk -F / '{print $1}' | sort | uniq | wc -l)

  cat << EOF > /www/stats.json
  {
    "total_users": $total_users,
    "online_users": $online_users
  }
EOF
}

# wait for prosody server to start
sleep 5

while true; do
  make_stats
  sleep 1m
done
