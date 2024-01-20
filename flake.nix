{
  description = "A very basic flake";

  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    {
      overlays.default =
        final: prev: {
          python3 = prev.python3.override {
            packageOverrides = python-self: python-super: {
              xc-fasm = python-self.callPackage ./python-packages/xc-fasm.nix { };
              qlf-fasm = python-self.callPackage ./python-packages/qlf-fasm.nix { };
              ql-fasm = python-self.callPackage ./python-packages/ql-fasm.nix { };
              ql-fasm-utils = python-self.callPackage ./python-packages/ql-fasm-utils.nix { };
              f4pga = python-self.callPackage ./python-packages/f4pga.nix { };
              fasm = python-self.callPackage ./python-packages/fasm.nix { };
              prjxray = python-self.callPackage ./python-packages/prjxray.nix { };
              quicklogic-timings-importer = python-self.callPackage ./python-packages/quicklogic-timings-importer.nix { };
              tinyfpgab = python-self.callPackage ./python-packages/tinyfpgab.nix { };
            };
          };
          prjxray-config = final.callPackage ./packages/prjxray-config.nix { };
          prjxray-tools = final.callPackage ./packages/prjxray-tools.nix { };
          vtr = final.callPackage ./packages/vtr { };
          f4pga-arch-defs = final.callPackages ./packages/f4pga-arch-defs.nix { };
        };
      lib = nixpkgs.lib;
    } // (
      flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
          };
          lib = nixpkgs.lib;
        in
        {
          packages = {
            inherit (pkgs) prjxray-config prjxray-tools vtr f4pga-arch-defs;
            inherit (pkgs.python3.pkgs) f4pga xc-fasm qlf-fasm fasm prjxray quicklogic-timings-importer tinyfpgab;



            update-all = pkgs.writeShellScriptBin "update-all" ''
              for p in f4pga xc-fasm ql-fasm ql-fasm-utils qlf-fasm fasm prjxray prjxray-config prjxray-tools vtr quicklogic-timings-importer tinyfpgab; do
                ${lib.getExe pkgs.nix-update} --version=branch --flake $p
              done
            '';
          };

          apps.update = {
            type = "app";
            program = lib.getExe self.packages.${system}.update-all;
          };

          devShells = rec {
            xc7 = pkgs.callPackage ./env/xc7.nix { };
            xc7a50t = pkgs.callPackage ./env/xc7.nix { allDevices = false; enableXc7a50t = true; };
            xc7a100t = pkgs.callPackage ./env/xc7.nix { allDevices = false; enableXc7a100t = true; };
            xc7a200t = pkgs.callPackage ./env/xc7.nix { allDevices = false; enableXc7a200t = true; };
            xc7a010t = pkgs.callPackage ./env/xc7.nix { allDevices = false; enableXc7a010t = true; };
            default = xc7;
          };

          formatter = pkgs.nixpkgs-fmt;
        }));
}
