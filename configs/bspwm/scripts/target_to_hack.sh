#!/bin/sh

ip_target=$(cat ~/.config/bin/target | awk '{print $1}')
name_target=$(cat ~/.config/bin/target | awk '{print $2}')

if [ $ip_target ] && [ $name_target ]; then
  echo "%{F#d11507}󰯐 %{F#ffffff}%{T6}$ip_target - $name_target%{T-}"
elif [ $(cat ~/.config/bin/target | wc -w) -eq 1 ]; then
  echo "%{F#d11507}󰯐 %{F#ffffff}%{T6}$ip_target%{T-}"
else
  echo "%{F#d11507}󰓾 %{u-}%{F#ffffff}%{T6}No target%{T-}"
fi
