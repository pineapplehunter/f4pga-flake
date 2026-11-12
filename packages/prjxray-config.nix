{
  lib,
  fetchFromGitHub,
  writeShellApplication,
}:

let
  database = fetchFromGitHub {
    owner = "f4pga";
    repo = "prjxray-db";
    rev = "0a0addedd73e7e4139d52a6d8db4258763e0f1f3";
    hash = "sha256-cU30ZtT+Olkcxzf/vopCT2d4IBG5vU9K3hHIvvy466c=";
  };
in
writeShellApplication {
  name = "prjxray-config";

  text = ''
    echo "${database}"
  '';

  meta = {
    description = "Print the Project X-Ray database directory";
    homepage = "https://github.com/f4pga/prjxray-db";
    license = lib.licenses.cc0;
    platforms = lib.platforms.all;
    mainProgram = "prjxray-config";
  };
}
