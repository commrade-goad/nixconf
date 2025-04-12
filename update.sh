#!/usr/bin/env sh

nix flake update
sudo nixos-rebuild switch --upgrade --flake ./#default
