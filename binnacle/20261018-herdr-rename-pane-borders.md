# 2026-10-18 - Rename en herdr: era confusión de atajos, y nuevo switch_workspace

## Resuelto y en pie

- **Config sin cambios netos**: `home/.config/herdr/config.toml` quedó igual que antes. Se había agregado `pane_borders = "always"` y se quitó.
- **Nombre del pane quitado**: el label `dot` del pane de la sesión se borró con `herdr pane rename <id> --clear`.

- **Atajo para saltar entre workspaces**: se agregó `switch_workspace = "prefix+shift+1..9"` en `home/.config/herdr/config.toml`, para ir directo al workspace N con `ctrl+b` y `shift+N`. Salió de los comentarios de config del binario (`switch_workspace` es un binding indexado). `herdr config check` da ok y se recargó el servidor sin diagnósticos. `prefix+[` y `prefix+]` siguen igual. Confirmado por el usuario que funciona en la UI (`shift+1` no llega como `!`).

## Qué se probó y se descartó

- **Teoría inicial (errónea)**: el usuario dijo que `prefix+shift+p` "renombra el pane" y no cambiaba. Se asumió que con `pane_borders = "auto"` un pane solo no dibuja borde y por eso el nombre no se veía. El backend sí guarda el label (`herdr pane rename` y `herdr pane get` coinciden), pero no era el problema.
- **Corrección del usuario**: se refería a la pestaña (tab), no al pane. Los bordes de pane no afectan a las pestañas, así que el cambio no servía.
- Keybinds por defecto en el binario: `rename_pane = "prefix+shift+p"` y `rename_tab = "prefix+shift+t"`. El config del repo no pisa ninguno.
- `herdr tab rename <TAB_ID> <LABEL>...` no tiene `--clear` (el de panes sí).

## Aclaración final

No había bug: `prefix+shift+p` renombra el pane y `prefix+shift+t` la pestaña. El usuario creía que `shift+p` era para la pestaña. `prefix+shift+t` funciona. El PDF de shortcuts se regeneró con el skill `home:shortcuts-pdf` (solo cambió herdr: fila de `switch_workspace`; `reference.html` del skill actualizado).

## Sin resolver

- El nombre de la pestaña actual (`dotfiles`, `w1H:tD`) sigue como estaba.
