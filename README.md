# Dotfiles Repository

This repository is for my personal use of storing and managing my dotfiles. 

## Installation

This repository uses [Chezmoi](https://github.com/twpayne/chezmoi).

To apply all of the dotfiles run the following:

```sh
chezmoi diff
chezmoi apply
```

This will symlink the dotfiles to their appropriate locations as specified in `install.conf.yaml`.

## Structure

- `zsh` - Zsh configuration files
- `config/` - anyhing that goes in `~/.config/`
  - In this case, it's the configuration for Sketchybar, and JankyBorders
