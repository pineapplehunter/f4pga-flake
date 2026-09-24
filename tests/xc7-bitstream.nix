{
  f4pga,
  f4pga-arch-defs,
  runCommand,
  symlinkJoin,
  archDef ? f4pga-arch-defs.xc7a50t_test,
  board ? "arty-a7-35t",
  source ? ./xc7-bitstream,
}:

let
  defs = symlinkJoin {
    name = "xc7-bitstream-test-defs";
    paths = with f4pga-arch-defs; [
      install-xc7
      archDef
    ];
  };

  installDir = runCommand "xc7-bitstream-test-install-dir" { } ''
    mkdir -p $out
    ln -s ${defs} $out/xc7
  '';
in
runCommand "f4pga-${board}-bitstream-test"
  {
    nativeBuildInputs = [ f4pga ];
    FPGA_FAM = "xc7";
    F4PGA_INSTALL_DIR = installDir;
  }
  ''
    cp -r ${source} source
    chmod -R u+w source
    cd source

    f4pga build --flow flow.json

    bitstream=build/${board}/top.bit
    test -s "$bitstream"

    mkdir -p $out
    cp "$bitstream" $out/top.bit
  ''
