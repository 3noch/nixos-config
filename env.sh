#!/usr/bin/env bash

# Based on https://github.com/grafted-in/dev-onboarding/blob/master/env.sh

export VISUAL=vim
export EDITOR="$VISUAL"

export NIX_CHANNEL_TRACK="nixpkgs-unstable"
export NIX_CHANNEL_REPO="$HOME/nixpkgs"
export NIX_PATH="nixpkgs=$NIX_CHANNEL_REPO:$NIX_PATH"

env_script_path=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

export PATH="$env_script_path/bin":$PATH

function user-packages() {
  #echo haskellPackages-mine.hlint
  #echo haskellPackages-mine.stylish-haskell
  #echo haskellPackages-mine.twitch-cli
  echo atom
  echo borgbackup
  echo cabal-install
  echo cloc
  echo colordiff
  echo curl
  echo fzf
  echo ghc
  echo gimp
  echo git
  echo git-crypt
  echo gitAndTools.hub
  echo gitkraken
  echo gnugrep
  echo gnumake
  echo gnupg
  echo google-chrome
  echo gzip
  echo haskellPackages-mine.intero
  echo haskellPackages.ghcid
  echo haskellPackages.hlint
  echo haskellPackages.stack
  echo haskellPackages.stylish-haskell
  echo htop
  echo imagemagick7
  echo inotify-tools
  echo jq
  echo kdiff3
  echo lastpass-cli
  echo less
  echo libreoffice
  #echo nix-prefetch-github
  echo nix-prefetch-scripts
  echo obelisk
  echo p7zip
  echo psmisc
  echo shellcheck
  echo signal-desktop
  echo spectacle
  echo steam
  echo thunderbird
  echo tmate
  echo tmux
  echo tree
  echo unzip
  echo vim
  echo vlc
  echo vscode
  echo wget
  echo wine
  echo xclip
  echo zip
  echo zoom-us

  # Fonts
  echo fira
  echo fira-code
  echo fira-mono
  echo inconsolata
}

function vscode-extensions() {
  #echo Vans.haskero
  echo azemoh.one-monokai
  echo bbenoist.Nix
  echo hoovercj.haskell-linter
  echo jcanero.hoogle-vscode
  echo justusadam.language-haskell
  echo timonwong.shellcheck
  echo vigoo.stylish-haskell
  echo zjhmale.idris
}


function user-nix-config() {
  mkdir -p "$HOME/.config/nixpkgs"
  cat > "$HOME/.config/nixpkgs/config.nix" <<NIX
import "$env_script_path/nixpkgs-config.nix"
NIX
}

function user-apply-vscode-config() {
  mkdir -p "$HOME/.config/Code/User"
  cp -r "$env_script_path/vscode"/* "$HOME/.config/Code/User"

  for ext in $(vscode-extensions); do
    code --install-extension "$ext"
  done
}

function user-apply-tmux-config() {
  cat > "$HOME/.tmux.conf" <<TMUX
set -g mouse on
# to enable mouse scroll, see https://github.com/tmux/tmux/issues/145#issuecomment-150736967
bind -n WheelUpPane if-shell -F -t = "#{mouse_any_flag}" "send-keys -M" "if -Ft= '#{pane_in_mode}' 'send-keys -M' 'copy-mode -e'"
TMUX
}

function user-apply-app-config() {
  # Stack can't install its own GHC on NixOS
  stack config set system-ghc --global true

  git config --global gpg.program gpg

  user-apply-tmux-config
  user-apply-vscode-config
}

function user-init-channel() {
  if [ ! -d "$NIX_CHANNEL_REPO" ]; then
    nix-shell -p git --run "git clone https://github.com/nixos/nixpkgs.git ""$NIX_CHANNEL_REPO"" && git -C ""$NIX_CHANNEL_REPO"" checkout ""$(get-latest-channel-hash)"""
  fi
}

function user-upgrade-channel() {
  user-init-channel
  nix-shell -p git --run "git -C ""$NIX_CHANNEL_REPO"" checkout ""$(get-latest-channel-hash)"""
}

function get-latest-channel-hash() {
  curl -sL "https://nixos.org/channels/$NIX_CHANNEL_TRACK/git-revision"
}

function user-build() {
  source "${BASH_SOURCE[0]}" # Be sure to use the most recent version of this file.

  # Apply the nixpkgs channel
  user-init-channel

  # Apply nixpkgs config
  mkdir -p "$HOME/.config/nixpkgs"
  user-nix-config > "$HOME/.config/nixpkgs/config.nix"

  # Apply packages
  nix-env -f '<nixpkgs>' --remove-all -iA $(user-packages)

  # Idris stuff from https://d3g5gsiof5omrk.cloudfront.net/nixos/unstable/nixos-18.09pre143771.a8c71037e04/nixexprs.tar.xz
  #nix-env -i \
  #  /nix/store/q99rl8mw63dplj7hbf973n9aszxilx93-idris-1.3.0.drv \
  #  /nix/store/nh67av50k1p803cwpxzmamar6zz646ni-idringen-0.1.0.3.drv

  # Apply various configurations
  user-apply-app-config
}

function clear-nix-cache {
  # Sometimes the cache for pre-built binaries is out of date.
  sudo rm /nix/var/nix/binary-cache-v3.sqlite*
}

function nix-build-closure-size {
  du -sch "$(nix-store -qR "$(nix-build "$@" --no-out-link)")"
}

