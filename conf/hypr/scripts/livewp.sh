#!/usr/bin/env sh

# dependencies : mpvpaper socat

ARGS1=$1
PATHTOVID="$HOME/Videos/livewp/Ushio Noa.webm"

main () {
    case "$ARGS1" in
        "toggle") echo 'cycle pause' | socat - /tmp/mpv-socket
            ;;
        *) launch
            ;;
    esac
    exit
}

launch () {
    if [ -z "$(pidof mpvpaper)" ]
    then
        swww kill
        hyprctl dispatch exec "$HOME/git/mpvpaper/build/mpvpaper -o '--input-ipc-server=/tmp/mpv-socket --loop=inf --no-config --profile=fast --hwdec=vaapi --vo=gpu' eDP-1 \"$PATHTOVID\""
        exit
    else
        kill -9 $(pidof mpvpaper)
        hyprctl dispatch exec swww-daemon
    fi
    exit 1
}

main
