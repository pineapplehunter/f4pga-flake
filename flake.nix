{
  description = "A reproducible F4PGA environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-f4pga.url = "github:nixos/nixpkgs/5e4fbfb6b3de1aa2872b76d49fafc942626e2add";
    systems.url = "github:nix-systems/default-linux";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    { flake-parts, ... }@inputs:
    let
      overlay =
        final: prev:
        let
          f4pgaToolchain = import inputs.nixpkgs-f4pga {
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
          vtr-f4pga = final.callPackage ./packages/vtr {
            enableTbb = false;
            enableX11 = false;
          };
          f4pga-arch-defs = final.callPackages ./packages/f4pga-arch-defs.nix { };
          f4pga = final.python3Packages.toPythonApplication final.python3Packages.f4pga;
        };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      flake.overlays.default = overlay;

      perSystem =
        {
          config,
          pkgs,
          system,
          ...
        }:
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [ overlay ];
          };

          packages = {
            inherit (pkgs)
              f4pga
              prjxray-config
              prjxray-tools
              vtr-f4pga
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
          };

          checks = {
            xc7-bitstream = pkgs.callPackage ./tests/xc7-bitstream.nix { };
            xc7-bitstream-arty-a7-100t = pkgs.callPackage ./tests/xc7-bitstream.nix {
              archDef = pkgs.f4pga-arch-defs.xc7a100t_test;
              board = "arty-a7-100t";
              source = ./examples/arty-a7-100t;
            };
          }
          // config.packages;

          devShells = rec {
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
          };

          formatter = pkgs.nixfmt-tree;

          legacyPackages = pkgs;
        };
    };
}
