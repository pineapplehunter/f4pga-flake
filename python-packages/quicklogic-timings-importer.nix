{
  fetchFromGitHub,
  buildPythonPackage,
  nix-update-script,
}:

buildPythonPackage {
  pname = "quicklogic-timings-importer";
  version = "0-unstable-2020-06-09";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "antmicro";
    repo = "quicklogic-timings-importer";
    rev = "58b4046bef4aebfef67f3aa12bc266aebd614f6a";
    fetchSubmodules = true;
    hash = "sha256-b+qWF7boZo7ZkmRFy/VdKl3mo1wd5PfJuSB7wuQ5BYw=";
  };

  pythonImportsCheck = [ "quicklogic_timings_importer" ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
}
