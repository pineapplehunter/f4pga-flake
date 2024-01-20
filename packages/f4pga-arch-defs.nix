{ lib
, stdenv
, fetchzip
, runCommand
, gnutar
}:
let
  fpga-packages = [
    { name = "install-xc7"; hash = ""; }
    { name = "xc7a50t_test"; hash = ""; }
    { name = "xc7a100t_test"; hash = ""; }
    { name = "xc7a200t_test"; hash = ""; }
    { name = "xc7z010_test"; hash = ""; }
    { name = "install-ql"; hash = ""; }
    { name = "ql-eos-s3_wlcsp"; hash = ""; }
  ];
  fpga-timestamp = "20220920-124259";
  fpga-hash = "007d1c1";

  fetchDefFile = { name, hash }: fetchzip {
    name = "${name}.tar.xz";
    url = "https://storage.googleapis.com/symbiflow-arch-defs/artifacts/prod/foss-fpga-tools/symbiflow-arch-defs/continuous/install/${fpga-timestamp}/symbiflow-arch-defs-${name}-${fpga-hash}.tar.xz";
    inherit hash;
  };
in
builtins.listToAttrs (map fetchDefFile fpga-packages) // {
  timestamp = fpga-timestamp;
  hash = fpga-hash;
}
