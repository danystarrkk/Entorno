#!/bin/sh

# Detecta automáticamente la interfaz de red principal (ignorando loopback y docker)
IFACE=$(ip route get 8.8.8.8 2>/dev/null | awk '{print $5; exit}')

if [ -n "$IFACE" ]; then
    # Extrae la IP de esa interfaz
    IP=$(ip -4 -br addr show "$IFACE" 2>/dev/null | awk '{print $3}' | cut -d/ -f1)
    # Sin etiquetas T6 ni u-, usando la fuente base estandarizada
    echo "%{F#2495e7}󰈀  %{F#ffffff}$IP"
else
    echo "%{F#2495e7}󰈂  %{F#ffffff}Disconnected"
fi
