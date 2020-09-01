{ pkgs, config, ... }@args: let

  me = "elliot";
  my-nixpkgs = import (config.users.users.${me}.home + "/cfg/dep/nixpkgs") {
    config = import ./nixpkgs-config.nix;
  };

in {
  imports = [
    modules/secrets.nix
    modules/keybase.nix
  ];

  programs.bash.enableCompletion = true;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    wget
    vim
  ];

  location.latitude = 38.3303825;
  location.longitude = -85.7399543;

  services.safeeyes.enable = false;
  services.redshift.enable = true;

  users.users.${me} = {
    extraGroups = ["adbusers"];

    packages = (with pkgs; [
      # STABLE PACKAGES
      git-crypt
      gnupg
      pinentry_qt5
    ]) ++ (with my-nixpkgs; [
      # USER-SPECIFIED NIXPKGS
      atom
      binutils
      brave
      cabal-install
      cachix
      cloc
      colordiff
      curl
      exa
      firefox
      fzf
      ghc
      gimp
      git
      gitAndTools.hub
      gitkraken
      gnugrep
      gnumake
      google-chrome
      gzip
      haskellPackages.ghcid
      haskellPackages.hlint
      haskellPackages.stack
      htop
      imagemagick7
      inotify-tools
      jq
      kdiff3
      less
      libreoffice
      nix-prefetch-scripts
      obelisk
      psmisc
      rlwrap
      shellcheck
      signal-desktop
      spectacle
      steam
      thunderbird
      tmate
      tmux
      tree
      unzip
      vim
      vlc
      vscode
      wget

      xclip
      zip
      zoom-us

      # Fonts
      fira
      fira-code
      fira-mono
      inconsolata
    ]);

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOBLTwoPAfJVfzwwWObnUfmP8c/0ocNnrd63iqQ0ftdY elliot@Elliots-MacBook-Pro.local" # my MacBook Pro
    ];
  };

  # For Steam to work (https://nixos.org/nixpkgs/manual/#sec-steam-play)
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;
  hardware.steam-hardware.enable = true;

  virtualisation.virtualbox.host.enable = true;
  virtualisation.docker.enable = true;

  services.openssh.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.adb.enable = true;

  networking.firewall.allowedTCPPorts = [ 80 8000 8001 ];

  networking.hosts = {
  };

  services.ddclient = {
    enable = true;
    server = "freedns.afraid.org";
    protocol = "freedns";
    domains = [ "3noch.mooo.com" ];
  };

  hardware.ledger.enable = true;

  services.udev.extraRules = ''
    # Rule for the Ergodox EZ Original / Shine / Glow
    SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="1307", GROUP="plugdev"
    # Rule for the Planck EZ Standard / Glow
    SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="6060", GROUP="plugdev"
  '';
  services.udev.packages = [
    pkgs.android-udev-rules
  ];

  nix.binaryCachePublicKeys = [ "obsidian-tezos-kiln:WlSLNxlnEAdYvrwzxmNMTMrheSniCg6O4EhqCHsMvvo=" ];
  nix.binaryCaches = [ "https://s3.eu-west-3.amazonaws.com/tezos-nix-cache" ];
}
