#!/usr/bin/env bash

export VISUAL=vim
export EDITOR="$VISUAL"

env_script_path=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

export NIX_CHANNEL_TRACK="nixpkgs-unstable"
export NIX_CHANNEL_REPO="$env_script_path/dep/nixpkgs"
export NIX_PATH="nixpkgs=$NIX_CHANNEL_REPO:$NIX_PATH"

export PATH="$env_script_path/bin":$PATH

function user-apply-config() {
  mkdir -p "$HOME/.config/nixpkgs"
  ln -sf "$env_script_path/nixpkgs-config.nix" "$HOME/.config/nixpkgs/config.nix"

  ln -sf "$env_script_path/tmux.conf" "$HOME/.tmux.conf"

  git config --global gpg.program gpg
}

function user-build() {
  source "${BASH_SOURCE[0]}" # Be sure to use the most recent version of this file.
  user-apply-config
}
