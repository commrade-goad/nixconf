#!/usr/bin/env sh

STATUS=$(acpi | awk '{print $3}' | sed -e 's/,//g')
PERCENTAGE=$(acpi | awk '{print $4}' | sed -e 's/,//g' -e 's/[^0-9]//g')

if [[ $STATUS == "Discharging" ]]
then
    if [[ $PERCENTAGE -lt 35 ]]
    then
        LOGO="󰁼"
    elif [[ $PERCENTAGE -lt 60 ]]
    then
        LOGO="󰁾"
    else
        LOGO="󰁹"
    fi
else
    LOGO="󰂄"
fi

echo "$LOGO $PERCENTAGE%"

