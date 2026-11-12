{
  lib,
  f4pga-xc7a35t,
  runCommand,
  configuredF4pga ? f4pga-xc7a35t,
  board ? "arty-a7-35t",
  source ? ./xc7-bitstream,
}:

runCommand "f4pga-${board}-bitstream-test"
  {
    strictDeps = true;
    __structuredAttrs = true;
    nativeBuildInputs = [ configuredF4pga ];
  }
  ''
    cp -r ${source} source
    chmod -R u+w source
    cd source

    ${lib.getExe configuredF4pga} build --flow flow.json

    bitstream=build/${board}/top.bit
    test -s "$bitstream"

    mkdir -p $out
    cp "$bitstream" $out/top.bit
  ''
