# 2026-09-04 - Explorador de archivos en nvim: telescope-file-browser.nvim

## Resuelto y en pie

- **Sidebar de archivos (tarea 2 del TODO), retomada**: investigados `folke/dot` y `craftzdog/dotfiles` como referencia (repos reales de folke y craftzdog en GitHub, vía `gh api`/`gh search code`). Hallazgo clave: **ninguno de los dos usa un sidebar persistente**, y ninguno tiene autocmds `WinClosed` ni manejo especial de quit.
  - `folke/dot` (`nvim/lua/plugins/snacks.lua`) usa `Snacks.picker.explorer()` con `layout.preset = "sidebar"` - exactamente lo que ya se había probado y revertido acá por el problema del `:q` múltiple. Confirmado que folke tampoco lo resuelve de raíz, simplemente no le pega el mismo síntoma con su flujo.
  - `craftzdog/dotfiles` (`.config/nvim/lua/plugins/editor.lua`) usa **`telescope-file-browser.nvim`**, un picker flotante (no split), mapeado a `sf`, con `hijack_netrw = true`. Al ser flotante nunca queda como última "cosa" abierta al cerrar el archivo real, esquivando el problema de raíz.
- **Implementación**: agregado `telescope-file-browser.nvim` (+ `telescope.nvim` + `plenary.nvim`, esta última ya era dependencia de `lazygit.nvim`) en `nvim/lua/plugins/navigation.lua`, mapeado a `<leader>e` (libre, no chocaba con nada). Config calcada de craftzdog: `hidden = true`, `respect_gitignore = false`, `grouped = true`, `previewer = false`, `initial_mode = 'normal'`, `hijack_netrw = true`.
- **Verificación del fix de `:q`**: probado headless vía RPC (`nvim --headless --listen <pipe>` + `nvim --server <pipe> --remote-send/--remote-expr`), sin depender de tmux (no está instalado). Abrir el browser con `<leader>e`, cerrarlo con `<Esc>`, y `:q` sobre el archivo real cierra nvim de una - confirmado con `ps aux` (proceso ya no vivo tras un solo `:q`).
- **Ajuste de orden**: al probarlo, las carpetas aparecían pegadas abajo del todo y los archivos arriba - lo opuesto a lo esperado pese a `grouped = true`. Causa: `grouped` ordena carpetas primero en el orden *lógico*, pero el `sorting_strategy` default de telescope es `descending` (el prompt vive abajo y el primer resultado se pinta pegado al prompt), así que la lista se renderiza invertida en pantalla. Fix: agregado `sorting_strategy = 'ascending'` + `layout_config = { prompt_position = 'top' }` en `require('telescope').setup()` (aplica solo a telescope, que en esta config ya solo se usa para el file browser). Reverificado headless leyendo el buffer `TelescopeResults`: ahora carpetas arriba, archivos abajo, orden alfabético dentro de cada grupo.

## Pendiente para la próxima

- **Personalizar atajos de teclado dentro del file browser**: por ahora usa los defaults de `telescope-file-browser.nvim` sin revisar (crear/renombrar/mover/borrar archivos y carpetas). Fue lo único que quedó pendiente de esta sesión de personalización.
- Ver detalle completo de tareas pendientes en `TODO.md`.
