{
  fetchFromGitHub,
  stdenv,
  nix-update-script,
  cmake,
  gflags,
  abseil-cpp,
}:

stdenv.mkDerivation {
  pname = "prjxray-tools";
  version = "0.1-unstable-2025-06-05";

  src = fetchFromGitHub {
    owner = "f4pga";
    repo = "prjxray";
    rev = "c9f02d8576042325425824647ab5555b1bc77833";
    hash = "sha256-cuqjVLTy9JZxuoD8vPsRfSFCv/HhhSdburx1a9EJajM=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [
    gflags
    abseil-cpp
  ];

  dontUseCmakeConfigure = true;
  enableParallelBuilding = true;

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail "git" "# git" \
      --replace-fail "\$(MAKE)" "\$(MAKE) -j$NIX_BUILD_CORES" \
      --replace-fail "cmake" "cmake -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DCMAKE_INSTALL_PREFIX:PATH=$out"
    substituteInPlace CMakeLists.txt \
      --replace-fail 'add_compile_options(-Wall -Werror)' 'add_compile_options(-Wall)'
    sed -i '1i#include <cstdint>' lib/include/prjxray/memory_mapped_file.h
  '';

  buildFlags = [ "build" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

}
