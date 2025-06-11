{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=25.05";
    colmena.url = "github:zhaofengli/colmena";
    nixos-generators.url = "github:nix-community/nixos-generators";
  };

  outputs = { self, nixpkgs, colmena, nixos-generators, ... }:
    let
      pkgsLinux = import nixpkgs { system = "x86_64-linux"; };
      pkgsDarwin = import nixpkgs { system = "x86_64-darwin"; };
    in
    {
      packages.x86_64-linux.do = nixos-generators.nixosGenerate {
        system = "x86_64-linux";
        modules = [ ];
        format = "do";
      };

      # nix develop
      devShells."x86_64-darwin".default = pkgsDarwin.mkShell {
        buildInputs = [
          colmena
        ];
      };

      colmenaHive = colmena.lib.makeHive {
        meta = {
          nixpkgs = pkgsLinux;
        };

        defaults = import ./nixos/common;

        alpha = import ./nixos/hosts/gameonthatthang;
      };
    };
}
