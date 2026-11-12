{
  lib,
  f4pga,
  f4pga-arch-defs,
  runCommand,
  symlinkJoin,
  writeShellApplication,
  name,
  family,
  archDef,
}:
let
  defs = symlinkJoin {
    name = "${name}-defs";
    strictDeps = true;
    __structuredAttrs = true;
    paths = [
      (if family == "xc7" then f4pga-arch-defs.install-xc7 else f4pga-arch-defs.install-ql)
      archDef
    ];
  };

  installDir =
    runCommand "${name}-install-dir"
      {
        strictDeps = true;
        __structuredAttrs = true;
      }
      ''
        mkdir -p "$out"
        ln -s ${defs} "$out/${family}"
      '';
in
writeShellApplication {
  inherit name;
  text = ''
    export FPGA_FAM=${lib.escapeShellArg family}
    export F4PGA_INSTALL_DIR=${installDir}
    export F4PGA_TIMESTAMP=${lib.escapeShellArg f4pga-arch-defs.timestamp}
    export F4PGA_HASH=${lib.escapeShellArg f4pga-arch-defs.hash}
    exec ${lib.getExe f4pga} "$@"
  '';
  meta = {
    description = "F4PGA configured with ${archDef.name} architecture data";
    inherit (f4pga.meta) homepage license platforms;
    mainProgram = name;
  };
}
