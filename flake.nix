{
  description = "Nix Flake for ED-Outrider (Elite Dangerous companion and cockpit assistant)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    ed-outrider-src = {
      url = "github:weslocke/ED-Outrider";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      ed-outrider-src,
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgsFor = system: nixpkgs.legacyPackages.${system};
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = self.packages.${system}.ed-outrider;
          ed-outrider = pkgs.callPackage ./package.nix {
            src = ed-outrider-src;
          };
        }
      );

      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/ed-outrider";
          meta = {
            description = "Run ED-Outrider web server";
          };
        };
        overlay = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/ed-outrider-overlay";
          meta = {
            description = "Run ED-Outrider in-game overlay";
          };
        };
      });

      overlays.default = final: prev: {
        ed-outrider = self.packages.${prev.system}.ed-outrider;
      };
    };
}
