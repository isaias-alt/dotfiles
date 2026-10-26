# 2026-10-23 - `./rebuild.sh` falla con "darwin-rebuild: command not found"

## Resuelto y en pie

- **Síntoma**: `./rebuild.sh` termina con `sudo: darwin-rebuild: command not found`.
- **Diagnóstico**: `sudo` no hereda el PATH del usuario, y además en la máquina donde se investigó `/run/current-system` no existía, o sea que nix-darwin quizá nunca se activó y `darwin-rebuild` todavía no está instalado.
- **Cambio en `rebuild.sh`**: ahora resuelve la ruta completa de `darwin-rebuild` antes de llamar a `sudo`. Orden: `command -v darwin-rebuild`, luego `/run/current-system/sw/bin/darwin-rebuild`, y si ninguno existe hace bootstrap con `sudo nix run nix-darwin/nix-darwin-26.05#darwin-rebuild -- switch --flake ~/.dotfiles#mac` (misma rama que el input de `flake.nix`).
- El script no se ejecutó desde el agente: el rebuild lo corre el usuario.

## Qué se probó y se descartó

- **Solo dar el comando de bootstrap a mano**: se descartó como solución final porque el README promete que `./rebuild.sh` basta en una Mac nueva, y eso no se cumplía.
- **No se confirmó cuál de las dos causas era** (PATH de sudo o nix-darwin sin activar): se pidió la salida de `ls /run/current-system` y no llegó. El script cubre ambas.

## Sin resolver

- Correr `./rebuild.sh` y ver por cuál rama pasa. Si es el bootstrap, nix-darwin puede quejarse de archivos de `/etc` ya existentes (`/etc/zshrc`, `/etc/nix/nix.conf`); habría que renombrarlos a mano.
- El rebuild también aplicará los cambios pendientes de `configuration.nix` (opencode en brew, gemini-cli fuera). Seguir las verificaciones del binnacle del 2026-10-18.
- Si el bootstrap resulta ser el camino habitual en Macs nuevas, actualizar el README (paso 4) para mencionarlo.
