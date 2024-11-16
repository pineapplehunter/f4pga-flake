{
  antlr4_9,
  buildPythonPackage,
  cmake,
  cython,
  fetchFromGitHub,
  jdk,
  lib,
  nix-update-script,
  textx,

  enableAntlr ? true,
}:

buildPythonPackage {
  pname = "fasm";
  version = "0.0.2-unstable-2022-07-25";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "chipsalliance";
    repo = "fasm";
    rev = "ffafe821bae68637fe46e36bcfd2a01b97cdf6f2";
    fetchSubmodules = true;
    hash = "sha256-evOtRl2FYa+9VIGpOc9Az7qAHFwt5dmukrpMXPBTZ7o=";
  };

  nativeBuildInputs =
    [
      cython
    ]
    ++ lib.optionals enableAntlr [
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

  setupPyBuildFlags = lib.optionals enableAntlr [ "--antlr-runtime=shared" ];

  env.ANTLR4_RUNTIME_INCLUDE = "${antlr4_9.runtime.cpp.dev}/include/antlr4-runtime";

  pythonImportsCheck = [ "fasm" ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
}
