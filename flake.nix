{
  description = "A very basic flake";

  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    {
      overlays.default = final: prev: {
        python3 = prev.python3.override {
          packageOverrides = python-self: python-super: {
            inherit (self.packages.${final.system}) prjxray f4pga fasm f4pga-xc-fasm;
          };
        };
      };
    } // (
      flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
          };
        in
        {
          packages.f4pga = pkgs.python3.pkgs.callPackage ./packages/f4pga.nix { };
          packages.prjxray = pkgs.python3.pkgs.callPackage ./packages/prjxray.nix { };
          packages.fasm = pkgs.python3.pkgs.callPackage ./packages/fasm.nix { };
          packages.f4pga-xc-fasm = pkgs.python3.pkgs.callPackage ./packages/f4pga-xc-fasm.nix { };
          packages.update-all = pkgs.writeShellScriptBin "update-all" ''
            for p in f4pga prjxray fasm f4pga-xc-fasm; do
              ${nixpkgs.lib.getExe pkgs.nix-update} --version=branch --flake $p
            done
          '';

          app.default = self.packages.${system}.update-all;

          devShells.xc7 = pkgs.callPackage ./env/xc7.nix { };
          devShells.default = self.devShells.${system}.xc7;

          formatter = pkgs.nixpkgs-fmt;
        }));
}
