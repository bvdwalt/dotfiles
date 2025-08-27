# Dotfiles Repository

This repository is for my personal use of storing and managing my dotfiles. 

## Installation

This repository uses [Chezmoi](https://github.com/twpayne/chezmoi).

To apply all of the dotfiles run the following:

```sh
set working_tree (chezmoi data | jq -r '.chezmoi.workingTree')
gh repo clone bvdwalt/dotfiles $working_tree
chezmoi diff
chezmoi apply
```
or just run to apply without showing the difference first
```sh
chezmoi update
```
