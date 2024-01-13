{ fetchFromGitHub
, buildPythonPackage
, nix-update-script
, colorama
, pyyaml
, stdenv
}:

buildPythonPackage {
  pname = "f4pga";
  version = "unstable-2023-09-13";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "chipsalliance";
    repo = "f4pga";
    rev = "9c049e21ac8ad5d7719e48434989f7365cb1b117";
    hash = "sha256-OfgbiDkkKxeUThxVbnFrpqAoS16xvbrZBgC+Ea+Kr2I=";
  };

  propagatedBuildInputs = [
    colorama
    pyyaml
  ];

  postPatch = ''
    substituteInPlace f4pga/wrappers/sh/__init__.py \
      --replace "/bin/bash" "${stdenv.shell}"
  '';

  preConfigure = ''
    cd f4pga
  '';

  doCheck = false;

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
}
