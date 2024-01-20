{ stdenv, fetchFromGitHub }: stdenv.mkDerivation {
  pname = "prjxray-config";
  version = "unstable-2021-12-14";

  src = fetchFromGitHub {
    owner = "f4pga";
    repo = "prjxray-db";
    rev = "0a0addedd73e7e4139d52a6d8db4258763e0f1f3";
    hash = "sha256-cU30ZtT+Olkcxzf/vopCT2d4IBG5vU9K3hHIvvy466c=";
  };

  runScript = ''
    #!${stdenv.shell}

    echo ${placeholder "out"}/share/prjxray/database
  '';

  passAsFile = [ "runScript" ];

  buildPhase = "true";

  installPhase = ''
    install -dm 755 $out/share/prjxray/database
    cp -r artix7 kintex7 spartan7 zynq7 $out/share/prjxray/database/
    install -Dm 755 $runScriptPath $out/bin/prjxray-config
  '';

}
