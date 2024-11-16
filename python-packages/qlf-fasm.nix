{
  fetchFromGitHub,
  buildPythonPackage,
  nix-update-script,
  fasm,
}:

buildPythonPackage {
  pname = "qlf-fasm";
  version = "0-unstable-2021-06-11";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "QuickLogic-Corp";
    repo = "ql_fasm";
    rev = "e5d09154df9b0c6d1476ac578950ec95abb8ed86";
    hash = "sha256-jciXhME/EXV50xBOq2mAfc/bPNEJYZ+TFU7F91wTjfY=";
  };

  dependencies = [ fasm ];

  pythonImportsCheck = [ "qlf_fasm" ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
}
