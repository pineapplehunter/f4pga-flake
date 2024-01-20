{ lib
, stdenv
, fetchzip
}:
let
  fpga-packages = [
    { name = "install-xc7"; hash = "sha256-wSA2EFFCylpqcAgkQ7I6f6DUJBygsWWNE4hjADZKqe0="; }
    { name = "xc7a50t_test"; hash = "sha256-oaNXm9AyDGib5jOTL9vqlWB6T+AcjKbDMagVdcvHlx0="; }
    { name = "xc7a100t_test"; hash = "sha256-sMeDW1ts5aaX6pDqdm7ctmL9ARW4Ws85WfLUsf8n/lY="; }
    { name = "xc7a200t_test"; hash = "sha256-hB5v7zPM+PU4AmGTH5DiI0kGvITmUC2Qeg1z42DzDxo="; }
    { name = "xc7z010_test"; hash = "sha256-/pk94lJ/iF6pn4EgweCEUcJFgD4xzwx0s0IjbW+0rcY="; }
    { name = "install-ql"; hash = "sha256-vi96gg86BURdmYP1lMKmVQ99ydaNYpTHISr1pYZUNDE="; }
    { name = "ql-eos-s3_wlcsp"; hash = "sha256-Ropfo/WEsRw7UcP2cbw6BaRsLtD1UXP3IQtxVhB8JC0="; }
  ];

  fpga-timestamp = "20220920-124259";
  fpga-hash = "007d1c1";

  fetchDefFile = { name, hash }:
    lib.attrsets.nameValuePair name (fetchzip {
      inherit name;
      url = "https://storage.googleapis.com/symbiflow-arch-defs/artifacts/prod/foss-fpga-tools/symbiflow-arch-defs/continuous/install/${fpga-timestamp}/symbiflow-arch-defs-${name}-${fpga-hash}.tar.xz";
      inherit hash;
      stripRoot = false;
    });
in
builtins.listToAttrs (map fetchDefFile fpga-packages) // {
  timestamp = fpga-timestamp;
  hash = fpga-hash;
}
