#!/usr/bin/env sh

mode=$1
if [ "$mode" = "raise" ]; then
    brightnessctl s 5%+
elif [ "$mode" = "lower" ]; then
    brightnessctl s 5%-
fi
brightness=$(brightnessctl g)
percent=$(( brightness * 100 / 255 ))
notify-send -t 500 "Bri: $percent%"
