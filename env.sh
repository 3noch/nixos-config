#!/usr/bin/env bash

# Based on https://github.com/grafted-in/dev-onboarding/blob/master/env.sh

export VISUAL=vim
export EDITOR="$VISUAL"

export NIX_CHANNEL_TRACK="nixpkgs-unstable"
export NIX_CHANNEL_REPO="$HOME/nixpkgs"
export NIX_PATH="nixpkgs=$NIX_CHANNEL_REPO:$NIX_PATH"

env_script_path=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

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
  echo inotify-tools
  echo jq
  echo kdiff3
  echo keybase
  echo keybase-gui
  echo lastpass-cli
  echo less
  echo libreoffice
  echo nix-prefetch-scripts
  echo p7zip
  echo psmisc
  echo shellcheck
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
  cat <<NIX
{
  allowUnfree = true;

  packageOverrides = pkgs: {
    haskellPackages-mine = pkgs.haskellPackages.override {
      overrides = self: super: {
        #haskell-src-exts-HEAD = self.callCabal2nix "haskell-src-exts" (pkgs.fetchFromGitHub {
        #  owner  = "haskell-suite";
        #  repo   = "haskell-src-exts";
        #  rev    = "935f6f0915e89c314b686bdbdc6980c72335ba3c";
        #  sha256 = "1v3c1bd5q07qncqfbikvs8h3r4dr500blm5xv3b4jqqv69f0iam9";
        #}) {};
        #haskell-src-exts = self.haskell-src-exts-HEAD;

        #hlint = super.hlint.overrideAttrs (_: { haskell-src-exts = self.haskell-src-exts-HEAD; });
        #stylish-haskell = super.stylish-haskell.overrideAttrs (_: { haskell-src-exts = self.haskell-src-exts-HEAD; });

        twitch-cli = self.callCabal2nix "twitch-cli" (pkgs.fetchFromGitHub {
          owner  = "grafted-in";
          repo   = "twitch-cli";
          rev    = "85047186c3790ab8f015bdc4658abfe63c6129b7";
          sha256 = "1yr53r3h0p12dj2cyc3j6r71nyf0g93x1xbra9205f6qp3ymc205";
        }) {};

        #intero = pkgs.haskell.lib.dontCheck super.intero;
        #stylish-haskell = pkgs.haskell.lib.doJailbreak super.stylish-haskell;
      };
    };
  };
}
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

