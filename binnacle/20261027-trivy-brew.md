# 2026-10-27 - Instalar trivy (brew)

## Resuelto y en pie

- **trivy declarado en brew**: se agregó `"trivy"` a `brews` en `configuration.nix`, entre `"tree-sitter-cli"` y `"zoxide"`. Falta correr el rebuild (lo corre el usuario) para que se instale.
- **Por qué en la config y no con `brew install trivy`**: con `homebrew.onActivation.cleanup = "zap"` el siguiente rebuild desinstalaría cualquier paquete que no esté declarado. Es una decisión deliberada del repo (ver `AGENTS.md`).

## Qué se probó y se descartó

- **`brew install trivy` a mano**: descartado, el `zap` lo borraría en el próximo rebuild.
- **trivy desde nixpkgs**: no se evaluó. Se siguió la convención del repo, que declara las herramientas de CLI en `brews`.

## Sin resolver

- Nunca se verificó la instalación. Tras el rebuild correr `trivy --version`.
