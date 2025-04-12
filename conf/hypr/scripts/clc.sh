PRETTY_NAME="caps-lock"
sleep 0.2
if [[ $# -gt 0 ]] then
    STATUS=$($HOME/.config/hypr/scripts/check-lock $1)
    if [[ "$1" = "-n" ]] then
        PRETTY_NAME="num-lock"
    fi
    notify-send "$PRETTY_NAME : $STATUS" -t 1000 -a "ruskey"
fi
