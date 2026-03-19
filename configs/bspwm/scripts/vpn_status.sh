#!/bin/sh

# Solo verificamos si la carpeta de la interfaz existe en el sistema (Costo de CPU: casi cero)
if [ -d "/sys/class/net/tun0" ]; then
  # Usamos 'ip' moderno en lugar de ifconfig para extraer la IP directamente
  IP=$(ip -4 -br addr show tun0 2>/dev/null | awk '{print $3}' | cut -d/ -f1)

  if [ -n "$IP" ]; then
    # Ícono grande con espacio de respiro
    echo "%{F#1bbf3e}%{T2}󰅣  %{T-}%{F#ffffff}$IP"
  else
    # Ícono grande de error con espacio
    echo "%{F#1bbf3e}%{T2}󰅤  %{T-}%{F#ffffff}Error"
  fi
else
  # Ícono grande de desconexión con espacio
  echo "%{F#1bbf3e}%{T2}󰅤  %{T-}%{F#ffffff}Disconnected"
fi
