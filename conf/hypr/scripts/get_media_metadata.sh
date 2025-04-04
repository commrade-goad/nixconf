#!/usr/bin/env sh

MAX_LENGTH=45

program_names=$(playerctl metadata | grep -oP '^[^ ]+' | sort -u)

if [ -z "$program_names" ]; then
    exit 1
fi

first=1
for program in $program_names; do
    title=$(playerctl --player="$program" metadata xesam:title)
    artist=$(playerctl --player="$program" metadata xesam:artist)

    title=$(echo "$title" | cut -c 1-"$MAX_LENGTH")
    artist=$(echo "$artist" | cut -c 1-"$MAX_LENGTH")

    title="${title:-Unknown Title}"
    artist="${artist:-Unknown Artist}"

    echo -n "\"$title\" - $artist"
    if [ $first -eq 1 ]; then
        first=0
    else
        echo -n " && "
    fi
done

echo
