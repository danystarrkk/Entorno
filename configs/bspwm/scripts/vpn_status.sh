#!/bin/sh

# Solo verificamos si la carpeta de la interfaz existe en el sistema (Costo de CPU: casi cero)
if [ -d "/sys/class/net/tun0" ]; then
    # Usamos 'ip' moderno en lugar de ifconfig para extraer la IP directamente
    IP=$(ip -4 -br addr show tun0 2>/dev/null | awk '{print $3}' | cut -d/ -f1)
    
    if [ -n "$IP" ]; then
        echo "%{F#1bbf3e}󰅣  %{F#ffffff}%{T6}$IP%{u-}%{T-}"
    else
        echo "%{F#1bbf3e}󰅤 %{u-} %{F#ffffff}%{T6}Error%{T-}"
    fi
else
    echo "%{F#1bbf3e}󰅤 %{u-} %{F#ffffff}%{T6}Disconnected%{T-}"
fi
