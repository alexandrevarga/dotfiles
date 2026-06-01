# ⌨️ Audited System Keybindings (DConf & Setup Telemetry)

## GNOME Window & Workspace Keybindings
* **Workspace Navigation:** `<Super>1-9` (Switch directly), `<Super><Alt>Left/Right` or `<Control><Alt>Left/Right` (Switch lateral).
* **Window Layout:** `<Super>Up` or `<Alt>F10` (Maximize), `<Super>Down` or `<Alt>F5` (Unmaximize), `<Super>h` (Minimize).
* **Window Placement:** `<Super><Shift>1-9` (Move window to workspace), `<Super><Shift>Arrows` (Move window between monitors).

## Application Launchers (Smart `switch-to-application` Focus Keybinds)
* **Ghostty Terminal (Workspace 1):** `<Super>Return` (or `<Super>Enter` via `switch-to-application-1`)
* **VS Code Insiders (Workspace 2):** `<Super>c` (via `switch-to-application-2`, opens `code-insiders`)
* **Floorp Browser (Workspace 3):** `<Super>b` (via `switch-to-application-3`, opens `floorp`)
* **Telegram Desktop (Workspace 5):** `<Super>t` (via `switch-to-application-4`, opens `telegram`)
* **Stremio Media Player (Workspace 7):** `<Super>s` (via `switch-to-application-7`, opens `stremio`)
* **EasyEffects Sound Suite (Workspace 8):** `<Super>e` (via `switch-to-application-8`, opens `easyeffects`)
* **Ulauncher Toggle:** `<Control>space` (or `<Primary>space` in dconf custom0)
* **Convert Clipboard Image to Path Script:** `<Super>i` (custom1, calls `~/.local/bin/img_to_path.sh`)

## SRE Safe Power Management (Zero-Accident Keybindings)
* **Suspend / Sleep (Safe):** `<Control>Pause` (custom2, calls `systemctl suspend`)
* **Hibernate (Safe):** `<Control><Shift>Pause` (custom3, calls `systemctl hibernate`)
* **Instant Reboot (Safe):** `<Control><Alt>Delete` (custom4, calls `systemctl reboot` - overrides default logout screen)
* **Instant Power Off (Safe):** `<Control><Alt>End` (custom5, calls `systemctl poweroff`)

## Tmux Audited Keybindings (Active .tmux.conf Setup)
* **Prefix Key:** `Ctrl+a` (`C-a` mapped, `Ctrl+b` unbound)
* **Pane Navigation (Alt-Direct, No Prefix Needed):** `Alt+Left` (Left), `Alt+Right` (Right), `Alt+Up` (Up), `Alt+Down` (Down).
* **Pane Splitting:** `Prefix + '` (Split vertical/columns), `Prefix + -` (Split horizontal/rows).
* **VI Copy Mode:** Mapped to `vi` keys. `v` in copy mode begins selection, `y` copies selection and cancels.
* **Config Reload:** `Prefix + r` (reloads config on the fly).
