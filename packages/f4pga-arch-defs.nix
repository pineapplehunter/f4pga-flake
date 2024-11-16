{
  lib,
  fetchzip,
}:
let
  fpga-package-hashes = {
    "install-xc7" = "sha256-wSA2EFFCylpqcAgkQ7I6f6DUJBygsWWNE4hjADZKqe0=";
    "xc7a50t_test" = "sha256-oaNXm9AyDGib5jOTL9vqlWB6T+AcjKbDMagVdcvHlx0=";
    "xc7a100t_test" = "sha256-sMeDW1ts5aaX6pDqdm7ctmL9ARW4Ws85WfLUsf8n/lY=";
    "xc7a200t_test" = "sha256-hB5v7zPM+PU4AmGTH5DiI0kGvITmUC2Qeg1z42DzDxo=";
    "xc7z010_test" = "sha256-/pk94lJ/iF6pn4EgweCEUcJFgD4xzwx0s0IjbW+0rcY=";
    "install-ql" = "sha256-vi96gg86BURdmYP1lMKmVQ99ydaNYpTHISr1pYZUNDE=";
    "ql-eos-s3_wlcsp" = "sha256-Ropfo/WEsRw7UcP2cbw6BaRsLtD1UXP3IQtxVhB8JC0=";
  };

  fpga-timestamp = "20220920-124259";
  fpga-hash = "007d1c1";

  fetchDefFile =
    name: hash:
    fetchzip {
      inherit name;
      url = "https://storage.googleapis.com/symbiflow-arch-defs/artifacts/prod/foss-fpga-tools/symbiflow-arch-defs/continuous/install/${fpga-timestamp}/symbiflow-arch-defs-${name}-${fpga-hash}.tar.xz";
      inherit hash;
      stripRoot = false;
    };

in
{
  timestamp = fpga-timestamp;
  hash = fpga-hash;
}
// lib.attrsets.mapAttrs fetchDefFile fpga-package-hashes
