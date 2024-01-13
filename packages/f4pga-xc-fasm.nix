{ fetchFromGitHub
, buildPythonPackage
, nix-update-script
, intervaltree
, simplejson
, textx
, fasm
, prjxray
}:

buildPythonPackage {
  pname = "f4pga-xc-fasm";
  version = "unstable-2022-02-28";

  format = "setuptools";

  src = fetchFromGitHub {
    owner = "chipsalliance";
    repo = "f4pga-xc-fasm";
    rev = "25dc605c9c0896204f0c3425b52a332034cf5e5c";
    fetchSubmodules = true;
    hash = "sha256-QzBL759yS2TwWmN0FG+WIWhTjhvzLVSYHatYlQgkxW4=";
  };

  propagatedBuildInputs = [
    intervaltree
    simplejson
    textx
    prjxray
    fasm
  ];

  doCheck = false;

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
}
