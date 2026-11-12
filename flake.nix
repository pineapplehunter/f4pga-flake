{
  description = "A reproducible F4PGA environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    systems.url = "github:nix-systems/default-linux";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    { flake-parts, ... }@inputs:
    let
      overlay =
        final: prev:
        let
          configuredF4pga =
            chip: family: archDef:
            final.callPackage ./packages/f4pga-configured.nix {
              name = "f4pga-${chip}";
              inherit family archDef;
            };
        in
        {
          yosys-f4pga = final.callPackage ./packages/yosys {
            yosys = final.yosys-f4pga;
          };
          pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
            (python-final: python-prev: {
              xc-fasm = python-final.callPackage ./python-packages/xc-fasm.nix { };
              qlf-fasm = python-final.callPackage ./python-packages/qlf-fasm.nix { };
              ql-fasm = python-final.callPackage ./python-packages/ql-fasm.nix { };
              ql-fasm-utils = python-final.callPackage ./python-packages/ql-fasm-utils.nix { };
              f4pga = python-final.callPackage ./python-packages/f4pga.nix {
                vtr = final.vtr-f4pga;
                yosys = final.yosys-f4pga;
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
          f4pga-xc7a35t = configuredF4pga "xc7a35t" "xc7" final.f4pga-arch-defs.xc7a50t_test;
          f4pga-xc7a50t = configuredF4pga "xc7a50t" "xc7" final.f4pga-arch-defs.xc7a50t_test;
          f4pga-xc7a100t = configuredF4pga "xc7a100t" "xc7" final.f4pga-arch-defs.xc7a100t_test;
          f4pga-xc7a200t = configuredF4pga "xc7a200t" "xc7" final.f4pga-arch-defs.xc7a200t_test;
          f4pga-xc7z010 = configuredF4pga "xc7z010" "xc7" final.f4pga-arch-defs.xc7z010_test;
          f4pga-eos-s3 = configuredF4pga "eos-s3" "eos-s3" final.f4pga-arch-defs.ql-eos-s3_wlcsp;
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
        let
          extraChecks = {
            eos-s3-bitstream = pkgs.callPackage ./tests/eos-s3-bitstream.nix { };
            xc7-bitstream-arty-a7-100t = pkgs.callPackage ./tests/xc7-bitstream.nix {
              configuredF4pga = pkgs.f4pga-xc7a100t;
              board = "arty-a7-100t";
              source = ./examples/arty-a7-100t;
            };
          };
        in
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [ overlay ];
          };

          packages = extraChecks // {
            tests-full = pkgs.linkFarm "f4pga-tests-full" (config.checks // extraChecks);

            arty-a7-100t-demo = pkgs.writeShellApplication {
              name = "arty-a7-100t-demo";
              runtimeInputs = [ pkgs.openfpgaloader ];
              text = ''
                exec openFPGALoader -b arty_a7_100t \
                  ${extraChecks.xc7-bitstream-arty-a7-100t}/top.bit
              '';
            };

            inherit (pkgs)
              f4pga
              f4pga-xc7a35t
              f4pga-xc7a50t
              f4pga-xc7a100t
              f4pga-xc7a200t
              f4pga-xc7z010
              f4pga-eos-s3
              prjxray-config
              prjxray-tools
              vtr-f4pga
              yosys-f4pga
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

          # Keep default CI limited to the XC7A35T architecture bundle.
          checks = {
            f4pga-packaging = pkgs.callPackage ./tests/f4pga-packaging.nix { };
            xc7-bitstream = pkgs.callPackage ./tests/xc7-bitstream.nix { };
          };

          formatter = pkgs.nixfmt-tree;

          legacyPackages = pkgs;
        };
    };
}
