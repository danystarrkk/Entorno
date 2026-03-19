#!/bin/sh

# Detecta automáticamente la interfaz de red principal (ignorando loopback y docker)
IFACE=$(ip route get 8.8.8.8 2>/dev/null | awk '{print $5; exit}')

if [ -n "$IFACE" ]; then
  # Extrae la IP de esa interfaz
  IP=$(ip -4 -br addr show "$IFACE" 2>/dev/null | awk '{print $3}' | cut -d/ -f1)

  # Aplicamos %{T2} para el ícono y dejamos un espacio extra para evitar el corte
  echo "%{F#2495e7}%{T2}󰈀  %{T-}%{F#ffffff}$IP"
else
  # Mismo truco para cuando estés desconectado
  echo "%{F#2495e7}%{T2}󰈂  %{T-}%{F#ffffff}Disconnected"
fi
