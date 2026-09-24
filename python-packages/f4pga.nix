{
  buildPythonPackage,
  colorama,
  fetchFromGitHub,
  lib,
  lxml,
  nix-update-script,
  prjxray,
  prjxray-config,
  prjxray-tools,
  python-constraint,
  python,
  pyyaml,
  setuptools,
  simplejson,
  stdenv,
  vtr,
  which,
  xc-fasm,
  yosys,

  enableXc7 ? true,
}:
let
  pythonConstraint = python-constraint.overridePythonAttrs {
    dontCheckPythonMetadata = true;
  };

  pythonDependencies = [
    colorama
    lxml
    pyyaml
    simplejson
  ]
  ++ lib.optionals enableXc7 [
    prjxray
    pythonConstraint
  ];

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

  dependencies = pythonDependencies;

  postPatch = ''
    substituteInPlace f4pga/wrappers/sh/__init__.py \
      --replace-fail "/bin/bash" "${stdenv.shell}"
    substituteInPlace f4pga/flows/commands.py \
      --replace-fail 'common_sub("which", "python3").decode().replace("\n", "")' '"'"$out/bin/f4pga-python"'"'
  '';

  preConfigure = ''
    cd f4pga
  '';

  doCheck = true;

  pythonImportsCheck = [
    "f4pga"
    "f4pga.utils.yosys_split_inouts"
  ]
  ++ lib.optionals enableXc7 [
    "f4pga.utils.xc7.create_place_constraints"
  ];

  postInstall = ''
    makeWrapper ${python.interpreter} $out/bin/f4pga-python \
      --prefix PYTHONPATH : "$out/${python.sitePackages}:${python.pkgs.makePythonPath pythonDependencies}"

    for file in $out/bin/*; do
      wrapProgram "$file" \
        --inherit-argv0 \
        --suffix PATH : ${
          lib.makeBinPath (
            [
              yosys-with-plugins
              vtr
              which
            ]
            ++ lib.optionals enableXc7 [
              prjxray-config
              prjxray-tools
              xc-fasm
            ]
          )
        }
    done

    for file in $out/lib/${python.executable}/site-packages/f4pga/wrappers/sh/**/*.sh; do
      chmod +x "$file"
      wrapProgram "$file" \
        --suffix PYTHONPATH : "$out/lib/${python.executable}/site-packages:${simplejson}/lib/${python.executable}/site-packages"
    done
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
}
