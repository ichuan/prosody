#!/bin/bash

make_stats () {
  total_users=$(echo -en "user:list(\"$DOMAIN\")\nbye\n" | nc -w 5 localhost 5582 | sed '/Showing all/!d' | grep -o --color=never '[0-9]*')
  onlines=$(echo -en "c2s:show()\nbye\n" | nc -w 5 localhost 5582 | sed "/@$DOMAIN/!d" | awk -F / '{print $1}' | sort)
  c2s_connections=$(echo "$onlines" | wc -l)
  online_users=$(echo "$onlines" | uniq | wc -l)

  cat << EOF > /www/stats.json
  {
    "total_users": $total_users,
    "c2s_connections": $c2s_connections,
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
