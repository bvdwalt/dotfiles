# Dotfiles Repository

This repository is for my personal use of storing and managing my dotfiles. It includes configurations for:

- Zsh
- Aerospace Tiling Window Manager
- Sketchybar
- JankyBorders 

## Installation

This repository uses [Dotbot](https://github.com/anishathalye/dotbot) to manage the placement of dotfiles on the system. The configuration for Dotbot is specified in `install.conf.yaml`.

To install the dotfiles, run the following command:

```sh
./install
```

This will symlink the dotfiles to their appropriate locations as specified in `install.conf.yaml`.

## Structure

- `zsh` - Zsh configuration files
- `config/` - anyhing that goes in `~/.config/`
  - In this case, it's the configuration for Sketchybar, and JankyBorders