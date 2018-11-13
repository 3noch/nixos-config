{ pkgs, ... }: {
  imports = [ modules/keybase.nix ];

  programs.bash.enableCompletion = true;

  nixpkgs.config.allowUnfree = true;
  
  environment.systemPackages = with pkgs; [
    wget
    vim
  ];

  virtualisation.virtualbox.host.enable = true;
  virtualisation.docker.enable = true;

  services.openssh.enable = true;

  networking.firewall.allowedTCPPorts = [ 80 8000 8001 ];
}
