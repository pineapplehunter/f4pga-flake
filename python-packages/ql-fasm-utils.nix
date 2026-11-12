{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  nix-update-script,
  setuptools,
}:

buildPythonPackage {
  pname = "fasm-utils";
  version = "0-unstable-2021-03-05";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "QuickLogic-Corp";
    repo = "quicklogic-fasm-utils";
    rev = "3d6a375ddb6b55aaa5a59d99e44a207d4c18709f";
    hash = "sha256-wHSOU+GaCGZtYqwze8+7fgerJ0aUlpL0NIzcCoQgKU8=";
  };

  build-system = [ setuptools ];

  pythonImportsCheck = [ "fasm_utils" ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "FASM utilities for QuickLogic FPGAs";
    homepage = "https://github.com/QuickLogic-Corp/quicklogic-fasm-utils";
    license = lib.licenses.asl20;
  };
}
