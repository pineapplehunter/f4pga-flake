# Arty A7-100T example

Generate a bitstream from the repository root:

```shell
cd examples/arty-a7-100t
nix run ../..#f4pga-xc7a100t -- build --flow flow.json
```

The resulting bitstream is written to `build/arty-a7-100t/top.bit`.
