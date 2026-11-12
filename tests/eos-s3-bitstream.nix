{
  f4pga,
  f4pga-arch-defs,
  runCommand,
  symlinkJoin,
}:

let
  defs = symlinkJoin {
    name = "eos-s3-bitstream-test-defs";
    strictDeps = true;
    __structuredAttrs = true;
    paths = with f4pga-arch-defs; [
      install-ql
      ql-eos-s3_wlcsp
    ];
  };

  installDir =
    runCommand "eos-s3-bitstream-test-install-dir"
      {
        strictDeps = true;
        __structuredAttrs = true;
      }
      ''
        mkdir -p $out
        ln -s ${defs} $out/eos-s3
      '';
in
runCommand "f4pga-eos-s3-bitstream-test"
  {
    strictDeps = true;
    __structuredAttrs = true;
    nativeBuildInputs = [ f4pga ];
    env = {
      FPGA_FAM = "eos-s3";
      F4PGA_INSTALL_DIR = installDir;
    };
  }
  ''
    cp -r ${./eos-s3-bitstream} source
    chmod -R u+w source
    cd source

    f4pga build --flow flow.json

    test -s build/top.bit
    mkdir -p $out
    cp build/top.bit $out/top.bit
  ''
