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
, allDevices ? true
, enableXc7a50t ? allDevices
, enableXc7a100t ? allDevices
, enableXc7a200t ? allDevices
, enableXc7a010t ? allDevices
}:
let
  defs = symlinkJoin {
    name = "xc7-defs";
    paths = with f4pga-arch-defs;[
      install-xc7
      (lib.optional enableXc7a50t xc7a50t_test)
      (lib.optional enableXc7a100t xc7a100t_test)
      (lib.optional enableXc7a200t xc7a200t_test)
      (lib.optional enableXc7a010t xc7z010_test)
    ];
  };
in
mkShell {
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

  FPGA_FAM = "xc7";
  F4PGA_TIMESTAMP = f4pga-arch-defs.timestamp;
  F4PGA_HASH = f4pga-arch-defs.hash;
  F4PGA_INSTALL_DIR = runCommand "xc7-defs-dir" { } ''
    mkdir -pv $out
    ln -s ${defs} $out/xc7
  '';

}
