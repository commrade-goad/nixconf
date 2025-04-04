#!/usr/bin/env sh

p_command="wl-gammactl -c 0.935 -b 0.998 -g 0.806"
status=$(pidof wl-gammactl)

if [ -z "$status"]
then
    command $p_command &
    notify-send "wl-gammactl RESTARTED" -t 500 -a "System"
else
    pkill wl-gammactl
    command $p_command &
    notify-send "wl-gammactl RESTARTED" -t 500 -a "System"
fi
