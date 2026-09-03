# 2026-09-03 - Opacity de wezterm, theme y explorador de archivos en nvim

## Resuelto y en pie

- **Opacity de nvim en wezterm** (tarea 1 del TODO): `text_background_opacity` bajado de `0.6` a `0.08` en `wezterm.lua`. Antes, el fondo que pinta nvim se mezclaba dos veces (una vez con la transparencia de la ventana, otra con la de nvim), dejando el área de nvim visiblemente más opaca que el resto de la terminal ("las opacities se suman"). `0.0` eliminaba el problema del todo pero mataba el highlight de tab seleccionada de herdr y bajaba mucho el contraste de los fondos de color del prompt; `0.08` es el punto medio elegido.
- **Theme: tokyonight en vez de atom-one-darker**, en wezterm y nvim a la vez (`wezterm.lua` + `nvim/lua/plugins/colorscheme.lua`), porque se ve mejor con el explorador de archivos probado hoy y en general. `atom-one.nvim` queda instalado y lazy, disponible con `:colorscheme atom-one-darker` para volver cuando se refine.
- **`<Esc>` vuelve al default de vim**: ya no guarda (`:w`) ni saca de insert a la vez - antes esto generaba confusión al chocar con el flujo normal de guardar/salir. Guardar es `:w` normal.

## Probado y revertido: sidebar de archivos + tabs (tarea 2 del TODO)

Se intentó dos veces armar un layout tipo LazyVim (árbol de archivos a un costado + tabs de buffers arriba), inspirado en una captura del README de `folke/tokyonight.nvim` (que resultó ser vieja - folke ya no usa esa config).

1. **Intento 1: `neo-tree.nvim`** + `bufferline.nvim`. Se resolvieron varios problemas en el camino (choque de `H` con el atajo de cambiar de tab, netrw dejando un buffer roto al abrir un directorio, `:q` necesitando varios intentos para cerrar del todo), pero terminó siendo frágil - cada fix generaba un efecto secundario nuevo.
2. **Hallazgo**: revisando `folke/dot` (su dotfiles real), folke ya no usa `neo-tree.nvim` - migró a `Snacks.picker.explorer()`, el explorador integrado de `snacks.nvim` (que ya estaba instalado acá para el picker de archivos). Tiene una feature nativa (`explorer.replace_netrw`) que reemplaza netrw y limpia el buffer del directorio solo, mejor que cualquier parche manual.
3. **Intento 2: `Snacks.picker.explorer()`**. Mejoró varias cosas (menos plugins, manejo de netrw nativo), pero **el problema de fondo persistió**: el explorer es en realidad 2 ventanas (input + lista), y al cerrar el último archivo real, esas ventanas quedan solas y `:q` no cierra nvim de una - hacen falta varios intentos. No se encontró una forma confiable de arreglar esto con autocmds (`WinClosed` + chequeo de filetypes de todas las ventanas restantes tampoco alcanzó).

**Decisión**: se sacó todo - `neo-tree.nvim`, la config de explorer de snacks, y `bufferline.nvim` (las tabs, que sí andaban bien, pero se sacaron igual para volver a un estado limpio). La config de nvim quedó como estaba antes de esta tarea: solo el picker de snacks (`<leader>f` archivos, `<leader>s` grep, `<leader>b` buffers), sin sidebar visual ni tabs de buffers.

## Pendiente para la próxima

- **Retomar el sidebar de archivos**: antes de reintentar, investigar la causa raíz del problema de `:q` múltiple en vez de seguir parchando con autocmds - puede que la solución esté en cómo se cierra el picker/tree en sí (buscar si `snacks.nvim` o alguna alternativa tiene un modo "cerrar todo de una" ya resuelto), o evaluar `mini.files` como alternativa más simple.
- **Diffs sin colores** (neogit/diffview): con `atom-one-darker` no se ve rojo/verde en los diffs. `atom-one.nvim` sí define `DiffAdd`/`DiffChange`/`DiffDelete`/`DiffText` (`lua/atom-one/groups/base.lua:109-113`) con opacidad muy baja (~13-25%, `lua/atom-one/colors/darker.lua:57-62`) - puede ser eso, o que diffview use sus propios grupos de highlight que el theme no cubre. Sin confirmar todavía.
- **Afinar atom-one-darker vs tokyonight**: si se vuelve a atom-one-darker, evaluar un híbrido (fondos/highlights de tokyonight + sintaxis de atom-one) para no perder ninguno de los dos.
- Ver detalle completo de tareas pendientes en `TODO.md`.
