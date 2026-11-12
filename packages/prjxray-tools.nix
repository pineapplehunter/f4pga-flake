{
  lib,
  stdenv,
  fetchFromGitHub,
  abseil-cpp,
  cmake,
  gflags,
  nix-update-script,
}:

stdenv.mkDerivation {
  pname = "prjxray-tools";
  version = "0.1-unstable-2025-06-05";

  strictDeps = true;
  __structuredAttrs = true;

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

  patches = [ ./prjxray-tools-compiler-compat.patch ];

  cmakeFlags = [ (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.5") ];

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = {
    description = "Native tools for the Project X-Ray Xilinx 7-series database";
    homepage = "https://github.com/f4pga/prjxray";
    license = lib.licenses.isc;
    platforms = lib.platforms.linux;
  };
}
