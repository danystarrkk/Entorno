#!/bin/sh

TARGET_FILE="$HOME/.config/bin/target"

# Verificamos si el archivo existe y leemos su contenido de un solo golpe
if [ -f "$TARGET_FILE" ]; then
    read -r ip_target name_target < "$TARGET_FILE"

    if [ -n "$ip_target" ] && [ -n "$name_target" ]; then
        echo "%{F#d11507}󰯐 %{F#ffffff}%{T6}$ip_target - $name_target%{T-}"
    elif [ -n "$ip_target" ]; then
        echo "%{F#d11507}󰯐 %{F#ffffff}%{T6}$ip_target%{T-}"
    else
        echo "%{F#d11507}󰓾 %{u-}%{F#ffffff}%{T6}No target%{T-}"
    fi
else
    echo "%{F#d11507}󰓾 %{u-}%{F#ffffff}%{T6}No target%{T-}"
fi
