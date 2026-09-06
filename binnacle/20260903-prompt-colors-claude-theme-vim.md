# 2026-09-03 - Colores del prompt, theme de Claude Code, recurso de vim

## Resuelto y en pie

- **Colores del prompt de Starship** (tarea 6 del TODO): `programs.starship.settings` en `home.nix` recoloreado con la paleta de `atom-one-night-flat` (la misma que ya usan nvim/wezterm/herdr), en vez de los colores por defecto de Starship. `directory` azul `#4aa5f0`, `git_branch` magenta `#c162de`, `git_status` naranja `#d18f52`, `character` verde `#8cc265`/rojo `#e05561`, `cmd_duration` naranja `#d18f52`. Layout y módulos sin cambios, solo colores.
- **Recurso para aprender vim** (tarea 4 del TODO): [OpenVim](https://openvim.com/) - tutorial interactivo, 100% gratis y open source (MIT), corre en el navegador sin cuenta, más un [sandbox](https://openvim.com/sandbox.html) con ayuda contextual de comandos. Se descartó VimHero como alternativa porque parte de sus lecciones son pagas.

## Probado y revertido: hacer que la respuesta de Claude Code en la terminal se vea mejor (tarea 5 del TODO)

Queja puntual: el prompt del usuario y la respuesta de Claude Code no se ven del mismo "peso" visual (uno más vívido/blanco que el otro) - a diferencia de Warp, donde ambos se ven con el mismo blanco. Comparado con capturas de pantalla directas (WezTerm vs. Warp).

1. **Hipótesis 1 (descartada): dimming ANSI del lado del terminal.** Se asumió que WezTerm estaba aplicando su transform HSV de 50% de brillo a texto SGR "faint/dim" (confirmado que ese mecanismo existe, ver [discusión oficial de WezTerm](https://github.com/wezterm/wezterm/discussions/4026)), y se agregó `config.font_rules` en `wezterm.lua` fijando el peso de fuente `Regular` para `intensity = "Half"`. **No tuvo ningún efecto visible** - se revirtió. Conclusión: Claude Code no usa el atributo SGR faint para este texto, usa colores truecolor fijos por token semántico.
2. **Hipótesis 2 (descartada): elegir el theme correcto de Claude Code.** Investigado el sistema de themes de Claude Code (`/theme`, doc: https://code.claude.com/docs/en/terminal-config.md#match-the-color-theme). Presets: `dark`, `light`, `dark-daltonized`, `light-daltonized`, `dark-ansi`, `light-ansi`. Con `dark-ansi` la respuesta se veía apagada y el prompt vívido; con `dark` es al revés (el prompt ya enviado, en el historial, se ve apagado y la respuesta vívida). Ninguno da paridad.
3. **Hipótesis 3 (descartada): custom theme sobreescribiendo el token `inactive`.** Los themes custom van en `~/.claude/themes/<slug>.json` (`{"base": "dark", "overrides": {...}}`), documentados con tabla completa de tokens (`text`, `inactive`, `subtle`, etc. - `inactive` = "secondary text such as hints, timestamps, and disabled items", que es lo que más pinta como el elemento en cuestión). Se armó `home/.claude/themes/unified.json` con `overrides.inactive = "#e6e6e6"` y symlink en `home.nix` (mismo patrón que `.claude/skills`). Tras rebuild y reinicio de sesión, **no cambió nada visible**. O el token no es el correcto para ese elemento puntual (el historial de prompts ya enviados no está explícitamente listado en la referencia de tokens), o el reload no tomó bien el override.
4. **Confirmado en el camino**: `settings.json` SÍ soporta una key `"theme"` de forma declarativa (se comprobó viendo que `/theme` escribe directamente `"theme": "dark"` en el `home/.claude/settings.json` del repo, gracias a que está symlinkeado out-of-store) - dato útil para el futuro, aunque no está en la doc pública de settings-reference.

**Decisión**: se abandonó la tarea. Todo revertido - `home/.claude/settings.json` quedó en `"theme": "dark"`, sin carpeta `themes/`, sin `font_rules` en `wezterm.lua`.

## Pendiente para la próxima

- **Tarea 5 (Claude Code look)**: si se retoma, antes de adivinar `overrides` a ciegas, usar el editor interactivo de themes (`/theme` → `Ctrl+E` sobre un custom theme) para ver en vivo qué token corresponde exactamente al prompt-ya-enviado en el historial, en vez de asumir por el nombre/descripción de la tabla de tokens.
- **Tarea 3 (atajos de herdr y Neovim)**: para la próxima sesión, usar como referencia [folke/dot](https://github.com/folke/dot) y [craftzdog/dotfiles](https://github.com/craftzdog/dotfiles) (ambos en GitHub) - no arrancada todavía.
- Ver detalle completo de tareas pendientes en `TODO.md`.
