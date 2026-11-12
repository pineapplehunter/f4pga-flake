{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  nix-update-script,
  pyserial,
  setuptools,
}:

buildPythonPackage {
  pname = "tinyfpgab";
  version = "0-unstable-2018-07-26";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "tinyfpga";
    repo = "TinyFPGA-B-Series";
    rev = "e8f915033f7a941647ca5f884e80086a8e68282d";
    hash = "sha256-j2IP862jEn7W4dnQxoYYai4JIq7n0LGY3dFtcfIJ288=";
  };

  build-system = [ setuptools ];

  dependencies = [ pyserial ];

  preConfigure = ''
    cd programmer
  '';

  pythonImportsCheck = [ "tinyfpgab" ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Serial programmer for TinyFPGA B-series boards";
    homepage = "https://github.com/tinyfpga/TinyFPGA-B-Series";
    license = lib.licenses.gpl3Only;
    mainProgram = "tinyfpgab";
  };
}
