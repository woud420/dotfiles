#!/bin/bash

class=$(playerctl metadata --player=spotify --format '{{lc(status)}}' 2>/dev/null)
icon=""

if [[ $class == "playing" ]]; then
  info=$(playerctl metadata --player=spotify --format '{{artist}} - {{title}}')
  if [[ ${#info} -gt 40 ]]; then
    info=$(echo "$info" | cut -c1-40)"..."
  fi
  text=$info
elif [[ $class == "paused" ]]; then
  text="$icon paused"
elif [[ $class == "stopped" ]]; then
  text="$icon stopped"
fi

echo -e "{\"text\":\""$text"\", \"class\":\""$class"\"}"
