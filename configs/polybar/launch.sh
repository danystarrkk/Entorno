#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar

# Launch bar
polybar top -r >>/tmp/polybar1.log 2>&1 & disown

echo "Bars launched..."

