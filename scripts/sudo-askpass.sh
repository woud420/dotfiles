#!/bin/bash
# Cross-platform sudo askpass helper

case "$(uname -s)" in
  Darwin)
    # macOS: use osascript (built-in)
    osascript -e 'Tell application "System Events" to display dialog "Password:" default answer "" with hidden answer' -e 'text returned of result' 2>/dev/null
    ;;
  Linux)
    # Linux: prefer rofi, fall back to zenity/kdialog
    if command -v rofi &>/dev/null; then
      rofi -dmenu -password -p "sudo" -l 0 -theme-str 'window {width: 300px;} listview {enabled: false;}'
    elif command -v zenity &>/dev/null; then
      zenity --password --title="sudo"
    elif command -v kdialog &>/dev/null; then
      kdialog --password "sudo"
    else
      echo "No askpass helper found" >&2
      exit 1
    fi
    ;;
esac
