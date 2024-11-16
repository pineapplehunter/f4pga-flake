{
  buildPythonPackage,
  colorama,
  fetchFromGitHub,
  lib,
  lxml,
  nix-update-script,
  prjxray,
  prjxray-config,
  python-constraint,
  python3,
  pyyaml,
  setuptools,
  simplejson,
  stdenv,
  vtr,
  yosys,

  enableXc7 ? true,
}:
let
  yosys-with-plugins = yosys.withPlugins (
    with yosys.allPlugins;
    [
      # integrateinv
      # ql-iob
      (params.overrideAttrs { doCheck = false; })
      design_introspection
      fasm
      sdc
      xdc
    ]
  );
in
buildPythonPackage {
  pname = "f4pga-unwrapped";
  version = "0-unstable-2024-10-15";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "chipsalliance";
    repo = "f4pga";
    rev = "0723f9ca4ea4b686ff9c2e32c9cec56d40de1a62";
    hash = "sha256-heZ19PeMP+Fc1lAgytAejlMdDjxMVtPOOqzNsobVg6U=";
  };

  build-system = [ setuptools ];

  dependencies =
    [
      colorama
      lxml
      python-constraint
      pyyaml
      simplejson
    ]
    ++ lib.optionals enableXc7 [
      prjxray
      prjxray-config
    ];

  postPatch = ''
    substituteInPlace f4pga/wrappers/sh/__init__.py \
      --replace-fail "/bin/bash" "${stdenv.shell}"
  '';

  preConfigure = ''
    cd f4pga
  '';

  doCheck = true;

  pythonImportsCheck = [ "f4pga" ];

  postInstall = ''
    for file in $out/bin/*; do
      wrapProgram "$file" \
        --inherit-argv0 \
        --suffix PATH : ${
          lib.makeBinPath [
            yosys-with-plugins
            vtr
          ]
        }
    done

    for file in $out/lib/${python3.executable}/site-packages/f4pga/wrappers/sh/**/*.sh; do
      chmod +x "$file"
      wrapProgram "$file" \
        --suffix PYTHONPATH : "$out/lib/${python3.executable}/site-packages:${simplejson}/lib/${python3.executable}/site-packages"
    done
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
}
