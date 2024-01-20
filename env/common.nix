{ lib
, python3
, mkShell
, openfpgaloader
, prjxray-tools
, prjxray-config
, vtr
, pkgsCross
, symbiyosys
, yosys
, which
, symlinkJoin
, f4pga-arch-defs
, runCommand
, family ? "xc7"
, allDevices ? true
, enableQlEosS3Wlcsp ? allDevices && family == "eos-s3"
, enableXc7a50t ? allDevices && family == "xc7"
, enableXc7a100t ? allDevices && family == "xc7"
, enableXc7a200t ? allDevices && family == "xc7"
, enableXc7a010t ? allDevices && family == "xc7"
}:
let
  defs = symlinkJoin {
    name = "${family}-defs";
    paths = with f4pga-arch-defs;[
      # EOS-S3 devices
      (lib.optional (family == "eos-s3") install-ql)
      (lib.optional enableQlEosS3Wlcsp ql-eos-s3_wlcsp)

      # XC7 devices
      (lib.optional (family == "xc7") install-xc7)
      (lib.optional enableXc7a50t xc7a50t_test)
      (lib.optional enableXc7a100t xc7a100t_test)
      (lib.optional enableXc7a200t xc7a200t_test)
      (lib.optional enableXc7a010t xc7z010_test)
    ];
  };
in
mkShell {
  name = "f4pga-${family}-env";
  packages = [
    openfpgaloader
    prjxray-tools
    prjxray-config
    pkgsCross.riscv64-embedded.stdenv.cc
    python3
    vtr
    (yosys.withPlugins (with yosys.allPlugins;
    [
      design_introspection
      fasm
      integrateinv
      params
      ql-iob
      sdc
      xdc
    ]))
    symbiyosys
    which
  ] ++ (with python3.pkgs;[
    fasm
    prjxray
    xc-fasm
    f4pga
    lxml
    python-constraint
    simplejson
  ]);

  FPGA_FAM = family;
  F4PGA_TIMESTAMP = f4pga-arch-defs.timestamp;
  F4PGA_HASH = f4pga-arch-defs.hash;
  F4PGA_INSTALL_DIR = runCommand "${family}-defs-dir" { } ''
    mkdir -pv $out
    ln -s ${defs} $out/${family}
  '';

}
