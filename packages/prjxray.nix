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
  version = "unstable-2024-01-04";

  format = "setuptools";

  src = fetchFromGitHub {
    owner = "f4pga";
    repo = "prjxray";
    rev = "248db01e4c2f1430c7d7e5f794eccf292779c62c";
    hash = "sha256-/KrkADQy3J17hrejfzNjvepm9CPsrK19LAznEH4bENE=";
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
