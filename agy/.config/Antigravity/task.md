# Projetos de Engenharia e Resiliência (Tarefas Realizadas)

## 🩺 SRE Git History Surgery & Remote Synchronization
- `[x]` Execute git-filter-repo to obliterate leaked secrets from local git history.
- `[x]` Verify that the leaked paths are completely gone from the git tree.
- `[x]` Reconnect the remote `origin` to GitHub.
- `[x]` Perform the safe push to the `main` branch.

## 🛡️ SRE MCP Self-Healing & Persona Auto-Loader
- `[x]` Diagnose root cause of broken linux-mcp-server binary (system python upgrade).
- `[x]` Perform force reinstall of linux-mcp-server using uv.
- `[x]` Create a modular, background-running mcp-self-heal script with time locking (TTL).
- `[x]` Implement desktop notification support (notify-send) and audit logs.
- `[x]` Inject an async, disowned subshell hook in .zshrc to execute the self-heal process.
- `[x]` Apply Stow links for scripts and shell packages via targeted Makefile rules.
- `[x]` Stage, commit, and push self-healing code securely to GitHub.

## 🧠 SRE Master Persona Consolidation & Ergonomic Keybindings
- `[x]` Re-evaluate agy.md and merge essential triggers/rules from legacy GEMINI.md.
- `[x]` Map custom app launchers and GNOME favorite applications list.
- `[x]` Code ergonomic switch-to-application shortcut for Stremio (<Super>s) inside setup_keys.sh.
- `[x]` Deploy zero-accident power hotkeys (Ctrl+Pause, Ctrl+Shift+Pause, Ctrl+Alt+Delete, Ctrl+Alt+End).
- `[x]` Configure .gitignore exceptions to securely track agy.md while blocking private IDE states.
- `[x]` Apply Stow symlinks for scripts and cli packages.
- `[x]` Commit and push the master persona securely to GitHub.

## 📂 SRE GUI Settings Versioning
- `[x]` Restructure .gitignore directory traversal exceptions for the User/ folder.
- `[x]` Verify laser-precision tracking of settings.json while keeping private caches ignored.
- `[x]` Stage, commit, and push user GUI options safely to GitHub.

## 🎛️ Audiophile DSP & Phase-Coherent Pitch Shift (MPV + Stow)
- `[x]` Audit current PipeWire clock rate settings (verified locked at 48kHz, 1024 quantum).
- `[x]` Deep-dive psychoacoustic analysis of dithering interactions with EasyEffects Exciter/Crystalizer.
- `[x]` Import legacy MPV config files (`mpv.conf` and `input.conf`) and first-commit them to dotfiles.
- `[x]` Securely relocate and version Anime4K shaders to prevent any data loss.
- `[x]` Resolve redundant Stow absolute path symlink conflicts inside the `monitor/` module.
- `[x]` Deploy the new phase-coherent `mpv.conf` using pure 32-bit float pipelines and demands-only Soxr.
- `[x]` Execute GNU Stow deployment via Makefile and push final top-tier version to GitHub.
- `[x]` Fix and bypass YouTube bot detection (EJS "n challenge" failed) inside MPV by injecting Floorp Flatpak cookies database and forcing explicit Node.js runtime.

## 🚀 Cockpit Autostart & Login Automation (Gnome Session)
- `[x]` Identify system-level launcher files for target applications (Ghostty, VS Code Insiders, Floorp, EasyEffects).
- `[x]` Code clean, translation-free `.desktop` autostart entries inside `config-apps/.config/autostart/`.
- `[x]` Implement silent background boot parameter (`--gapplication-service`) for EasyEffects.
- `[x]` Execute GNU Stow deployment via Makefile to safely symlink entries inside the user's `~/.config/autostart/` folder.
- `[x]` Commit and push the cockpit autostart configurations safely to GitHub.
