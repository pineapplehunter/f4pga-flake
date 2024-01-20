{ fetchFromGitHub
, clangStdenv
, python3
, bison
, flex
, cmake
, tbb_2021_8
, libX11
, libXft
, fontconfig
, cairo
, pkg-config
, gtk3
, gperftools
, perl
, time
, libXdmcp
, libxcb
, wget
, pcre2
, pcre
, util-linux
, libselinux
, libsepol
, libthai
, libdatrie
, libxkbcommon
, libepoxy
, libXtst
, tcl
, readline
, ninja
, clang
, fetchurl
, capnproto
, eigen
, openssl
, libffi
}:
let
  java-schema = fetchurl rec {
    # master version
    version = "ed9a67c5fcd46604a88593625a9e38496b83d3ab";
    url = "https://raw.githubusercontent.com/capnproto/capnproto-java/${version}/compiler/src/main/schema/capnp/java.capnp";
    hash = "sha256-q8SNhZ/6Bqwmx9/mAgN0+w7l76STZwerw1vawiM676s=";
  };
in
clangStdenv.mkDerivation rec {
  pname = "vtr";
  version = "unstable-2024-01-04";

  src = fetchFromGitHub {
    owner = "verilog-to-routing";
    repo = "vtr-verilog-to-routing";
    rev = "69f9ebe5480a4f57335ba12e4788689217ae15b2";
    hash = "sha256-0/beRWNFkh6eh8BDwfQE5YdUtHDF9IqH+qvVbiU2DVI=";
    fetchSubmodules = true;
  };

  patches = [
    ./nowget.patch
    ./yosys.patch
    ./iterator.patch
  ];

  cmakeFlags = [ "-DWITH_PARMYS=OFF" ];

  nativeBuildInputs = [
    python3
    perl
    bison
    flex
    cmake
    pkg-config
    gperftools
    time
    ninja
  ] ++ (with python3.pkgs;
    [
      pip
      virtualenv
      lxml
      python-utils
    ]);

  buildInputs = [
    eigen
    libXtst
    libepoxy
    libxkbcommon
    libdatrie
    libthai
    libsepol
    libselinux
    util-linux
    pcre2
    pcre
    fontconfig
    tbb_2021_8
    libX11
    libXft
    libXdmcp
    libxcb
    cairo
    gtk3
    tcl
    readline
    openssl
    libffi
  ];

  postPatch = ''
    substituteInPlace libs/libvtrcapnproto/CMakeLists.txt \
      --replace "@java-schema@" ${java-schema}
    substituteInPlace yosys/Makefile \
      --replace "@git.rev@" ${src.rev}

    # TODO: fix this upstream
    # This prevents from opening the link it self
    substituteInPlace \
      libs/EXTERNAL/capnproto/c++/src/kj/filesystem-disk-unix.c++ \
      libs/EXTERNAL/capnproto/c++/ekam-provider/canonical/kj/filesystem-disk-unix.c++ \
      libs/EXTERNAL/capnproto/c++/ekam-provider/c++header/kj/filesystem-disk-unix.c++ \
      --replace "AT_SYMLINK_NOFOLLOW" "0"
  '';

  postInstall = ''
    mkdir $out/lib
    mv $out/bin/*.a $out/lib
  '';

  doCheck = true;

  passthru = { inherit java-schema; };
}
