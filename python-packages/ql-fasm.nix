{ fetchFromGitHub
, buildPythonPackage
, nix-update-script
, fasm
, ql-fasm-utils
}:

buildPythonPackage {
  pname = "ql-fasm";
  version = "unstable-2022-02-28";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "antmicro";
    repo = "quicklogic-fasm";
    rev = "fafa623486f37301821cd29683a2c7a118115ff1";
    fetchSubmodules = true;
    hash = "sha256-cDscgsOswTowFCmd7cUDesKDqfA8zt9u4wFPfZaPESE=";
  };

  propagatedBuildInputs = [ fasm ql-fasm-utils ];

  doCheck = false;

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
}
