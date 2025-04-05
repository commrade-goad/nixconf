#!/usr/bin/env sh

# TODO add support to update flake lock file with the command below.
# nix flake update

sudo nixos-rebuild switch --upgrade --flake ./#default
