{ fetchFromGitHub
, buildPythonPackage
, nix-update-script
, cython
, textx
}:

buildPythonPackage {
  pname = "fasm";
  version = "unstable-2022-07-25";

  format = "setuptools";

  src = fetchFromGitHub {
    owner = "chipsalliance";
    repo = "fasm";
    rev = "ffafe821bae68637fe46e36bcfd2a01b97cdf6f2";
    fetchSubmodules = true;
    hash = "sha256-evOtRl2FYa+9VIGpOc9Az7qAHFwt5dmukrpMXPBTZ7o=";
  };

  nativeBuildInputs = [ cython ];

  propagatedBuildInputs = [ textx ];

  doCheck = false;

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

}
