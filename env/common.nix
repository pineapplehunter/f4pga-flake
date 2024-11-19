{
  f4pga,
  f4pga-arch-defs,
  lib,
  mkShellNoCC,
  runCommand,
  symlinkJoin,

  family ? "xc7",
  allDevices ? true,
  enableQlEosS3Wlcsp ? allDevices && family == "eos-s3",
  enableXc7a50t ? allDevices && family == "xc7",
  enableXc7a100t ? allDevices && family == "xc7",
  enableXc7a200t ? allDevices && family == "xc7",
  enableXc7a010t ? allDevices && family == "xc7",
}:

let
  defs = symlinkJoin {
    name = "${family}-defs";
    paths =
      with f4pga-arch-defs;
      lib.concatLists [
        # EOS-S3 devices
        (lib.optionals (family == "eos-s3") [ install-ql ])
        (lib.optionals enableQlEosS3Wlcsp [ ql-eos-s3_wlcsp ])

        # XC7 devices
        (lib.optionals (family == "xc7") [ install-xc7 ])
        (lib.optionals enableXc7a50t [ xc7a50t_test ])
        (lib.optionals enableXc7a100t [ xc7a100t_test ])
        (lib.optionals enableXc7a200t [ xc7a200t_test ])
        (lib.optionals enableXc7a010t [ xc7z010_test ])
      ];
  };
in

mkShellNoCC {
  name = "f4pga-${family}-env";
  packages = builtins.attrValues {
    inherit f4pga;
  };

  FPGA_FAM = family;
  F4PGA_TIMESTAMP = f4pga-arch-defs.timestamp;
  F4PGA_HASH = f4pga-arch-defs.hash;
  F4PGA_INSTALL_DIR = runCommand "${family}-defs-dir" { preferLocalBuild = true; } ''
    mkdir -pv $out
    ln -s ${defs} $out/${family}
  '';
}
