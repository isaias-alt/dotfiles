# dotfiles

Config reproducible de mi Mac: sistema, Homebrew, shell, terminal, editor y multiplexor, todo declarado acá y aplicado con Nix.

## Cómo reproducir esto en una Mac nueva

1. **Instalar Nix** (Determinate Nix Installer):

   ```bash
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

   Después de instalar, correr el comando que indica el instalador para refrescar el entorno (o simplemente abrir una terminal nueva).

2. **Clonar este repo**, en la ubicación que prefiera (no importa dónde, `rebuild.sh` se encarga de armar un alias estable):

   ```bash
   git clone <url-de-este-repo> ~/github/isaias-alt/dotfiles
   ```

3. **Revisar el usuario.** Todo acá asume que el usuario de macOS se llama `macuser`. Si la Mac nueva tiene otro nombre de usuario, hay que cambiarlo en 3 lugares antes del primer rebuild:
   - `flake.nix` → `user = "macuser";`
   - `configuration.nix` → `system.primaryUser` y `users.users.macuser`
   - `home.nix` → `home.username` y `home.homeDirectory`

   Si el usuario ya se llama `macuser`, no hay que tocar nada.

4. **Correr el rebuild:**

   ```bash
   cd ~/github/isaias-alt/dotfiles
   ./rebuild.sh
   ```

   Pide la contraseña de `sudo`. La primera vez tarda bastante (descarga e instala todo: nix-darwin, Homebrew vía nix-homebrew, home-manager). Repetir este mismo comando cada vez que se modifique algo acá.

## Qué instala/configura esto

- **Sistema (nix-darwin)**: preferencias de macOS (dark mode, key repeat, Finder, trackpad, menu bar, etc.) — `configuration.nix`.
- **Homebrew (nix-homebrew)**: se gestiona 100% declarativo. `cleanup = "zap"` borra en cada rebuild cualquier brew/cask que no esté listado en `configuration.nix` — si instalo algo nuevo con `brew install` y quiero que persista, tengo que agregarlo ahí.
- **Shell y herramientas de usuario (home-manager)** — `home.nix`:
  - zsh (autosuggestions, syntax highlighting, aliases), zoxide, Starship.
  - WezTerm, Neovim, herdr: config real vive en `home/.config/<app>/`, symlinkeada en vivo (los cambios ahí aplican sin rebuild).
  - `~/.claude/settings.json` y `~/.claude/CLAUDE.md`: config y reglas globales de Claude Code, también symlinkeadas desde `home/`.

## Reglas para agentes (Claude, etc.)

- `home/AGENTS.md`: reglas de comportamiento globales, se cargan en cualquier sesión (vía symlink a `~/.claude/CLAUDE.md`).
- `AGENTS.md` (acá en la raíz): notas puntuales de este repo, se cargan solo cuando trabajo en este proyecto.
