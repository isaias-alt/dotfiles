# 2026-09-06 - lazygit sin diff side-by-side ni fondos de color

## Resuelto

lazygit mostraba el diff de cada archivo en modo unificado (una sola columna) y, aunque el texto de las líneas +/- tenía color, el fondo de la línea no - solo el texto. El pedido: diff lado a lado (código viejo vs nuevo) con fondo rojo/verde completo por línea, como GitHub o delta, sin perder el side-by-side.

lazygit no tenía config propia (`~/Library/Application Support/lazygit/config.yml` no existía) - corría 100% con defaults, solo instalado como paquete suelto en `home.nix`.

### Callejones sin salida (en orden)

1. **`gui.splitDiff: always`**: el nombre sugería "split view" pero en realidad controla si el panel principal se divide en dos cuando un archivo tiene cambios *staged* y *unstaged* a la vez (arriba/abajo) - nada que ver con side-by-side de código viejo/nuevo. Confirmado leyendo `docs/Config.md` de lazygit. Sin efecto porque el archivo probado no tenía staged+unstaged simultáneos.
2. **`git.diffRenderers`** (siguiendo `docs/Custom_DiffRenderers.md` de la rama `master` de lazygit en GitHub): la key no existe en la versión instalada (0.61.1) - fue renombrada en una versión posterior a la instalada. lazygit ignoró la key silenciosamente, sin error. Lección: al buscar docs de una herramienta, verificar que correspondan a la versión instalada (`lazygit -c` imprime la config default real, útil para chequear qué keys existen de verdad) y no a `master`.
3. **`ydiff` como pager** (`git.pagers`, key correcta para 0.61.1 según `docs/Custom_Pagers.md` de ese mismo tag): logró side-by-side real, pero con dos problemas:
   - Con las flags default (`ydiff -p cat`) no hacía nada en absoluto cuando su salida no iba a un terminal interactivo - pasaba el diff crudo sin tocar. Hubo que forzar `-s -c always`.
   - Con `--wrap` partía palabras a la mitad sin criterio (wrap por cantidad de caracteres, no por palabra) - ej. "las" → "l"/"as", "opacity" → "opacit"/"y".
   - Más importante: confirmado leyendo el código fuente de `ydiff` que el coloreado es **intraline por diseño** (solo tiñe las palabras/caracteres que cambiaron dentro de la línea, vía `_word_diff()`) - nunca pinta el fondo completo de la línea. No hay flag ni tema que lo cambie. Esto era el pedido original (fondo completo tipo GitHub), así que `ydiff` quedó descartado para ese objetivo aunque el side-by-side funcionara bien.
4. **`delta` como pager, primer intento con `--width={{columnWidth}}`** (copiando el patrón del ejemplo oficial de `ydiff`): logró side-by-side + fondo completo de línea (confirmado insertando el diff a mano en un pipe no interactivo y leyendo los códigos ANSI crudos - el fondo se extiende con espacios de relleno hasta el ancho total), pero las columnas ocupaban solo ~1/4 del ancho del panel, con mucho espacio vacío sin usar.
   - Causa encontrada clonando el tag `v0.61.1` de lazygit y leyendo `pkg/config/pager_config.go`: `columnWidth` se calcula como `width/2 - 6`, pensado para herramientas donde ese valor es el ancho de **una sola columna** (como `ydiff`). `delta --width` en cambio espera el ancho **total** del side-by-side y lo vuelve a partir a la mitad internamente - de ahí que el resultado quedara a un cuarto del ancho real.
   - Mismo código fuente reveló algo más útil: lazygit corre el pager dentro de un **pty real** dimensionado exactamente al `view.InnerWidth()` del panel (`pkg/gui/pty.go`), con `TERM=dumb` en el entorno. Esto significa que `delta` puede auto-detectar el ancho correcto del panel por sí solo vía ioctl sobre ese pty - no hace falta pasarle ningún ancho manual. Se sacó `--width=...` del todo.
5. **`--wrap-max-lines=0`** (para evitar que `delta` partiera palabras a la mitad, mismo síntoma que con `ydiff`): en su momento parecía necesario, pero era un síntoma del bug de ancho de arriba (columnas a 1/4 del ancho real → líneas largas que no entraban → wrap agresivo). Una vez arreglado el ancho real (item 4), el wrap default de `delta` (`--wrap-max-lines` en 2, su valor default) ya no partía palabras de forma molesta - se sacó el override.

### Estado final

`home.nix`:
- `home.packages`: sacado `lazygit` como paquete suelto (ahora lo trae `programs.lazygit.enable`); agregado `delta` (se probó `ydiff` en el camino, descartado y sacado).
- Nuevo bloque:
  ```nix
  programs.lazygit = {
    enable = true;
    settings = {
      gui.sidePanelWidth = 0.2; # more room for the side-by-side diff
      git.pagers = [
        { colorArg = "never"; pager = "delta --side-by-side --dark --paging=never"; }
      ];
    };
  };
  ```

Nota operativa: la primera vez que se corrió `./rebuild.sh` con `programs.lazygit.enable`, home-manager se negó a pisar `~/Library/Application Support/lazygit/config.yml` porque ya existía (vacío, 0 bytes) y no estaba gestionado por home-manager - hubo que borrarlo a mano una vez antes de reintentar.

## Pendiente para la próxima

- Ver detalle completo de tareas pendientes en `TODO.md`.
