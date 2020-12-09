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

  nixpkgs.config.allowUnfree = true;
  nix = {
    binaryCachePublicKeys = [ ];
    binaryCaches = [ ];
  };

  time.timeZone = "America/New_York";

  environment.systemPackages = with pkgs; [
    wget
    vim
  ];

  location.latitude = 38.3303825;
  location.longitude = -85.7399543;

  users.users.${me} = {
    extraGroups = ["adbusers" "vboxusers"];

    packages = with my-nixpkgs; [
      binutils
      cachix
      cloc
      colordiff
      curl
      exa
      firefox-wayland
      gimp
      git
      gnugrep
      gnumake
      gzip
      htop
      imagemagick7
      inotify-tools
      jq
      less
      nix-prefetch-scripts
      psmisc
      rlwrap
      shellcheck
      signal-desktop
      spectacle
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
    ];
  };

  virtualisation = {
    docker.enable = true;
    virtualbox.host.enable = true;
  };

  programs = {
    adb.enable = true;
    bash.enableCompletion = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    steam.enable = true;
  };

  networking = {
    firewall.allowedTCPPorts = [ 80 ];
    hosts = {};
  };

  services = {
    openssh = {
      enable = true;
      passwordAuthentication = false;
    };
    ddclient = {
      enable = true;
      server = "freedns.afraid.org";
      protocol = "freedns";
      domains = [ "3noch.mooo.com" ];
    };
    udev.extraRules = ''
      # Rule for the Ergodox EZ Original / Shine / Glow
      SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="1307", GROUP="plugdev"
      # Rule for the Planck EZ Standard / Glow
      SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="6060", GROUP="plugdev"
    '';
    udev.packages = [
      pkgs.android-udev-rules
    ];
  };

  security.pam.enableSSHAgentAuth = true;

  hardware.ledger.enable = true;
}
