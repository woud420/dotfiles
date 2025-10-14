#!/bin/sh

mount="/home/jm/workspace"
warning=80
critical=90

df -h -P -l "$mount" | awk -v warning=$warning -v critical=$critical '
/workspace.*/ {
  text=$4
  tooltip="Workspace: "$2" total, "$3" used, "$4" free ("$5")"
  use=$5
  exit 0
}
END {
  class=""
  gsub(/%$/,"",use)
  if (use > critical) {
    class="critical"
  } else if (use > warning) {
    class="warning"
  }
  print "{\"text\":\""text"\", \"percentage\":"use",\"tooltip\":\""tooltip"\", \"class\":\""class"\"}"
}
'
