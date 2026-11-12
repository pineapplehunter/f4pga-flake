# F4PGA environment in Nix

A reproducible Nix environment for building FPGA bitstreams with F4PGA.

- [Overview](#overview)
- [Supported targets](#supported-targets)
- [Quick start](#quick-start)
- [Arty A7-100T example](#arty-a7-100t-example)
  - [Design and constraints](#design-and-constraints)
  - [Generate the bitstream](#generate-the-bitstream)
  - [Program the FPGA](#program-the-fpga)
- [Development shells](#development-shells)
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

Enter the development shell for the target device and run the F4PGA flow:

```shell
nix develop .#xc7a100t
cd examples/arty-a7-100t
f4pga build --flow flow.json
```

The generated bitstream is written to:

```text
build/arty-a7-100t/top.bit
```

## Arty A7-100T example

The [`examples/arty-a7-100t`](examples/arty-a7-100t) directory contains a complete minimal design for the `XC7A100TCSG324-1` device.

This example has been tested successfully on a physical Arty A7-100T board. This confirms that sample on that board, not hardware validation of every supported target.

### Design and constraints

[`top.v`](examples/arty-a7-100t/top.v) implements a 26-bit counter. Its most significant bit drives an LED, producing a visible blink from the board's 100 MHz clock.

[`arty-a7-100t.xdc`](examples/arty-a7-100t/arty-a7-100t.xdc) assigns:

- `clk` to pin `E3` with a 10 ns clock period
- `led` to pin `H5`
- both signals to the `LVCMOS33` I/O standard

[`flow.json`](examples/arty-a7-100t/flow.json) selects the FPGA part, source files, constraints, output directory, and bitstream target used by F4PGA.

### Generate the bitstream

From the repository root:

```shell
nix develop .#xc7a100t
cd examples/arty-a7-100t
f4pga build --flow flow.json
```

A clean build of this small example takes approximately two minutes on a modern laptop, excluding the initial Nix downloads.

### Program the FPGA

To build and load the example in one command, connect and power the Arty A7-100T,
then run from the repository root:

```shell
nix run .#arty-a7-100t-demo
```

This uses the packaged bitstream and openFPGALoader to program volatile FPGA
memory, not configuration flash. The design is lost when power is removed.
Run it on the host with USB access; Linux may require openFPGALoader udev rules.

With [openFPGALoader](https://github.com/trabucayre/openFPGALoader) installed and the board connected, load the bitstream into volatile FPGA memory:

```shell
openFPGALoader -b arty_a7_100t build/arty-a7-100t/top.bit
```

The LED connected to `H5` should blink. Programming commands differ by device, board, programmer, and whether the design is loaded into volatile memory or persistent configuration flash.

## Development shells

Use the smallest shell matching the intended target:

| Shell | Target |
| --- | --- |
| `xc7` | All packaged Xilinx 7-series definitions |
| `xc7a50t` | XC7A35T/XC7A50T architecture bundle |
| `xc7a100t` | XC7A100T architecture data |
| `xc7a200t` | XC7A200T architecture data |
| `xc7a010t` | Packaged XC7Z010 architecture data |
| `eos-s3` | QuickLogic EOS S3 definitions |
| `ql-eos-s3_wlcsp` | QuickLogic EOS S3 WLCSP target |

Enter a shell with `nix develop .#<shell>`.

## Verification

Run all package builds and end-to-end checks with:

```shell
nix flake check -L
```

The checks include:

- `f4pga-packaging`: checks packaged-tool precedence, child Python environments, and Xilinx/QuickLogic command-line entry points without architecture downloads or hardware
- `xc7-bitstream`: generates a non-empty Arty A7-35T bitstream
- `xc7-bitstream-arty-a7-100t`: generates a non-empty bitstream from the Arty A7-100T example
- `eos-s3-bitstream`: generates a non-empty EOS S3 PD64 bitstream from a small combinational design; its pin constraints are a software test, not board wiring instructions

## Known limitations

- This project is experimental and primarily tested on `x86_64-linux`.
- F4PGA uses compatibility-pinned Yosys 0.47 (`yosys-f4pga`) and VTR source versions for the packaged architecture data. Both are built with the main `nixos-unstable` input's compiler and dependencies; no separate old nixpkgs input is needed.
- End-to-end bitstream checks cover Arty A7-35T, Arty A7-100T, and EOS S3 PD64, not every device/package. QLF-K4N8 has no packaged architecture bundle, and its `ql-qlf` plugin is not yet supported by this pinned toolchain.
- Package builds and bitstream generation are software validation, not confirmation that every board works. Hardware validation is separate and is not required to run the checks.
- Hardware programming tools are not included in the development shells.
- Device support and programming procedures vary; consult the board and tool documentation before programming hardware.
