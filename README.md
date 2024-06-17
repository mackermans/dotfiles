# Nix system configuration for MacOS and NixOS

## Prerequisites

- [Nix](https://github.com/DeterminateSystems/nix-installer) 
- [Homebrew](https://brew.sh) (MacOS only)

## Install

- Clone this repository to `~/.dotfiles`

```sh
git clone git@github.com:mackermans/dotfiles.git ~/.dotfiles
```

### MacOS

```sh
nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake ~/.dotfiles#nix-darwin
```

```sh
chsh -s /run/current-system/sw/bin/fish
```

### NixOS

```sh
nix run nixos-rebuild --extra-experimental-features "nix-command flakes" -- switch --flake ~/.dotfiles#nixos
```

## Usage

Update your system configuration to the latest version:

```sh
nix-rebuild
``` 

```sh
nix-rollback
```
