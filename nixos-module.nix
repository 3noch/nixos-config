{ pkgs, config, ... }@args: let

  me = "elliot";
  my-nixpkgs = import (config.users.users.${me}.home + "/cfg/dep/nixpkgs") {
    config = import ./nixpkgs-config.nix;
  };

in {
  imports = [
    modules/secrets.nix
    modules/vpn.nix
    #modules/keybase.nix
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
      file
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
      nix-index
      nix-prefetch-scripts
      nodejs-12_x # for vscode remote manual patching not to get GC'ed
      psmisc
      rlwrap
      shellcheck
      signal-desktop
      teams
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

      # Gnome extensions
      gnomeExtensions.appindicator
      gnomeExtensions.arc-menu
      # gnomeExtensions.battery-status # not needed
      gnomeExtensions.caffeine
      gnomeExtensions.clipboard-indicator
      gnomeExtensions.dash-to-dock
      gnomeExtensions.dash-to-panel
      gnomeExtensions.draw-on-your-screen
      gnomeExtensions.drop-down-terminal
      gnomeExtensions.emoji-selector
      # gnomeExtensions.gsconnect
      # gnomeExtensions.icon-hider # buggy reviews
      gnomeExtensions.impatience
      # gnomeExtensions.mediaplayer # deprecated
      gnomeExtensions.mpris-indicator-button
      gnomeExtensions.night-theme-switcher
      # gnomeExtensions.no-title-bar
      # gnomeExtensions.nohotcorner # removed
      # gnomeExtensions.paperwm
      # gnomeExtensions.pidgin-im-integration
      gnomeExtensions.remove-dropdown-arrows
      gnomeExtensions.sound-output-device-chooser
      gnomeExtensions.system-monitor
      gnomeExtensions.taskwhisperer
      gnomeExtensions.tilingnome
      gnomeExtensions.timepp
      gnomeExtensions.topicons-plus
      gnomeExtensions.window-corner-preview
      gnomeExtensions.window-is-ready-remover
      gnomeExtensions.workspace-matrix
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
