#!/bin/bash

# Get CPU usage history and create a sparkline graph
# Uses Unicode block characters to show CPU history

HISTORY_FILE="/tmp/waybar-cpu-history"
MAX_POINTS=8

# Get current CPU usage
current=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
current_int=$(printf "%.0f" "$current")

# Read history
if [ -f "$HISTORY_FILE" ]; then
    history=$(cat "$HISTORY_FILE")
else
    history=""
fi

# Add current to history
history="$history $current_int"

# Keep only last MAX_POINTS
history=$(echo $history | awk -v max=$MAX_POINTS '{n=NF-max+1; if(n<1) n=1; for(i=n; i<=NF; i++) printf "%s ", $i}')

# Save history
echo "$history" > "$HISTORY_FILE"

# Create sparkline using block characters
blocks=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")
graph=""

for val in $history; do
    # Scale value (0-100) to block index (0-7)
    idx=$((val * 7 / 100))
    if [ $idx -gt 7 ]; then idx=7; fi
    if [ $idx -lt 0 ]; then idx=0; fi
    graph="${graph}${blocks[$idx]}"
done

# Output JSON
echo "{\"text\":\"$graph ${current_int}%\", \"percentage\":$current_int, \"tooltip\":\"CPU: ${current_int}%\"}"
