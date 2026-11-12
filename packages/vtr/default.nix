# This revision matches the prebuilt F4PGA architecture bundles.
{
  lib,
  stdenv,
  bison,
  cmake,
  fetchFromGitHub,
  fetchurl,
  flex,
  libffi,
  libz,
  ninja,
  pkg-config,
  python3,
  readline,
  replaceVars,
  tcl,
  openssl,

  enableTbb ? true,
  tbb,

  enableEigen ? true,
  eigen,

  # gui
  enableX11 ? true,
  cairo,
  gtk3,
  lerc,
  libX11,
  libXdmcp,
  libXtst,
  libdatrie,
  libepoxy,
  libselinux,
  libsepol,
  libsysprof-capture,
  libthai,
  libuuid,
  libxkbcommon,
  pango,
  pcre2,
}:
let
  java-schema = fetchurl {
    url = "https://raw.githubusercontent.com/capnproto/capnproto-java/b2f7242c2d833eb499fd9734132642d571b02a74/compiler/src/main/schema/capnp/java.capnp";
    hash = "sha256-q8SNhZ/6Bqwmx9/mAgN0+w7l76STZwerw1vawiM676s=";
  };
in
stdenv.mkDerivation {
  pname = "vtr-f4pga";
  version = "8.0.0-5699-g25e723a24";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "verilog-to-routing";
    repo = "vtr-verilog-to-routing";
    rev = "25e723a24aa0ae7a0061cd89dd84b1fb62afcc09";
    hash = "sha256-q3J89TiwrqsUHs0/H4cBMMDx2Xya8uiXndsUPti5DkA=";
    fetchSubmodules = true;
  };

  patches = [
    (replaceVars ./nowget.patch {
      javaschema = java-schema;
    })
    ./gcc15-compat.patch
    ./mmap-file-follow-symlinks.patch
  ];

  nativeBuildInputs = [
    (python3.withPackages (ps: [ ps.prettytable ]))
    bison
    cmake
    flex
    ninja
    pkg-config
    tcl
  ];

  buildInputs = [
    libffi
    libz
    openssl
    readline
  ]
  ++ lib.optionals enableTbb [ tbb ]
  ++ lib.optionals enableEigen [ eigen ]
  ++ lib.optionals enableX11 [
    cairo
    gtk3
    lerc
    libX11
    libXdmcp
    libXtst
    libdatrie
    libepoxy
    libselinux
    libsepol
    libsysprof-capture
    libthai
    libuuid
    libxkbcommon
    pango
    pcre2
  ];

  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.5")
    (lib.cmakeFeature "VPR_USE_EZGL" (if enableX11 then "on" else "off"))
    (lib.cmakeFeature "VPR_EXECUTION_ENGINE" (if enableTbb then "tbb" else "serial"))
    (lib.cmakeBool "VPR_ANALYTIC_PLACE" enableEigen)
  ];

  doCheck = false;

  postInstall = ''
    moveToOutput "bin/*.a" $lib
    mkdir -p $lib/lib
    cp $lib/bin/* $lib/lib
    moveToOutput share $dev
  '';

  outputs = [
    "out"
    "lib"
    "dev"
  ];

  passthru = {
    inherit java-schema;
  };

  meta = {
    description = "F4PGA-compatible Verilog-to-Routing FPGA CAD tools";
    homepage = "https://verilogtorouting.org/";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "vpr";
  };
}
