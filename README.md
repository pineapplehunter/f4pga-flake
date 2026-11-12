# F4PGA in Nix

Reproducible, per-chip Nix packages for building FPGA bitstreams with F4PGA.

- [Overview](#overview)
- [Supported targets](#supported-targets)
- [Quick start](#quick-start)
- [Arty A7-100T example](#arty-a7-100t-example)
- [Configured packages](#configured-packages)
- [Verification](#verification)
- [Known limitations](#known-limitations)

## Overview

This is an **unofficial, independently maintained, and vibe-coded project**. It is not affiliated with or endorsed by the F4PGA project. Treat it as experimental and review the package definitions before relying on it for critical work.

[F4PGA](https://f4pga.org/) is an open-source FPGA toolchain framework. It connects tools such as Yosys, VPR, and device-specific projects to synthesize, place, route, and generate bitstreams. This repository packages a compatible set of those tools and architecture definitions through Nix.

## Supported targets

The packaged architecture data covers:

- Xilinx 7-series devices
- QuickLogic EOS S3 devices
- Arty A7-35T and Arty A7-100T end-to-end example builds

The F4PGA package includes Xilinx and QuickLogic runtime tools by default. Architecture bundles are currently provided for the families listed above; other upstream targets need matching architecture data and tool/plugin compatibility checks.

Software checks can generate bitstreams without a physical board. They do not establish that a bitstream works on hardware, and not every device or board in a family has been tested.

## Quick start

Run the package for the target chip directly; no development shell or environment setup is needed. From the repository root:

```shell
cd examples/arty-a7-100t
nix run github:pineapplehunter/f4pga-flake#f4pga-xc7a100t -- -v build --flow flow.json
```

The generated bitstream is written to:

```text
build/arty-a7-100t/top.bit
```

## Arty A7-100T example

This LED-blinker example for the `XC7A100TCSG324-1` device has been tested successfully on a physical Arty A7-100T board. This does not imply hardware validation of other targets.

See the [example directory](examples/arty-a7-100t/README.md) for more information on how to use this, including generating the bitstream and programming the board.

## Configured packages

Each package wraps the shared F4PGA toolchain with the chip's architecture data and sets `FPGA_FAM`, `F4PGA_INSTALL_DIR`, `F4PGA_TIMESTAMP`, and `F4PGA_HASH` automatically.

| Package | Target |
| --- | --- |
| `f4pga-xc7a35t` | XC7A35T, using the shared XC7A35T/XC7A50T bundle |
| `f4pga-xc7a50t` | XC7A50T, using the shared XC7A35T/XC7A50T bundle |
| `f4pga-xc7a100t` | XC7A100T |
| `f4pga-xc7a200t` | XC7A200T |
| `f4pga-xc7z010` | XC7Z010 |
| `f4pga-eos-s3` | QuickLogic EOS S3, using the packaged `ql-eos-s3_wlcsp` bundle |

Use `nix run <flake>#<package> -- -v build --flow flow.json` from your project directory. Arguments are passed unchanged to F4PGA. Your flow still specifies the FPGA part/package, sources, and constraints; the launcher does not supply board pin assignments or change the selected part.

There are no family-wide launchers or development shells. The unconfigured `f4pga` package remains available for custom integrations that supply their own architecture data and environment.

## Verification

### Default CI suite

```shell
nix flake check -L
```

Normal CI builds only these checks and their dependencies, not every exported package:

- `f4pga-packaging`: checks packaged-tool precedence, child Python environments, and Xilinx/QuickLogic command-line entry points without architecture downloads or hardware
- `xc7-bitstream`: generates a non-empty Arty A7-35T bitstream using the shared XC7A35T/XC7A50T bundle

This does not download the XC7A100T, XC7A200T, XC7Z010, or EOS S3 architecture bundles. Flake evaluation still validates all package definitions.

### Full suite (opt-in)

```shell
nix build --no-link -L .#tests-full
```

The full suite includes both CI checks plus these additional bitstream checks and their architecture downloads:

- `xc7-bitstream-arty-a7-100t`: generates a non-empty bitstream from the Arty A7-100T example
- `eos-s3-bitstream`: checks EOS S3 PD64 bitstream generation from a small combinational design; its pin constraints are a software test, not board wiring instructions

Run either additional check individually with `nix build --no-link -L .#<check-name>`. The full suite covers all existing bitstream tests, not every packaged chip. To run it in GitHub Actions, manually dispatch the CI workflow with `full_tests` enabled.

The EOS S3 check currently fails because the packaged `qlfasm` version lacks the `--dev-type` option expected by F4PGA; the full suite will fail until that compatibility issue is fixed.

## Known limitations

- This project is experimental and primarily tested on `x86_64-linux`.
- F4PGA uses compatibility-pinned Yosys 0.47 (`yosys-f4pga`) and VTR source versions for the packaged architecture data. Both are built with the main `nixos-unstable` input's compiler and dependencies; no separate old nixpkgs input is needed.
- End-to-end bitstream checks cover Arty A7-35T, Arty A7-100T, and EOS S3 PD64, not every device/package. QLF-K4N8 has no packaged architecture bundle, and its `ql-qlf` plugin is not yet supported by this pinned toolchain.
- Package builds and bitstream generation are software validation, not confirmation that every board works. Hardware validation is separate and is not required to run the checks.
- Chip launchers generate bitstreams; they do not include hardware programming tools. The separate `arty-a7-100t-demo` command includes openFPGALoader.
- Device support and programming procedures vary; consult the board and tool documentation before programming hardware.
