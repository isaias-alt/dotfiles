#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
nix flake update --flake "$DIR"
exec "$DIR/rebuild.sh"
