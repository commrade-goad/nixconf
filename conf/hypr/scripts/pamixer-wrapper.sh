#!/usr/bin/env sh

mode=$1
if [ "$mode" = "raise" ]; then
    pamixer -i 5
    volume=$(pamixer --get-volume)
    notify-send -t 500 "Vol: $volume%"
elif [ "$mode" = "lower" ]; then
    pamixer -d 5
    volume=$(pamixer --get-volume)
    notify-send -t 500 "Vol: $volume%"
elif [ "$mode" = "toggle" ]; then
    pamixer -t
    ismute=$(pamixer --get-mute)
    usestr="Muted"
    if [ $ismute = false ]; then
        usestr="Unmuted"
    fi
    notify-send -t 500 "Vol: $usestr"
fi
