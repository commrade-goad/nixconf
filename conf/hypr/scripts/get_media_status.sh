#!/usr/bin/env sh

status=$(playerctl status)
program_names=$(playerctl metadata | grep -oP '^[^ ]+' | sort -u)

if [ -z "$program_names" ]; then
    exit 1
fi

first=1
for program in $program_names; do
    program_status=$(playerctl --player="$program" status)
    echo -n "${program^^} Currently $program_status"

    if [ $first -eq 1 ]; then
        first=0
    else
        echo -n " && "
    fi
done

echo
