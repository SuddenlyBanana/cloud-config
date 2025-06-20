{ modulesPath, lib, pkgs,  ... }:

{

  imports =
    lib.optional (builtins.pathExists ./do-userdata.nix) ./do-userdata.nix
    ++ [ (modulesPath + "/virtualisation/digital-ocean-config.nix") ];

  time.timeZone = "Europe/Berlin";

  environment.systemPackages = with pkgs; [ ferium ];

  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 ];
    };
  };

  services = {
    cockpit.settings.WebService.Origins = lib.mkForce
      "https://cockpit.gameontthatthang.online wss://cockpit.gameontthatthang.online";
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      virtualHosts = {
        "gameonthatthang.online www.gameonthatthang.online" = {
          forceSSL = true;
          sslCertificate = "/srv/web/gameonthatthang.online.pem";
          sslCertificateKey = "/srv/web/gameonthatthang.online.key";
          locations = {
            "/" = {
              tryFiles = "$uri $uri/ $uri.html =404";
              index = "index.html";
              root = "/srv/web/www";
            };
            "~* \\.(gif|jpg|png|webp)$" = { root = "/srv/web/images"; };
            "~* \\.(mp4|ogg|mp3)$" = { root = "/srv/web/media"; };
          };
        };
        "cockpit.gameonthatthang.online" = {
          forceSSL = true;
          sslCertificate = "/srv/web/gameonthatthang.online.pem";
          sslCertificateKey = "/srv/web/gameonthatthang.online.key";
          locations."/" = { proxyPass = "http://localhost:9090"; };
        };
      };
    };
  };

  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      minecraft-server = {
        image = "itzg/minecraft-server:java17-graalvm";
        environment = {
          EULA = "TRUE";
          MEMORY = "6G";
          USE_MEOWICE_FLAGS = "TRUE";
          TYPE = "QUILT";
          VERSION = "1.20.1";
        };
        ports = [ "25565:25565" ];
        volumes = [ "/srv/minecraft/minecraft-data:/data" ];
      };
    };
  };

}
