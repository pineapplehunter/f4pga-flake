{
  lib,
  fetchFromGitHub,
  gtest,
  python3,
  readline,
  stdenv,
  yosys,
  zlib,
  yosys-symbiflow,
  pkg-config,
}:
let

  version = "1.20230906";

  src = fetchFromGitHub {
    owner = "chipsalliance";
    repo = "yosys-f4pga-plugins";
    rev = "v${version}";
    hash = "sha256-XIn5wFw8i2njDN0Arua5BdZ0u1q6a/aJAs48YICehsc=";
  };

  # Supported symbiflow plugins.
  #
  # The following are disabled:
  #
  # "ql-qlf" builds but fails to load the plugin, so is not currently supported.
  plugins = [
    "design_introspection"
    "fasm"
    "integrateinv"
    "params"
    "ql-iob"
    # "ql-qlf"
    "sdc"
    "xdc"
  ];

  staticGtest = gtest.override { static = true; };

in
lib.genAttrs plugins (
  plugin:
  stdenv.mkDerivation {
    pname = "yosys-symbiflow-${plugin}-plugin";
    inherit src version plugin;
    patches = lib.optional (plugin == "integrateinv") ./integrateinv-yosys-0.47.patch;
    strictDeps = true;
    __structuredAttrs = true;
    enableParallelBuilding = true;

    nativeBuildInputs = [
      python3
      pkg-config
      yosys
    ];
    buildInputs = [
      yosys
      readline
      zlib
    ];

    # xdc has an incorrect path to a test which has yet to be patched
    doCheck = plugin != "xdc";
    checkInputs = [ staticGtest ];

    # A Makefile rule tries to wget-fetch a yosys script from github.
    # Link the script from our yosys sources in preBuild instead, so that
    # the Makefile rule is a no-op.
    preBuild = ''
      ln -s ${yosys.src}/passes/pmgen/pmgen.py pmgen.py
    '';

    # Providing a symlink avoids the need for patching the test makefile
    postUnpack = ''
      mkdir -p source/third_party/googletest/build/
      ln -s ${staticGtest}/lib source/third_party/googletest/build/lib
    '';

    makeFlags = [
      "PLUGIN_LIST=${plugin}"
      "YOSYS_PLUGINS_DIR=${placeholder "out"}/share/yosys/plugins/"
      "YOSYS_DATA_DIR=${placeholder "out"}/share/yosys/"
    ];

    checkTarget = "test";
    checkFlags = [
      (
        "NIX_YOSYS_PLUGIN_DIRS=\${NIX_BUILD_TOP}/source/${plugin}-plugin/build"
        # sdc and xdc plugins use design introspection for their tests
        + (lib.optionalString (
          plugin == "sdc" || plugin == "xdc"
        ) ":${yosys-symbiflow.design_introspection}/share/yosys/plugins/")
      )
    ];

    meta = {
      description = "Symbiflow ${plugin} plugin for Yosys";
      homepage = "https://github.com/chipsalliance/yosys-f4pga-plugins";
      license = lib.licenses.isc;
      platforms = lib.platforms.all;
      maintainers = with lib.maintainers; [
        ollieB
        thoughtpolice
      ];
    };
  }
)
