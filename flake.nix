{

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=25.05";
    colmena.url = "github:zhaofengli/colmena";
    nixos-generators.url = "github:nix-community/nixos-generators";
  };

  outputs = { nixpkgs, colmena, nixos-generators, ... }:
    let
      systemLinux = "x86_64-linux";
      systemDarwin = "x86_64-darwin";
      pkgsLinux = import nixpkgs { system = systemLinux; };
      pkgsDarwin = import nixpkgs { system = systemDarwin; };
    in {
      packages.x86_64-linux.do = nixos-generators.nixosGenerate {
        system = systemLinux;
        modules = [ ];
        format = "do";
      };

      # nix develop
      devShells.${systemDarwin}.default = pkgsDarwin.mkShell {
        nativeBuildInputs = [ colmena.defaultPackage.${systemDarwin} ];
      };

      devShells.${systemLinux}.default = pkgsLinux.mkShell {
        nativeBuildInputs = [ colmena.defaultPackage.${systemLinux} ];
      };

      colmenaHive = colmena.lib.makeHive {
        meta = { nixpkgs = pkgsLinux; };

        defaults = {
          imports = [ ./nixos/common ];

          deployment.buildOnTarget = true;
        };

        alpha = {
          imports = [ ./nixos/hosts/alpha ];

          deployment.targetHost = "134.122.91.58";
        };
      };
    };

}
