# TODO

1. ~~Al abrir nvim se repinta encima de la terminal base y las opacities se suman - molesto.~~ Resuelto: `text_background_opacity` bajado de 0.6 a 0.08 en wezterm.lua.
2. ~~Configurar la barra lateral de archivos y las pestañas en nvim, basándose en lo que tiene folke (LazyVim).~~ Resuelto: neo-tree.nvim (derecha) + bufferline.nvim.
   - Pendiente opcional: afinar detalles - los colores de neo-tree se ven mejor con tokyonight que con atom-one-darker. Probar un híbrido: colores de fondo/highlight (UI) de tokyonight combinados con los colores de sintaxis de código de atom-one, a ver si se puede lograr un punto medio sin cambiar el theme general.
   - Nuevo error encontrado: los highlights de los diffs (neogit/diffview) no se ven bien con atom-one-darker - el theme parece no estar tan refinado/completo como debería en esos grupos de highlight.
3. Configurar bien los atajos de teclado de herdr y de Neovim.
4. Buscar una página para aprender vim.
5. Hacer que la respuesta de Claude Code en la terminal se vea mejor.
6. Hacer que los colores de la cmd line (prompt) se vean mejor.
