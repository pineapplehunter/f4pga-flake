{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  yosys,
  vtr,
  nodejs,
  libxml2,
  openocd,
  yapf,
  icestorm,
  tinyprog,
  verilog,
  prjxray-tools,
  prjxray-config,
  python3,
  cmake,
  gtkwave,
  inkscape,
  cmakeCurses,
  fusesoc,
}:
let
  python-env = python3.withPackages (
    ps: with ps; [
      f4pga
      flake8
      pytest
      xc-fasm
      qlf-fasm
      ql-fasm
      quicklogic-timings-importer
      tinyfpgab
      prjxray
      simplejson
      pyjson5
      pyyaml
      numpy
      intervaltree
      mako
    ]
  );
in
stdenv.mkDerivation {
  pname = "f4pga-arch-defs";
  version = "unstable-2021-12-14";

  src = fetchFromGitHub {
    owner = "f4pga";
    repo = "f4pga-arch-defs";
    rev = "1f97ae02626f9470abc1bfb6d0f7366b79f0614f";
    hash = "sha256-K9CM/NqaGUhXEzAAADfAr7BQP+lagAu9s/Xe/bzX67w=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    gtkwave
    inkscape
    yosys
    vtr
    nodejs
    libxml2
    openocd
    yapf
    icestorm
    tinyprog
    verilog
    prjxray-tools
    prjxray-config
    cmake
    cmakeCurses
    fusesoc
    python-env
  ];

  cmakeFlags = [
    "-DPYTHON3=${lib.getExe python-env}"
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
}
