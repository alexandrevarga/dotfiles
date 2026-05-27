# 🧠 DOTFILES ARCHITECTURE RULES & META-COGNITIVE PROTOCOL

This file defines the strict repository-specific rules for managing, refactoring, and orchestrating dotfiles inside `/home/alexandre/Projects/dotfiles/`.

## 1. TECHNICAL ENVIRONMENT CONSTRAINTS
- **Target OS:** Fedora 44 (Gnome 50.1 / Wayland native).
- **Core Terminal:** **Ghostty** (OpenGL accelerated) running on Workspace 1.
- **Ecosystem Stack Golden Rules:**
  - *Stow Workflow:* Dotfiles managed via GNU Stow in `~/Projects/dotfiles/`. NEVER edit paths directly in `~/.config/` or `~/.local/`. All edits go through this repository and Makefile orchestration.
  - *Tmux Prefix:* `Ctrl+a` (Ctrl+b is unbound).

## 2. SH-MODULE & SHELL ISOLATION RULES (ANTI-BLOAT)
- **Zshrc Integrity:** NEVER append long custom scripts, helper functions, or raw aliases directly to `.zshrc`.
- **Modular Sourcing:** Always isolate custom scripts into `scripts/` or `shell/` as standalone executables or modular source files (e.g., `~/.local/bin/`), then symlink via Stow and minimally load them in `.zshrc`.
- **DRY Principle:** Refuse duplicate configurations across different setups.

## 3. META-COGNITIVE REASONING PROTOCOL (SRP)
Before generating any code, file refactoring, or Stow layout modifications, Agy MUST execute a systemic pre-computation loop:

### Phase 1: Context & Collision Check
1. **Direct Path Check:** Verify that NO output file targets `~/.config` or `~/.local` directly. Ensure all write operations target the Stow repository structure.
2. **Keybinding Conflict Audit:** Check if any proposed bindings clash with GNOME's workspace bindings, applications switchers, or active tmux keymaps.
3. **Wayland Compliance:** Verify that all shell scripts use modern Wayland tools (`wl-copy` / `wl-paste` / Gnome CLI) instead of legacy X11 utilities (`xclip`).

### Phase 2: Structural Verification Plan
* Dry-run the Stow symlink behavior mentally. Ensure that writing to `/home/alexandre/Projects/dotfiles/config-apps/ghostty/config` correctly maps to `~/.config/ghostty/config` upon deploying `stow config-apps`.
