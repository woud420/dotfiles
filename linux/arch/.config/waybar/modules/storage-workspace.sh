#!/bin/sh

mount="$HOME/workspace"
warning=80
critical=90

# Exit quietly (module hides) when the workspace mount does not exist
[ -d "$mount" ] || exit 1

df -h -P -l "$mount" | awk -v warning=$warning -v critical=$critical '
NR==2 {
  text=$4
  tooltip="Workspace: "$2" total, "$3" used, "$4" free ("$5")"
  use=$5
}
END {
  if (use == "") { exit 1 }
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
