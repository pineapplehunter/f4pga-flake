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
  version = "0.0-583-t1e53270-unstable-2024-09-28";

  src = fetchFromGitHub {
    owner = "f4pga";
    repo = "prjxray";
    rev = "f2d21573c7f6bdfa98e86fae5a2f5ef52e23b51c";
    hash = "sha256-Ld4oo8Ha+78jZZK76KP8W5GObt4LLb3h58OZ9eJDRrQ=";
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
      --replace "git" "# git" \
      --replace "\$(MAKE)" "\$(MAKE) -j$NIX_BUILD_CORES" \
      --replace "cmake" "cmake -DCMAKE_INSTALL_PREFIX:PATH=$out"
  '';

  buildFlags = [ "build" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

}
