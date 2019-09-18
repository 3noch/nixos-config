{ pkgs, config, ... }@args: let

  me = "elliot";
  my-nixpkgs = import (config.users.users.${me}.home + "/cfg/dep/nixpkgs") {
    config = import ./nixpkgs-config.nix;
  };

in {
  imports = [ modules/keybase.nix ];

  programs.bash.enableCompletion = true;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    wget
    vim
  ];

  services.safeeyes.enable = false;

  users.users.${me}.packages = (with pkgs; [
    # STABLE PACKAGES
    pkgs.google-chrome
    git-crypt
    gnupg
    pinentry_qt5

  ]) ++ (with my-nixpkgs; [
    # USER-SPECIFIED NIXPKGS
    #haskellPackages-mine.twitch-cli
    atom
    borgbackup
    brave
    cabal-install
    cloc
    colordiff
    curl
    firefox
    fzf
    ghc
    gimp
    git
    gitAndTools.hub
    gitkraken
    gnugrep
    gnumake
    gzip
    #haskellPackages.intero
    haskellPackages.ghcid
    haskellPackages.hlint
    haskellPackages.stack
    #haskellPackages-mine.stylish-haskell
    htop
    imagemagick7
    inotify-tools
    jq
    kdiff3
    lastpass-cli
    less
    libreoffice
    #nix-prefetch-github
    nix-prefetch-scripts
    obelisk
    p7zip
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
    #wine
    xclip
    zip
    zoom-us

    # Fonts
    fira
    fira-code
    fira-mono
    inconsolata
  ]);

  virtualisation.virtualbox.host.enable = true;
  virtualisation.docker.enable = true;

  services.openssh.enable = true;

  programs.gnupg.agent = {
    enable = false;
    enableSSHSupport = true;
  };

  networking.firewall.allowedTCPPorts = [ 80 8000 8001 ];

  networking.hosts = {
  };

  services.udev.extraRules = ''
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="1b7c", MODE="0660", GROUP="users"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="2b7c", MODE="0660", GROUP="users"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="3b7c", MODE="0660", GROUP="users"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="4b7c", MODE="0660", GROUP="users"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="1807", MODE="0660", GROUP="users"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="1808", MODE="0660", GROUP="users"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="2c97", ATTRS{idProduct}=="0000", MODE="0660", GROUP="users"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="2c97", ATTRS{idProduct}=="0001", MODE="0660", GROUP="users"
  '';
}
