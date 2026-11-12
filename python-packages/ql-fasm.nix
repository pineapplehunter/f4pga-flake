{
  lib,
  buildPythonPackage,
  fasm,
  fetchFromGitHub,
  nix-update-script,
  ql-fasm-utils,
  setuptools,
}:

buildPythonPackage {
  pname = "quicklogic-fasm";
  version = "0-unstable-2020-07-14";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "antmicro";
    repo = "quicklogic-fasm";
    rev = "fafa623486f37301821cd29683a2c7a118115ff1";
    fetchSubmodules = true;
    hash = "sha256-cDscgsOswTowFCmd7cUDesKDqfA8zt9u4wFPfZaPESE=";
  };

  patches = [ ./ql-fasm-local-database-path.patch ];

  build-system = [ setuptools ];

  dependencies = [
    fasm
    ql-fasm-utils
  ];

  pythonImportsCheck = [
    "quicklogic_fasm"
    "quicklogic_fasm.qlfasm"
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "FASM bitstream generator for QuickLogic FPGAs";
    homepage = "https://github.com/antmicro/quicklogic-fasm";
    license = lib.licenses.asl20;
    mainProgram = "qlfasm";
  };
}
