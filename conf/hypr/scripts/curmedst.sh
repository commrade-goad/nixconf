#!/usr/bin/env sh

STATUS=$(playerctl status)

if [[ $STATUS == "" ]]
then
    echo "No Media playing."
else
    echo "Currently $STATUS"
fi

