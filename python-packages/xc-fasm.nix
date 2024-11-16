{
  buildPythonPackage,
  fasm,
  fetchFromGitHub,
  intervaltree,
  nix-update-script,
  prjxray,
  simplejson,
  textx,
}:

buildPythonPackage {
  pname = "xc-fasm";
  version = "0-unstable-2022-02-28";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "chipsalliance";
    repo = "f4pga-xc-fasm";
    rev = "25dc605c9c0896204f0c3425b52a332034cf5e5c";
    fetchSubmodules = true;
    hash = "sha256-QzBL759yS2TwWmN0FG+WIWhTjhvzLVSYHatYlQgkxW4=";
  };

  dependencies = [
    fasm
    intervaltree
    prjxray
    simplejson
    textx
  ];

  pythonImportsCheck = [ "xc_fasm" ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
}
