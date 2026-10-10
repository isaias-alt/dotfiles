# 2026-10-10 - Tema solarized-osaka, colores de terminal, limpieza de Obsidian y LSP de Tailwind

## Resuelto y en pie

- **Obsidian fuera**: se borró `nvim/lua/plugins/obsidian.lua`, su entrada en `lazy-lock.json` y la sección en `home/.claude/skills/shortcuts-pdf/reference.html`. El vault `~/Desktop/Ideaverse` no se tocó. `Lazy! sync` limpió el plugin instalado.
- **Preview de imágenes fuera**: se quitó `image = { enabled = true }` de snacks en `navigation.lua` (junto con el atajo `<leader>i`, que vivía en el archivo de obsidian).
- **Plugins de nvim actualizados** con `nvim --headless "+Lazy! sync" +qa` (gitsigns, lazygit, mason-lspconfig, nvim-autopairs, nvim-lspconfig, nvim-treesitter, onedarkpro, smear-cursor). Ojo: `timeout` no existe en macOS.
- **Tema actual: solarized-osaka** en nvim, WezTerm y Claude Code (pasó antes por tokyonight, que también quedó probado).
  - nvim: `solarized-osaka.nvim` carga al arrancar con `transparent = true`. `tokyonight` y `atom-one` quedan lazy (`:colorscheme <nombre>`).
  - WezTerm: `color_scheme = "Solarized Osaka"`, usando una copia del tema oficial del plugin en `wezterm/colors/solarized-osaka.toml`.
  - Claude Code: `home/.claude/themes/solarized-osaka.json` y `"theme": "custom:solarized-osaka"`.
  - Starship: colores del prompt en `home.nix` pasados a la paleta solarized (necesita rebuild).
  - herdr: sin cambios, sigue a WezTerm con `theme = "terminal"`.

## Problemas de color y su causa

Dos síntomas distintos con la misma raíz: **el color 8 de la paleta ANSI** (`brights[0]`).

1. **Brillo de las respuestas de Claude Code** (ver `20260906-claude-code-vividness-wezterm.md`): el `foreground` del colorscheme se perdió al cambiar de tema. En solarized-osaka era `#839395`; se subió a `#e6e6e6`, igual que la vez anterior.
2. **Autocompletado de zsh casi negro**: zsh-autosuggestions pinta el ghost text con el color 8. En solarized-osaka `brights[0]` era `#001419`, idéntico al fondo. En atom-one y tokyonight era un gris visible (`#4f5666`, `#414868`).
3. **Nombre del pane seleccionado en herdr ilegible** (gris sobre azul): al "arreglar" el punto 2 subiendo `brights[0]` a `#657b83`, herdr (con `theme = "terminal"`) usa ese mismo color para el texto sobre la pestaña azul. Hipótesis confirmada por el usuario después de revertir.

**Intento descartado**: dejar `brights[0]` en `#001419` y darle al autocompletado un color explícito (`programs.zsh.autosuggestion.highlight = "fg=#657b83"` en `home.nix`). Al usuario no le gustó esa variable, así que se quitó.

**Fix final**: desacoplar las dos cosas por el lado de herdr. `brights[0] = "#657b83"` (autocompletado visible) y, en `herdr/config.toml`, `[theme.custom] surface_dim = "#001419"` para que el texto de la pestaña activa siga oscuro sobre el azul. La doc de herdr no dice qué token pinta ese texto, así que `surface_dim` fue una prueba; el usuario confirmó que funciona. Si se rompe, los siguientes candidatos eran `surface0` y `overlay0`. Se aplica con `herdr server reload-config`.

Detalle útil: WezTerm no recarga al editar archivos de `colors/`, solo `wezterm.lua`. Si un cambio de colorscheme no se ve, hay que cerrar y abrir WezTerm.

## LSP, Tailwind y autocompletado

- **Hallazgo**: `mason-lspconfig` tiene `automatic_enable` activo por defecto, así que activaba todo lo instalado en Mason aunque no estuviera en la lista `servers` de `lsp.lua`. Quedaron activos `tailwindcss`, `eslint`, `biome` y `dockerls` (restos de mayo, de una config anterior). Verificado con `vim.lsp.is_enabled`.
- **Aviso tipo VS Code** (`max-w-[480px]` -> `max-w-120`): es la regla `tailwindCSS.lint.suggestCanonicalClasses` del servidor (v0.14.29, `warning` por defecto). Probado en `~/github/kinexa/nutrione/nutrione-web` (Next 16, React 19, Tailwind 4) con un buffer en memoria, sin escribir nada: salieron `max-w-[480px]` -> `max-w-120`, `p-[16px]` -> `p-4` y `cssConflict` entre `text-red-500` y `text-blue-500`.
- **Cambios en `lsp.lua`**:
  - `automatic_enable = false` y `vim.lsp.enable(servers)`: solo corre lo declarado.
  - Agregados a `servers`: `tailwindcss`, `eslint`, `emmet_language_server` (este último instalado en Mason).
  - Atajo nuevo `<leader>a` (normal y visual) para `vim.lsp.buf.code_action`, que aplica el fix de la clase.
- **Verificado**: tras el cambio quedan activos `tailwindcss`, `eslint`, `ts_ls`, `cssls`, `emmet_language_server`; apagados `biome` y `dockerls`.

## Sin resolver

- **Errores falsos en un proyecto de Next**: en `nutrione-web` no se reprodujeron. El archivo real probado solo dio 3 `WARN` del plugin de Next sobre props de funciones en un componente `"use client"` (código 71007), que VS Code también muestra. Sospecha original: `eslint`/`biome` activándose sin config; el cambio de `automatic_enable` debería cubrirlo. Si vuelve, hace falta el mensaje exacto y el archivo.
- **No probado interactivamente**: el atajo `<leader>a` y emmet en un nvim real (solo se verificó que los servidores quedan activos y que el aviso existe).
- **Faltan vs VS Code**: ordenar clases de Tailwind (plugin de Prettier, fuera del LSP) y preview de color de las clases.
- **PDF de atajos** sin regenerar (falta `<leader>a`).
- **Commit y rebuild** de nix-darwin pendientes (los corre el usuario): Starship y el symlink del tema de Claude dependen del rebuild, que además quita la variable de zsh del autocompletado.
