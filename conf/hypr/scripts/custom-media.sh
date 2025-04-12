#!/usr/bin/env sh

empty="No media"

while :
do
    sleep 0.5
    status=$(playerctl status)

    if [ $? -eq 1 ]; then
        echo -e "$empty"
        continue
    fi

    title=$(playerctl metadata xesam:title)
    artist=$(playerctl metadata xesam:artist)

    title=$(echo "$title" | cut -c 1-"$MAX_LENGTH")
    artist=$(echo "$artist" | cut -c 1-"$MAX_LENGTH")

    status_msg="<i>[$status]</i> "

    msg="$status_msg $title - $artist"

    echo -e "$msg"
done
