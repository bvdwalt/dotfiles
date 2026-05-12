# Dotfiles Repository

This repository is for my personal use of storing and managing my dotfiles.

## Installation

This repository uses [Chezmoi](https://github.com/twpayne/chezmoi).

### Prerequisites

Install chezmoi for your platform first:

**macOS:**
```sh
brew install chezmoi
```

**Linux (Arch/CachyOS):**
```sh
sudo pacman -S chezmoi
```

**Linux (Fedora):**
```sh
sudo dnf install chezmoi
```

**Other systems:**
See [Chezmoi installation guide](https://www.chezmoi.io/install/)

### Apply Dotfiles

```sh
chezmoi init https://github.com/bvdwalt/dotfiles
chezmoi diff
chezmoi apply
```

### Updates

To update your dotfiles:

```sh
chezmoi update
```

## About

Dotfiles for cross-platform setup (macOS, Linux, Windows) including:
- Shell configuration (Fish, Zellij, Starship)
- Editor setup (Neovim with LazyVim)
- Development tools (Go, Git, etc.)
- Platform-specific packages and applications

Platform-specific installation scripts run automatically during `chezmoi apply`.

