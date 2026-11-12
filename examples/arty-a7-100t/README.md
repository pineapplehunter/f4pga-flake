# Arty A7-100T example

An LED blinker for the Arty A7-100T's `XC7A100TCSG324-1` FPGA. This example has been tested successfully on a physical Arty A7-100T board; it is not intended for the Arty A7-35T.

## Requirements

- Nix with flakes and the `nix-command` feature enabled on Linux.
- For programming: a powered Arty A7-100T connected with a USB data cable, and host access to its USB programmer.

Generating a bitstream does not require a board. No development shell or manual F4PGA environment setup is needed.

Run all commands below from this example directory (`examples/arty-a7-100t`). The commands use the toolchain published by `github:pineapplehunter/f4pga-flake`.

## Design and constraints

- [`top.v`](top.v) increments a 26-bit counter using the board's 100 MHz clock. The most significant bit drives the LED.
- [`arty-a7-100t.xdc`](arty-a7-100t.xdc) assigns `clk` to pin `E3` with a 10 ns period and `led` to pin `H5`, both using `LVCMOS33`.
- [`flow.json`](flow.json) selects the FPGA part, sources, constraints, build directory, and bitstream target.

## Generate the bitstream

```shell
nix run github:pineapplehunter/f4pga-flake#f4pga-xc7a100t -- build --flow flow.json
```

The first run downloads the toolchain and architecture data. The output file, relative to this example directory, is:

```text
build/arty-a7-100t/top.bit
```

Check that it exists and is nonempty:

```shell
test -s build/arty-a7-100t/top.bit && echo "Bitstream generated"
```

## Write the generated bitstream to the FPGA

Connect and power the board, then load the file you generated above using [openFPGALoader](https://github.com/trabucayre/openFPGALoader):

```shell
nix run nixpkgs#openfpgaloader -- \
  -b arty_a7_100t build/arty-a7-100t/top.bit
```

If openFPGALoader is already installed, the equivalent command is:

```shell
openFPGALoader -b arty_a7_100t build/arty-a7-100t/top.bit
```

These commands program **volatile FPGA memory**, not persistent configuration flash. The design is lost when power is removed. The LED connected to `H5` should blink after programming.

Run programming commands on the host with USB access. If access is denied on Linux, install the openFPGALoader udev rules for your system and reconnect the board; Nix downloading the program does not install host udev rules.

## Build and program in one command

Alternatively, build and program directly:

```shell
nix run github:pineapplehunter/f4pga-flake#arty-a7-100t-demo
```

This builds the example through Nix and invokes the packaged openFPGALoader. It loads the Nix-built bitstream, **not** the file in your local `build/` directory. It also programs volatile FPGA memory only.
