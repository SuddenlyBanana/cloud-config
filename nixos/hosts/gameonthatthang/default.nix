{ modulesPath, lib, ... }:

{

  imports =
    lib.optional (builtins.pathExists ./do-userdata.nix) ./do-userdata.nix
    ++ [ (modulesPath + "/virtualisation/digital-ocean-config.nix") ];

  time.timeZone = "Europe/Berlin";

  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 ];
    };
  };

  services.nginx = {
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

  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      purpurmc = {
        image = "docker.io/amazoncorretto:21-alpine-jdk";
        ports = [ "25565:25565" ];
        workdir = "/opt/";
        entrypoint = "./run.sh";
        volumes = [ "/srv/minecraft/purpur/:/opt/" ];
      };
    };
  };

}
