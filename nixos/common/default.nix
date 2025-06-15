{ pkgs, ... }:

{

  system.stateVersion = "25.05";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    wget
    curl
    btop
    podman-tui
    podman-compose
    dive
  ];

  programs = {
    fish.enable = true;
    neovim = {
      enable = true;
      defaultEditor = true;
    };
  };

  services.cockpit = {
    enable = true;
    openFirewall = true;
  };

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  users = {
    mutableUsers = false;
    users.admin = {
      isNormalUser = true;
      home = "/home/admin";
      description = "Admin account";
      extraGroups = [ "wheel" "networkmanager" ];
      shell = pkgs.fish;
      hashedPassword =
        "$y$j9T$CnOTMLorqOJnw//dnpUQm/$X5E7HuLvzPwNnqnjTJ/YVr73kDrke4DRxxnGkmMSvd4";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICRIhWo+MoCKC9ON917x42Go2kj3HAe15HOq1aRx2MsO niko@bazzite"
      ];
    };
  };

  security.sudo.extraRules = [{
    users = [ "admin" ];
    commands = [{
      command = "ALL";
      options = [ "SETENV" "NOPASSWD" ];
    }];
  }];

}
