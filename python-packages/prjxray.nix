{
  fetchFromGitHub,
  buildPythonPackage,
  simplejson,
  intervaltree,
  nix-update-script,
  fasm,
  numpy,
  pyjson5,
  pyyaml,
}:

buildPythonPackage {
  pname = "prjxray";
  version = "0.1-unstable-2025-06-05";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "f4pga";
    repo = "prjxray";
    rev = "c9f02d8576042325425824647ab5555b1bc77833";
    hash = "sha256-cuqjVLTy9JZxuoD8vPsRfSFCv/HhhSdburx1a9EJajM=";
    fetchSubmodules = true;
  };

  dependencies = [
    fasm
    intervaltree
    numpy
    pyjson5
    pyyaml
    simplejson
  ];

  pythonImportsCheck = [
    "prjxray"
    "prjxray.fasm_assembler"
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

}
