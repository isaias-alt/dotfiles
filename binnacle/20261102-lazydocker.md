# 2026-11-02 - Instalar lazydocker

## Hecho

- Se agregó `lazydocker` a `home.packages` en `home.nix`, junto a `delta`, con el comentario `docker TUI (talks to the colima daemon)`.
- Se puso en Nix y no en `brews` de `configuration.nix` porque es una CLI más del bloque de herramientas de `home.nix` (igual que `ripgrep`, `fd`, `eza`), y así se evita sumar otra entrada al Homebrew con `cleanup = "zap"`.
- No se ejecutó ningún comando: el rebuild lo corre el usuario.

## Qué se probó y se descartó

- Agregarlo a `brews` en `configuration.nix`: descartado, ver arriba.
- Usar el módulo `programs.lazydocker` de home-manager: descartado por ahora, no hay configuración propia que declarar; basta el paquete. Se puede cambiar a ese módulo si más adelante se quieren `settings` como en `programs.lazygit`.

## Sin resolver

- Falta el rebuild y verificar que `lazydocker` abre y ve los contenedores.
- Docker en este equipo corre sobre colima: hay que tener `colima start` activo antes de abrirlo. Si no encuentra el socket, puede hacer falta exportar `DOCKER_HOST` apuntando al socket de colima (`~/.colima/default/docker.sock`); no se probó.
