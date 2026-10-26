# 2026-10-18 - Instalar opencode (brew) y revisar pi

## Resuelto y en pie

- **opencode declarado en brew**: se agregó `"opencode"` a `brews` en `configuration.nix`, después de `"node"`. Falta correr `./rebuild.sh` (lo corre el usuario) para que se instale.
- **Versión instalada será la 2.0.32**, no la 1.19.3 pedida. Es la que ofrece Homebrew y el usuario la eligió a sabiendas.
- **gemini-cli quitado de brew**: se borró `"gemini-cli"` de `brews` en `configuration.nix` a pedido del usuario. Seguía instalado (0.46.0); el rebuild lo desinstala por el `cleanup = "zap"`.
- **pi sin cambios**: ya estaba instalado como global de npm en fnm (`@earendil-works/pi-coding-agent@0.85.1`). El usuario decidió dejarlo así.

## Qué se probó y se descartó

- **Fijar opencode 1.19.3 de forma declarativa**: no se puede con brew (solo ofrece 2.0.32) ni con nixpkgs (trae otra versión, 1.18.x). La 1.19.3 sí existe en npm como `opencode-ai@1.19.3`.
- **Opciones que se ofrecieron y no se eligieron**: `npm i -g opencode-ai@1.19.3` (versión exacta pero fuera de Nix) y una derivación Nix propia con `fetchurl` y hash (reproducible pero con más mantenimiento).
- **pi por brew**: existe la fórmula `pi-coding-agent` (1.3.0, pi.dev), pero su numeración no coincide con la del paquete npm (0.85.1) y no se verificó que sea el mismo proyecto. No se declaró.

## Sin resolver

- Si de verdad hace falta la 1.19.3, habría que quitar la fórmula de brew y usar npm o la derivación Nix.
- pi sigue fuera de la config declarativa. Antes de pasarlo a brew conviene confirmar que `pi-coding-agent` de brew es el mismo proyecto que el de npm.
- Nunca se verificó con `opencode --version` tras el rebuild. Hasta ahora `which opencode` no lo encuentra, solo está declarado.
- Tras el rebuild confirmar también que `gemini-cli` desapareció (`brew list gemini-cli`).
