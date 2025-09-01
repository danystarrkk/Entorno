#!/bin/bash

# Mata instancias previas
killall -q polybar

# Espera a que terminen
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Lanza cada barra
polybar logo -c ~/.config/polybar/config.ini &
polybar workspaces -c ~/.config/polybar/config.ini &
polybar top-ip -c ~/.config/polybar/config.ini &
polybar top-target -c ~/.config/polybar/config.ini &
polybar top-status -c ~/.config/polybar/config.ini &
polybar top-time -c ~/.config/polybar/config.ini &
