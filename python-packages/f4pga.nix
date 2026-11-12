{
  lib,
  buildPythonPackage,
  colorama,
  fetchFromGitHub,
  lxml,
  nix-update-script,
  prjxray,
  prjxray-config,
  prjxray-tools,
  python-constraint2,
  python,
  pyyaml,
  ql-fasm,
  qlf-fasm,
  setuptools,
  simplejson,
  stdenv,
  vtr,
  which,
  xc-fasm,
  yosys,

  # Dependency sets, not device selectors; FPGA_FAM selects the runtime family.
  enableXc7 ? true,
  enableQuicklogic ? true,
}:
let
  pythonDependencies = [
    colorama
    lxml
    pyyaml
    simplejson
  ]
  ++ lib.optionals enableXc7 [
    prjxray
    python-constraint2
  ]
  ++ lib.optionals enableQuicklogic [ ql-fasm ];

  yosys-with-plugins = yosys.withPlugins (
    with yosys.allPlugins;
    [
      (params.overrideAttrs { doCheck = false; })
      design_introspection
      fasm
      sdc
      xdc
    ]
    ++ lib.optionals enableQuicklogic [
      integrateinv
      ql-iob
    ]
  );

  runtimeTools = [
    yosys-with-plugins
    vtr
    which
  ]
  ++ lib.optionals enableXc7 [
    prjxray-config
    prjxray-tools
    xc-fasm
  ]
  ++ lib.optionals enableQuicklogic [
    ql-fasm
    qlf-fasm
  ];
in
buildPythonPackage {
  pname = "f4pga";
  version = "0-unstable-2024-10-15";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "chipsalliance";
    repo = "f4pga";
    rev = "0723f9ca4ea4b686ff9c2e32c9cec56d40de1a62";
    hash = "sha256-heZ19PeMP+Fc1lAgytAejlMdDjxMVtPOOqzNsobVg6U=";
  };

  patches = [
    ./f4pga-inherit-subprocess-environment.patch
    ./f4pga-eos-s3-builtin-synthesis.patch
  ];

  build-system = [ setuptools ];

  dependencies = pythonDependencies;

  postPatch = ''
    substituteInPlace f4pga/wrappers/sh/__init__.py \
      --replace-fail "/bin/bash" "${stdenv.shell}"
  '';

  preConfigure = ''
    cd f4pga
  '';

  pythonImportsCheck = [
    "f4pga"
    "f4pga.utils.yosys_split_inouts"
  ]
  ++ lib.optionals enableXc7 [
    "f4pga.utils.xc7.create_place_constraints"
  ]
  ++ lib.optionals enableQuicklogic [
    "quicklogic_fasm"
    "f4pga.utils.quicklogic.pp3.create_ioplace"
    "f4pga.utils.quicklogic.pp3.create_place_constraints"
    "f4pga.utils.quicklogic.qlf_k4n8.create_ioplace"
  ];

  # The Python hook wraps all entry points. Export the import path as well:
  # shell scripts launch child Python processes, which do not inherit sys.path.
  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath runtimeTools)
    "--prefix"
    "PYTHONPATH"
    ":"
    "${placeholder "out"}/${python.sitePackages}:${python.pkgs.makePythonPath pythonDependencies}"
  ];

  postInstall = ''
    chmod +x "$out/${python.sitePackages}"/f4pga/wrappers/sh/*/*.sh
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Open-source FPGA toolchain flow manager";
    homepage = "https://f4pga.org/";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    mainProgram = "f4pga";
  };
}
