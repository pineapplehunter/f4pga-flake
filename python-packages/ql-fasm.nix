{
  buildPythonPackage,
  fasm,
  fetchFromGitHub,
  nix-update-script,
  ql-fasm-utils,
  setuptools,
}:

buildPythonPackage {
  pname = "ql-fasm";
  version = "0-unstable-2020-07-14";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "antmicro";
    repo = "quicklogic-fasm";
    rev = "fafa623486f37301821cd29683a2c7a118115ff1";
    fetchSubmodules = true;
    hash = "sha256-cDscgsOswTowFCmd7cUDesKDqfA8zt9u4wFPfZaPESE=";
  };

  dependencies = [
    fasm
    ql-fasm-utils
    setuptools
  ];

  pythonImportsCheck = [ "quicklogic_fasm" ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
}
