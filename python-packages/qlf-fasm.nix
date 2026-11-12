{
  lib,
  buildPythonPackage,
  fasm,
  fetchFromGitHub,
  nix-update-script,
  setuptools,
}:

buildPythonPackage {
  pname = "qlf-fasm";
  version = "0-unstable-2021-06-11";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "QuickLogic-Corp";
    repo = "ql_fasm";
    rev = "e5d09154df9b0c6d1476ac578950ec95abb8ed86";
    hash = "sha256-jciXhME/EXV50xBOq2mAfc/bPNEJYZ+TFU7F91wTjfY=";
  };

  build-system = [ setuptools ];

  dependencies = [ fasm ];

  pythonImportsCheck = [ "qlf_fasm" ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "FASM support for QuickLogic FPGAs";
    homepage = "https://github.com/QuickLogic-Corp/ql_fasm";
    license = lib.licenses.asl20;
  };
}
