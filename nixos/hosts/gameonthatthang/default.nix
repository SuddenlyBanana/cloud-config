{ ... }:

{
  imports = [
    ./configuration.nix
  ];

  deployment = {
    buildOnTarget = true;
    targetHost = "gameonthatthang.online";
    targetUser = "admin";
  };
}