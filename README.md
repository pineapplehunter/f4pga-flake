# F4PGA environment in Nix

A reproducible F4PGA environment for Xilinx 7-series and QuickLogic EOS S3 devices.

## Usage

Enter a shell containing only the architecture data needed for your device:

```shell
nix develop .#xc7a50t
cd path/to/f4pga-project
f4pga build --flow flow.json
```

Available shells include `xc7`, `xc7a50t`, `xc7a100t`, `xc7a200t`, `xc7a010t`, `eos-s3`, and `ql-eos-s3_wlcsp`.

## Verification

Run all package builds and the end-to-end XC7 bitstream test:

```shell
nix flake check -L
```

The `xc7-bitstream` check synthesizes, packs, places, routes, and generates a non-empty Arty A7-35T bitstream from [`tests/xc7-bitstream`](tests/xc7-bitstream).
