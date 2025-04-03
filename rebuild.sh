#!/usr/bin/env sh

set -xe

echo -e "Diff :"
git diff HEAD~

echo -e "Rebuilding:"

if sudo nixos-rebuild switch --flake ./#default; then
    read msg
    git commit -a -m "$msg"
    echo -e "Commited with '$msg'"
fi
