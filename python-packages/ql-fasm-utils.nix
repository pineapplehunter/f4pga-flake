{ fetchFromGitHub
, buildPythonPackage
, nix-update-script
}:

buildPythonPackage {
  pname = "ql-fasm-utils";
  version = "unstable-2022-02-28";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "QuickLogic-Corp";
    repo = "quicklogic-fasm-utils";
    rev = "3d6a375ddb6b55aaa5a59d99e44a207d4c18709f";
    hash = "sha256-wHSOU+GaCGZtYqwze8+7fgerJ0aUlpL0NIzcCoQgKU8=";
  };

  doCheck = false;

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
}
