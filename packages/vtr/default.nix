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
  java-schema = fetchurl rec {
    # master version
    version = "b2f7242c2d833eb499fd9734132642d571b02a74";
    url = "https://raw.githubusercontent.com/capnproto/capnproto-java/${version}/compiler/src/main/schema/capnp/java.capnp";
    hash = "sha256-q8SNhZ/6Bqwmx9/mAgN0+w7l76STZwerw1vawiM676s=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "vtr";
  version = "9.0.0";

  src = fetchFromGitHub {
    owner = "verilog-to-routing";
    repo = "vtr-verilog-to-routing";
    rev = "refs/tags/v${finalAttrs.version}";
    hash = "sha256-g5pDGy6A0e1gHFU64G7NcTAGiUj8vfyhJkQ3++4Y2yw=";
    fetchSubmodules = true;
  };

  patches = [
    (replaceVars ./nowget.patch {
      javaschema = java-schema;
    })
  ];

  postPatch = ''
    # GCC 15 no longer provides these transitive standard-library includes.
    if [[ -e libs/libarchfpga/src/read_xml_arch_file_noc_tag.cpp ]]; then
      substituteInPlace libs/libarchfpga/src/read_xml_arch_file_noc_tag.cpp \
        --replace-fail '#include "read_xml_arch_file_noc_tag.h"' $'#include <sstream>\n\n#include "read_xml_arch_file_noc_tag.h"'
    fi
    for json11 in yosys/libs/json11/json11.cpp libs/EXTERNAL/libyosys/libs/json11/json11.cpp; do
      if [[ -e "$json11" ]]; then
        substituteInPlace "$json11" \
          --replace-fail '#include "json11.hpp"' $'#include "json11.hpp"\n#include <cstdint>'
      fi
    done
    if [[ -e libs/librtlnumber/src/include/rtl_utils.hpp ]]; then
      substituteInPlace libs/librtlnumber/src/include/rtl_utils.hpp \
        --replace-fail '#include <string.h>' $'#include <string.h>\n#include <cstdint>'
    fi
    if [[ -e libs/EXTERNAL/libcatch2/src/catch2/catch_test_case_info.hpp ]]; then
      substituteInPlace libs/EXTERNAL/libcatch2/src/catch2/catch_test_case_info.hpp \
        --replace-fail '#include <string>' $'#include <cstdint>\n#include <string>'
      substituteInPlace libs/EXTERNAL/libcatch2/src/catch2/internal/catch_xmlwriter.cpp \
        --replace-fail '#include <iomanip>' $'#include <cstdint>\n#include <iomanip>'

      for file in \
        libs/libvtrutil/src/vtr_string_interning.h \
        libs/librrgraph/src/base/rr_node_types.h \
        libs/libarchfpga/src/arch_check.h; do
        sed -i '1i#include <cstdint>' "$file"
      done
      for file in \
        libs/libarchfpga/src/arch_check.cpp \
        libs/libarchfpga/src/read_fpga_interchange_arch.cpp \
        vpr/src/base/read_interchange_netlist.cpp \
        vpr/src/base/vpr_types.cpp; do
        sed -i '1i#include <sstream>' "$file"
      done
      if grep -Fq 'bool operator()(char const* a, char const* b) {' utils/vqm2blif/src/base/preprocess.h; then
        substituteInPlace utils/vqm2blif/src/base/preprocess.h \
          --replace-fail 'bool operator()(char const* a, char const* b) {' 'bool operator()(char const* a, char const* b) const {'
      fi
    fi

    # Follow Nix store symlinks when determining the mapped file size.
    substituteInPlace libs/libvtrcapnproto/mmap_file.cpp \
      --replace-fail $'        auto stat = dir.lstat(path);\n        auto f = dir.openFile(path);' $'        auto f = dir.openFile(path);\n        auto stat = f->stat();'
  '';

  nativeBuildInputs = [
    (python3.withPackages (ps: with ps; [ prettytable ]))
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

  cmakeFlags = [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];

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

  meta.platforms = lib.platforms.linux;
})
