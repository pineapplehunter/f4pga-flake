{
  antlr4_9,
  buildPythonPackage,
  cmake,
  cython,
  fetchFromGitHub,
  jdk,
  lib,
  nix-update-script,
  setuptools,
  textx,

  enableAntlr ? true,
}:

buildPythonPackage {
  pname = "fasm";
  version = "0.0.2-unstable-2022-07-25";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "chipsalliance";
    repo = "fasm";
    rev = "ffafe821bae68637fe46e36bcfd2a01b97cdf6f2";
    fetchSubmodules = true;
    hash = "sha256-evOtRl2FYa+9VIGpOc9Az7qAHFwt5dmukrpMXPBTZ7o=";
  };

  build-system = [
    cython
    setuptools
  ];

  nativeBuildInputs = lib.optionals enableAntlr [
    cmake
    jdk
  ];

  buildInputs = lib.optionals enableAntlr [
    antlr4_9
    antlr4_9.runtime.cpp
  ];

  dependencies = [
    textx
  ];

  dontUseCmakeConfigure = true;

  # PEP 517 does not use setupPyBuildFlags; set the build command's default instead.
  patches = lib.optionals enableAntlr [ ./fasm-shared-antlr-runtime.patch ];

  env.ANTLR4_RUNTIME_INCLUDE = "${antlr4_9.runtime.cpp.dev}/include/antlr4-runtime";

  pythonImportsCheck = [ "fasm" ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "FPGA Assembly format parser and utilities";
    homepage = "https://github.com/chipsalliance/fasm";
    license = lib.licenses.asl20;
    mainProgram = "fasm";
  };
}
