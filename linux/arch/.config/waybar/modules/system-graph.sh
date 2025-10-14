#!/bin/bash

# Simple CPU + Memory display with load indicators

# Get current CPU usage
cpu_usage=$(top -bn2 -d 0.5 | grep "Cpu(s)" | tail -1 | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
cpu_int=$(printf "%.0f" "$cpu_usage")

# Get current memory usage
mem_usage=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')

# Choose icon based on CPU load
if [ $cpu_int -lt 25 ]; then
    cpu_icon=""
elif [ $cpu_int -lt 50 ]; then
    cpu_icon=""
elif [ $cpu_int -lt 75 ]; then
    cpu_icon=""
else
    cpu_icon=""
fi

# Simple compact display
text="${cpu_int}% ${mem_usage}%"
tooltip="CPU: ${cpu_int}%\nMemory: ${mem_usage}%"

echo "{\"text\":\"$text\", \"tooltip\":\"$tooltip\"}"
