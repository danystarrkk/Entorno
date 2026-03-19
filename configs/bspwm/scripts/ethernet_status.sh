#!/bin/sh

# Detecta automáticamente la interfaz de red principal (ignorando loopback y docker)
IFACE=$(ip route get 8.8.8.8 2>/dev/null | awk '{print $5; exit}')

if [ -n "$IFACE" ]; then
    # Extrae la IP de esa interfaz
    IP=$(ip -4 -br addr show "$IFACE" 2>/dev/null | awk '{print $3}' | cut -d/ -f1)
    echo "%{F#2495e7}󰈀  %{F#ffffff}%{T6}$IP%{u-}%{T-}"
else
    echo "%{F#2495e7}󰈂  %{F#ffffff}%{T6}Disconnected%{u-}%{T-}"
fi
