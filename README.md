# Dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Requirements
- GNU Stow

## Structure
- `cli/`: Command-line tools configurations
- `config-apps/`: GUI application configurations
- `easyeffects/`: EasyEffects audio presets
- `monitor/`: Display and monitor settings
- `scripts/`: Custom utility scripts
- `shell/`: Shell configurations
- `theme/`: System themes and appearance

## Management

This repository uses a `Makefile` to orchestrate GNU Stow.

### Install All
To link all packages to your home directory:
```bash
make all
```

### Install Specific Package
To link a specific package (e.g., shell):
```bash
make shell
```

### Uninstall (Clean)
To remove all symlinks created by this repository:
```bash
make clean
```
