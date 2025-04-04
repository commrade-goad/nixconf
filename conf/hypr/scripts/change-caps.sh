#!/usr/bin/env sh

ARGS=$1
status=$(hyprctl getoption input:kb_options | head -n1 | awk '{print $2}')

if [ -z $ARGS ]
then
    exit
else
    case "$ARGS" in
        "-d")
            if [ -z $status ]
            then
                echo "esc -> esc"
            else
                echo "caps -> esc"
            fi
            ;;
        "-r")
            if [ -z $status ]
            then
                hyprctl keyword input:kb_options 'caps:swapescape'
                notify-send "Changed to CapsLock" -t 500
            else
                hyprctl keyword input:kb_options ''
                notify-send "Changed to Esc" -t 500
            fi
            ;;
        *)
            exit
            ;;
    esac
fi

