#!/usr/bin/env sh
HYPRGAMEMODE=$(hyprctl getoption animations:enabled | sed -n '1p' | awk '{print $2}')
if [ $HYPRGAMEMODE = 1 ] ; then
    hyprctl --batch "\
        keyword animations:enabled false;\
        keyword decoration:blur false;\
        keyword general:gaps_in 0;\
        keyword general:gaps_out 0;\
        keyword general:border_size 1;\
        keyword decoration:rounding 0"
    exit
fi
hyprctl reload
