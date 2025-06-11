{ pkgs, ... }:

{
  system.stateVersion = "25.05";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [ wget curl ];

  programs = {
    fish.enable = true;
    neovim.enable = true;
  };

  virtualisation.podman.enable = true;
}
