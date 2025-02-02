{
  bison,
  cmake,
  fetchFromGitHub,
  fetchurl,
  flex,
  lib,
  libffi,
  libz,
  ninja,
  pkg-config,
  python3,
  readline,
  stdenv,
  substituteAll,
  tcl,
  openssl,

  enableTbb ? true,
  tbb_2021_11,

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
  java-schema = fetchurl rec {
    # master version
    version = "b2f7242c2d833eb499fd9734132642d571b02a74";
    url = "https://raw.githubusercontent.com/capnproto/capnproto-java/${version}/compiler/src/main/schema/capnp/java.capnp";
    hash = "sha256-q8SNhZ/6Bqwmx9/mAgN0+w7l76STZwerw1vawiM676s=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "vtr";
  version = "9.0.0-candidate1";

  src = fetchFromGitHub {
    owner = "verilog-to-routing";
    repo = "vtr-verilog-to-routing";
    rev = "refs/tags/v${finalAttrs.version}";
    hash = "sha256-bsf99P6XY7gGiZauLQcOdDR3SxH7lQu31fq1GvWrHmc=";
    fetchSubmodules = true;
  };

  patches = [
    (substituteAll {
      src = ./nowget.patch;
      javaschema = java-schema;
    })
  ];

  nativeBuildInputs = [
    (python3.withPackages (ps: with ps; [ prettytable ]))
    bison
    cmake
    flex
    ninja
    pkg-config
    tcl
  ];

  buildInputs =
    [
      libffi
      libz
      openssl
      readline
    ]
    ++ lib.optionals enableTbb [ tbb_2021_11 ]
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

  doCheck = false;

  postInstall = ''
    moveToOutput "bin/*.a" $lib
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

  meta.platforms = lib.platforms.linux;
})
