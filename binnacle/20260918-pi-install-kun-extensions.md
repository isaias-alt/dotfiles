# 2026-09-18 - instalación de Pi + extensiones de Kun

## Resuelto

Se instaló [Pi](https://pi.dev) (`@earendil-works/pi-coding-agent`, agent harness minimalista) y se replicó el patrón de configuración que usa Kun Chen en su propio repo (`github.com/kunchenguid/dotfiles`), fuente del tutorial que sigue este dotfiles.

- **Instalación del binario**: no hay fórmula de Homebrew para Pi. Se instaló vía npm (`npm install -g --ignore-scripts @earendil-works/pi-coding-agent`), corrido por el usuario, no declarado en `configuration.nix`/`home.nix` - igual que hace Kun, cuyo README dice explícitamente "Pi is an opt-in CLI, not a dependency this repository vendors". `node`/`pnpm` ya estaban en `brews`, así que no hizo falta tocar `configuration.nix`.
- **Extensiones vendored**: se trajeron ambas extensiones de Kun (`calm` y `terminal-status-title.js`) desde su repo vía `gh api`, preservando el LICENSE MIT de `calm`, a `home/.pi/agent/extensions/`.
- **`home.nix`**: se agregó el símlink `~/.pi/agent/extensions` → `home/.pi/agent/extensions` (mismo patrón `mkOutOfStoreSymlink` que el resto del repo).
- **AGENTS.md para Pi**: se investigó la doc de pi.dev - Pi carga instrucciones solo desde `AGENTS.md` (no `CLAUDE.md`, no soporta el `@import` de Claude Code) en `~/.pi/agent/`, directorios padre, y el cwd. Primer intento: símlink `~/.pi/agent/AGENTS.md` → `home/AGENTS.md` (el archivo compartido que ya usan `.claude/CLAUDE.md`, `.codex/AGENTS.md`, `.config/opencode/AGENTS.md`). El usuario corrigió esto: quería el archivo físicamente dentro de `home/.pi/agent/` (como Kun guarda `settings.json`/`models.json` ahí, sin indirección) aunque Kun en realidad nunca armó ese símlink específico para Pi en su propio repo. Quedó como copia física en `home/.pi/agent/AGENTS.md`, symlinkeada desde ahí - **nota: esto duplica el contenido de `home/AGENTS.md`, hay que actualizar ambos si cambia una regla global**.
- **Limpieza de skills sueltas**: al abrir la TUI de Pi aparecían dos skills inesperadas (`sanity-best-practices`, `sanity-migration`). Investigado: vivían en `~/.agents/skills/` (convención cross-agent separada de `~/.pi/`), instaladas el 2026-09-09 desde `sanity-io/agent-toolkit` para otra sesión de trabajo con Sanity, apuntando a una lista de agentes que no incluía `pi` - Pi las descubre igual porque escanea `~/.agents/skills/` por convención estándar, sin mirar esa lista. El usuario borró las carpetas (`rm -rf ~/.agents/skills/sanity-*`) y se limpiaron a mano las dos entradas correspondientes en `~/.agents/.skill-lock.json` (quedó `"skills": {}`).
- **Verificación E2E**: se corrió `pi` en la TUI - `[Context]` mostró `~/.pi/agent/AGENTS.md, AGENTS.md` (global + el del proyecto) y `[Extensions]` mostró `calm, terminal-status-title.js`, ambos cargando correctamente. Warning de "No models available" es esperado - falta correr `/login` para autenticar un provider.
- **Commit**: `f557c52` - "Add Pi coding agent extensions and AGENTS.md symlink". Se dejó afuera `home/.config/herdr/release-notes.json` (cambio previo sin relación).

## Pendiente para la próxima

- Correr `/login` dentro de Pi para autenticar un provider (Anthropic/OpenAI/etc.) - sin esto Pi no tiene modelos disponibles.
- `home/.config/herdr/release-notes.json` sigue modificado y sin commitear, sin relación con esta sesión - revisar aparte.
- Si el duplicado de `AGENTS.md` (`home/AGENTS.md` vs `home/.pi/agent/AGENTS.md`) genera drift, evaluar volver al esquema de archivo único compartido.
- Ver detalle completo de tareas pendientes en `TODO.md`.
