{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-f4pga.url = "github:nixos/nixpkgs/5e4fbfb6b3de1aa2872b76d49fafc942626e2add";
    systems.url = "github:nix-systems/default-linux";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-f4pga,
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
      overlays.default =
        final: prev:
        let
          f4pgaToolchain = import nixpkgs-f4pga {
            system = final.stdenv.hostPlatform.system;
          };
        in
        {
          pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
            (python-final: python-prev: {
              xc-fasm = python-final.callPackage ./python-packages/xc-fasm.nix { };
              qlf-fasm = python-final.callPackage ./python-packages/qlf-fasm.nix { };
              ql-fasm = python-final.callPackage ./python-packages/ql-fasm.nix { };
              ql-fasm-utils = python-final.callPackage ./python-packages/ql-fasm-utils.nix { };
              f4pga = python-final.callPackage ./python-packages/f4pga.nix {
                vtr = final.vtr-f4pga;
                yosys = f4pgaToolchain.yosys;
              };
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
          vtr-f4pga =
            (final.vtr.override {
              enableTbb = false;
              enableX11 = false;
            }).overrideAttrs
              (
                finalAttrs: previousAttrs: {
                  pname = "vtr-f4pga";
                  version = "8.0.0-5699-g25e723a24";
                  src = final.fetchFromGitHub {
                    owner = "verilog-to-routing";
                    repo = "vtr-verilog-to-routing";
                    rev = "25e723a24aa0ae7a0061cd89dd84b1fb62afcc09";
                    hash = "sha256-q3J89TiwrqsUHs0/H4cBMMDx2Xya8uiXndsUPti5DkA=";
                    fetchSubmodules = true;
                  };
                }
              );
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

      checks = eachSystem (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          vtr-no-gui = self.packages.${system}.vtr.override { enableX11 = false; };
          xc7-bitstream = pkgs.callPackage ./tests/xc7-bitstream.nix { };
        }
        // self.packages.${system}
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
          projectRootFile = "flake.nix";
          programs.nixfmt.enable = true;
        }).config.build.wrapper
      );

      legacyPackages = eachSystem pkgsFor;
    };
}
