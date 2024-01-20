{ fetchFromGitHub
, stdenv
, nix-update-script
, cmake
, gflags
, abseil-cpp
}:

stdenv.mkDerivation rec {
  pname = "prjxray-tools";
  version = "unstable-2024-01-13";

  src = fetchFromGitHub {
    owner = "f4pga";
    repo = "prjxray";
    rev = "01ce064d160a9d805366ef3756c40a990165d3a8";
    hash = "sha256-SWCce7zx11O525Z3T2RUVP0cqYOgGRXXgBnqn8PVVOs=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ gflags abseil-cpp ];

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
