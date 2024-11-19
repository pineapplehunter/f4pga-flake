{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    systems.url = "github:nix-systems/default";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      systems,
      treefmt-nix,
    }:
    let
      lib = nixpkgs.lib;
      eachSystem = lib.genAttrs (import systems);
      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };
    in
    {
      overlays.default = final: prev: {
        pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
          (python-final: python-prev: {
            xc-fasm = python-final.callPackage ./python-packages/xc-fasm.nix { };
            qlf-fasm = python-final.callPackage ./python-packages/qlf-fasm.nix { };
            ql-fasm = python-final.callPackage ./python-packages/ql-fasm.nix { };
            ql-fasm-utils = python-final.callPackage ./python-packages/ql-fasm-utils.nix { };
            f4pga = python-final.callPackage ./python-packages/f4pga.nix { };
            fasm = python-final.callPackage ./python-packages/fasm.nix { };
            prjxray = python-final.callPackage ./python-packages/prjxray.nix { };
            quicklogic-timings-importer =
              python-final.callPackage ./python-packages/quicklogic-timings-importer.nix
                { };
            tinyfpgab = python-final.callPackage ./python-packages/tinyfpgab.nix { };
          })
        ];
        prjxray-config = final.callPackage ./packages/prjxray-config.nix { };
        prjxray-tools = final.callPackage ./packages/prjxray-tools.nix { };
        vtr = final.callPackage ./packages/vtr { };
        f4pga-arch-defs = final.callPackages ./packages/f4pga-arch-defs.nix { };
        f4pga = final.python3Packages.toPythonApplication final.python3Packages.f4pga;
      };

      packages = eachSystem (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          inherit (pkgs)
            f4pga
            prjxray-config
            prjxray-tools
            vtr
            ;
          inherit (pkgs.python3.pkgs)
            fasm
            prjxray
            ql-fasm
            ql-fasm-utils
            qlf-fasm
            quicklogic-timings-importer
            tinyfpgab
            xc-fasm
            ;
        }
      );

      devShells = eachSystem (
        system:
        let
          pkgs = pkgsFor system;
        in
        rec {
          xc7 = pkgs.callPackage ./env/common.nix { family = "xc7"; };
          xc7a50t = pkgs.callPackage ./env/common.nix {
            family = "xc7";
            allDevices = false;
            enableXc7a50t = true;
          };
          xc7a100t = pkgs.callPackage ./env/common.nix {
            family = "xc7";
            allDevices = false;
            enableXc7a100t = true;
          };
          xc7a200t = pkgs.callPackage ./env/common.nix {
            family = "xc7";
            allDevices = false;
            enableXc7a200t = true;
          };
          xc7a010t = pkgs.callPackage ./env/common.nix {
            family = "xc7";
            allDevices = false;
            enableXc7a010t = true;
          };
          eos-s3 = pkgs.callPackage ./env/common.nix { family = "eos-s3"; };
          ql-eos-s3_wlcsp = pkgs.callPackage ./env/common.nix {
            family = "eos-s3";
            allDevices = false;
            enableQlEosS3Wlcsp = true;
          };
          default = xc7;
        }
      );

      formatter = eachSystem (
        system:
        (treefmt-nix.lib.evalModule (pkgsFor system) {
          projectRootFile = ./flake.nix;
          programs.nixfmt.enable = true;
        }).config.build.wrapper
      );

      legacyPackages = eachSystem pkgsFor;
    };
}
