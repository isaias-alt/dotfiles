#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ln -sfn "$DIR" ~/.dotfiles

# sudo no hereda el PATH del usuario, así que se resuelve la ruta completa antes.
# Si nix-darwin nunca se activó, darwin-rebuild no existe todavía: se hace bootstrap con nix run.
if DARWIN_REBUILD="$(command -v darwin-rebuild)"; then
  exec sudo "$DARWIN_REBUILD" switch --flake ~/.dotfiles#mac
elif [ -x /run/current-system/sw/bin/darwin-rebuild ]; then
  exec sudo /run/current-system/sw/bin/darwin-rebuild switch --flake ~/.dotfiles#mac
else
  exec sudo nix run nix-darwin/nix-darwin-26.05#darwin-rebuild -- switch --flake ~/.dotfiles#mac
fi
