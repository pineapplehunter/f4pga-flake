{
  lib,
  fetchzip,
}:
let
  fpga-package-hashes = {
    "install-xc7" = "sha256-Qebio1S71y8Uht1soFnJBVSXb0t9dI7jQ2It2ipEXgY=";
    "xc7a50t_test" = "sha256-Cz/tRG5fqgS1qDTVN9Ym05jMjHC12QZdaz7AbiUt/a8=";
    "xc7a100t_test" = "sha256-hO8ZffeCcmTku+gASu65HmkgNkw7UZODdxVz94YcfRY=";
    "xc7a200t_test" = "sha256-LkeuP11YYjO6BQAVdY7A8S20cWqsQFt6nIffHcDUPkw=";
    "xc7z010_test" = "sha256-Q3AlLsW9p5NScry/43NC8MOMt5jmGbRnf5urKADeNPk=";
    "install-ql" = "sha256-vi96gg86BURdmYP1lMKmVQ99ydaNYpTHISr1pYZUNDE=";
    "ql-eos-s3_wlcsp" = "sha256-u+F/kizkj9pED6wo3JSOg6vrtwo2+KGysWAD5u1P2Vo=";
  };

  fpga-timestamp = "20230411-180123";
  fpga-hash = "5e974a8";

  fetchDefFile =
    name: hash:
    fetchzip {
      inherit name;
      url = "https://storage.googleapis.com/symbiflow-arch-defs/artifacts/prod/foss-fpga-tools/symbiflow-arch-defs/continuous/install/${fpga-timestamp}/symbiflow-arch-defs-${name}-${fpga-hash}.tar.xz";
      inherit hash;
      stripRoot = false;
    };

in
{
  timestamp = fpga-timestamp;
  hash = fpga-hash;
}
// lib.attrsets.mapAttrs fetchDefFile fpga-package-hashes
