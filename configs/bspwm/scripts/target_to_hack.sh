#!/bin/sh

TARGET_FILE="$HOME/.config/bin/target"

# Verificamos si el archivo existe y leemos su contenido de un solo golpe
if [ -f "$TARGET_FILE" ]; then
    read -r ip_target name_target < "$TARGET_FILE"

    if [ -n "$ip_target" ] && [ -n "$name_target" ]; then
        echo "%{F#d11507}󰯐 %{F#ffffff}$ip_target - $name_target"
    elif [ -n "$ip_target" ]; then
        echo "%{F#d11507}󰯐 %{F#ffffff}$ip_target"
    else
        echo "%{F#d11507}󰓾 %{F#ffffff}No target"
    fi
else
    echo "%{F#d11507}󰓾 %{F#ffffff}No target"
fi
