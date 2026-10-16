# 2026-10-15 - PATH de pnpm en home-manager y hook de bitácora

## Resuelto y en pie

- **Error de pnpm** (`The configured global bin directory ... is not in PATH`): `pnpm setup` no sirve aquí porque edita `~/.zshrc`, que home-manager genera y pisa en cada rebuild. El PATH se declara en `home.nix`:
  - `home.sessionVariables.PNPM_HOME = ~/Library/pnpm`.
  - `~/Library/pnpm/bin` en `home.sessionPath`. Con pnpm 10 o más reciente los binarios globales van en `$PNPM_HOME/bin`, y esa es la ruta exacta que pedía el error.
- **Nombre del paquete**: es `@nestjs/cli`, no `@nest/cli`.
- **Hook de bitácora** (`.claude/hooks/binnacle.sh`, cableado en `.claude/settings.json`):
  - `PostToolUse` sobre `Write|Edit` marca la sesión si el archivo editado está fuera de `binnacle/`.
  - `Stop` revisa la marca y, si existe, bloquea una vez pidiendo a Claude que escriba o actualice la entrada de `binnacle/`. `stop_hook_active` evita el bucle.
  - Probado con payloads sintéticos (6 casos), no visto disparar en vivo.

## Problema y su causa

Tras el rebuild y reiniciar WezTerm, `echo $PNPM_HOME` seguía vacío aunque el archivo generado (`hm-session-vars.sh`) ya traía las líneas nuevas.

Causa: `hm-session-vars.sh` empieza con un guard (`__HM_SESS_VARS_SOURCED`) y se salta todo si la variable ya viene en el entorno. Los shells heredaban ese entorno viejo del servidor de herdr, que seguía vivo desde antes del rebuild. Cerrar WezTerm no basta.

Comprobación: `unset __HM_SESS_VARS_SOURCED && source ~/.zshenv && echo $PNPM_HOME` imprimió la ruta. Arreglo permanente: cerrar herdr con su servidor y WezTerm con `Cmd+Q`, y abrirlos de nuevo. Confirmado por el usuario, `$PNPM_HOME` y el PATH ya correctos.

## Sin resolver

- **El hook solo ve `Write` y `Edit`**: lo que cambie por `Bash` (un `sed`, un rebuild) no marca nada.
- **Hook no visto en vivo**: si no dispara, abrir `/hooks` una vez o reiniciar Claude Code.
- **`pnpm i -g @nestjs/cli`** no se ha corrido todavía; solo se confirmó que el PATH ya incluye `pnpm/bin`.
- **Sin commitear a propósito**: `flake.lock` y `herdr/release-notes.json` tienen cambios que no son de esta sesión.
