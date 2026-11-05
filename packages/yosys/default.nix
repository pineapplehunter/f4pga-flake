# Yosys 0.47 recipe from nixpkgs 5e4fbfb6b3de1aa2872b76d49fafc942626e2add,
# built with current nixpkgs dependencies. F4PGA only needs the CLI, not Pyosys.
{
  stdenv,
  lib,
  bison,
  callPackage,
  fetchFromGitHub,
  flex,
  libffi,
  makeWrapper,
  pkg-config,
  python3,
  readline,
  symlinkJoin,
  tcl,
  iverilog,
  zlib,
  yosys,
}:

let
  withPlugins =
    plugins:
    let
      paths = lib.closePropagation plugins;
      module_flags =
        with builtins;
        concatStringsSep " " (map (n: "--add-flags -m --add-flags ${n.plugin}") plugins);
    in
    lib.appendToName "with-plugins" (symlinkJoin {
      inherit (yosys) name;
      paths = paths ++ [ yosys ];
      nativeBuildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/yosys \
          --set NIX_YOSYS_PLUGIN_DIRS $out/share/yosys/plugins \
          ${module_flags}
      '';
      meta.mainProgram = "yosys";
    });

  # These plugins must be compiled against the same Yosys ABI.
  allPlugins = callPackage ./plugins.nix {
    inherit yosys;
    yosys-symbiflow = allPlugins;
  };

in
stdenv.mkDerivation (finalAttrs: {
  pname = "yosys-f4pga";
  version = "0.47";

  src = fetchFromGitHub {
    owner = "YosysHQ";
    repo = "yosys";
    rev = "refs/tags/${finalAttrs.version}";
    hash = "sha256-9u9aAPTZyt9vzZwryor3GRCGzs/mu2/XtM0XzV7uHfk=";
    fetchSubmodules = true;
    leaveDotGit = true;
    postFetch = ''
      # set up git hashes as if we used the tarball

      pushd $out
      git rev-parse HEAD > .gitcommit
      cd $out/abc
      git rev-parse HEAD > .gitcommit
      popd

      # remove .git now that we are through with it
      find "$out" -name .git -print0 | xargs -0 rm -rf
    '';
  };

  enableParallelBuilding = true;
  nativeBuildInputs = [
    pkg-config
    bison
    flex
  ];
  propagatedBuildInputs = [
    tcl
    readline
    libffi
    zlib
    (python3.withPackages (
      pp: with pp; [
        click
      ]
    ))
  ];

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  patches = [
    ./plugin-search-dirs.patch
    ./json11-cstdint.patch
    ./fix-clang-build.patch # see https://github.com/YosysHQ/yosys/issues/2011
  ];

  postPatch = ''
    substituteInPlace ./Makefile \
      --replace-fail 'echo UNKNOWN' 'echo ${builtins.substring 0 10 finalAttrs.src.rev}'

    patchShebangs tests ./misc/yosys-config.in
  '';

  preBuild = ''
    chmod -R u+w .
    make config-${if stdenv.cc.isClang or false then "clang" else "gcc"}

    if ! grep -q "YOSYS_VER := $version" Makefile; then
      echo "ERROR: yosys version in Makefile isn't equivalent to version of the nix package (allegedly ${finalAttrs.version}), failing."
      exit 1
    fi
  '';

  preCheck = ''
    # autotest.sh automatically compiles a utility during startup if it's out of date.
    # having N check jobs race to do that creates spurious codesigning failures on macOS.
    # run it once without asking it to do anything so that compilation is done before the jobs start.
    tests/tools/autotest.sh
  '';

  checkTarget = "test";
  doCheck = true;
  nativeCheckInputs = [ iverilog ];

  setupHook = ./setup-hook.sh;

  passthru = {
    inherit withPlugins allPlugins;
  };

  meta = with lib; {
    description = "F4PGA-compatible Yosys built with current nixpkgs";
    homepage = "https://yosyshq.net/yosys/";
    license = licenses.isc;
    platforms = platforms.all;
    maintainers = with maintainers; [
      shell
      thoughtpolice
      Luflosi
    ];
  };
})
