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
  version = "0.0-583-t1e53270-unstable-2024-09-28";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "f4pga";
    repo = "prjxray";
    rev = "f2d21573c7f6bdfa98e86fae5a2f5ef52e23b51c";
    hash = "sha256-Ld4oo8Ha+78jZZK76KP8W5GObt4LLb3h58OZ9eJDRrQ=";
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

  pythonImportsCheck = [ "prjxray" ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

}
