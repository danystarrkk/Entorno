#!/bin/sh

TARGET_FILE="$HOME/.config/bin/target"

# Verificamos si el archivo existe y leemos su contenido de un solo golpe
if [ -f "$TARGET_FILE" ]; then
  read -r ip_target name_target <"$TARGET_FILE"

  if [ -n "$ip_target" ] && [ -n "$name_target" ]; then
    # Ícono grande con espacio para que no se corte
    echo "%{F#d11507}%{T2}󰯐 %{T-}%{F#ffffff}$ip_target - $name_target"
  elif [ -n "$ip_target" ]; then
    echo "%{F#d11507}%{T2}󰯐 %{T-}%{F#ffffff}$ip_target"
  else
    # Ícono grande de "No target" con espacio
    echo "%{F#d11507}%{T2}󰓾 %{T-}%{F#ffffff}No target"
  fi
else
  echo "%{F#d11507}%{T2}󰓾 %{T-}%{F#ffffff}No target"
fi
