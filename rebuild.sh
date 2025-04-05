#!/usr/bin/env sh

set -e

echo -e " * Diff :"
git diff HEAD

echo -e " * Rebuilding :"

if sudo nixos-rebuild switch --flake ./#default; then
    echo -n " * Enter commit message : "
    read msg
    if [ -z $msg ]; then
        exit
    fi

    git commit -a -m "$msg"
    echo -e " ** Commited with '$msg'"
fi
