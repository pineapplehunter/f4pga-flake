{ fetchFromGitHub
, buildPythonPackage
, simplejson
, intervaltree
, nix-update-script
, fasm
, numpy
, pyjson5
, pyyaml
}:

buildPythonPackage {
  pname = "prjxray";
  version = "unstable-2024-01-13";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "f4pga";
    repo = "prjxray";
    rev = "01ce064d160a9d805366ef3756c40a990165d3a8";
    hash = "sha256-SWCce7zx11O525Z3T2RUVP0cqYOgGRXXgBnqn8PVVOs=";
    fetchSubmodules = true;
  };

  propagatedBuildInputs = [
    fasm
    intervaltree
    numpy
    pyjson5
    pyyaml
    simplejson
  ];

  doCheck = false;

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

}
