#!/usr/bin/env sh

nix flake update
echo -e " :: Done. Please run rebuild-sys.sh and rebuild-home.sh"
