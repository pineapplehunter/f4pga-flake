{
  description = "A very basic flake";

  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    let
      package-names = map
        (filename: nixpkgs.lib.strings.removeSuffix ".nix" filename)
        (builtins.attrNames (builtins.readDir ./packages));
    in
    {
      overlays.default = final: prev: {
        python3 = prev.python3.override {
          packageOverrides = python-self: python-super:
            let
              makePackage = name: {
                inherit name;
                value = python-self.callPackage ./packages/${name}.nix { };
              };
            in
            builtins.listToAttrs (map makePackage package-names);
        };
      };
      lib = nixpkgs.lib;
      inherit package-names;
    } // (
      flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
          };
        in
        {
          packages = {
            update-all = pkgs.writeShellScriptBin "update-all" ''
              for p in f4pga prjxray fasm f4pga-xc-fasm; do
                ${nixpkgs.lib.getExe pkgs.nix-update} --version=branch --flake $p
              done
            '';
          } //
          (builtins.listToAttrs (map
            (name: {
              inherit name;
              value = pkgs.python3.pkgs.${name};
            })
            package-names));

          apps.update = {
            type = "app";
            program = (nixpkgs.lib.getExe self.packages.${system}.update-all);
          };

          devShells = rec {
            xc7 = pkgs.callPackage ./env/xc7.nix { };
            default = xc7;
          };

          formatter = pkgs.nixpkgs-fmt;
        }));
}
