# Arty A7-100T example

Generate a bitstream from the repository root:

```shell
nix develop .#xc7a100t
cd examples/arty-a7-100t
f4pga build --flow flow.json
```

The resulting bitstream is written to `build/arty-a7-100t/top.bit`.
