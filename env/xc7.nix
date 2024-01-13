{ python3, mkShell }:
let
  xc7-python = python3.withPackages (ps: with ps;[
    fasm
    prjxray
    f4pga-xc-fasm
    f4pga
  ]);
in
mkShell {
  packages = [ xc7-python ];
}
