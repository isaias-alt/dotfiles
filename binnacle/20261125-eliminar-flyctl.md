# 2026-11-25 - Eliminar flyctl y revisar estado de vexillum en este repo

## Resuelto y en pie

- **Fly.io CLI (`configuration.nix`)**: se quitó `"flyctl"` de `brews`. Con `homebrew.onActivation.cleanup = "zap"`, el próximo `./rebuild.sh` desinstala `flyctl`.
- **Residuos locales de Fly.io**: se eliminó `~/.fly` (`~/.config/fly` no existía).
- **Vexillum (`vx`) en este repositorio**: se verificó que `dotfiles` no tiene inicialización ni archivos propios de `vx` en `AGENTS.md`, `.claude/`, `.gitignore`, hooks, worktrees ni dentro de `~/.vexillum/projects/` (coincide con `20261101-herdr-app-tema-atom-brillo.md`, donde `vx-dev doctor` ya marcaba el repo como no inicializado). La instalación global de `vexillum` en la laptop (`configuration.nix` y `lsp.lua`) se mantiene intacta.

## Qué se probó y se descartó

- **Quitar `vexillum` de `configuration.nix`, `lsp.lua` y `home/.claude/settings.json`**: revertido tras aclarar que el objetivo era solo dejar de usar `vx` en este repositorio, no desinstalarlo de la laptop (con `cleanup = "zap"`, quitarlo de `configuration.nix` lo habría desinstalado del equipo).

## Sin resolver

- Falta correr `./rebuild.sh` para desinstalar el binario de `flyctl` vía Homebrew.
