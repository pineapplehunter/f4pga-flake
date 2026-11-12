{
  f4pga,
  runCommand,
  writeShellScript,
}:

let
  unexpectedTool = writeShellScript "unexpected-caller-tool" ''
    echo "F4PGA selected a tool from the caller's PATH" >&2
    exit 97
  '';
in
runCommand "f4pga-packaging-test"
  {
    strictDeps = true;
    __structuredAttrs = true;
    nativeBuildInputs = [ f4pga ];
  }
  ''
    mkdir fake-bin
    for tool in python3 yosys vpr prjxray-config xcfasm qlfasm qlf_fasm; do
      ln -s ${unexpectedTool} "fake-bin/$tool"
    done
    export PATH="$PWD/fake-bin:$PATH"

    # Exercise the generated wrapper's environment without running the CLI.
    source <(awk '/^exec / { exit } { print }' ${f4pga}/bin/f4pga)
    for tool in python3 yosys vpr prjxray-config xcfasm qlfasm qlf_fasm; do
      case "$(command -v "$tool")" in
        ${builtins.storeDir}/*/bin/*) ;;
        *) echo "Unpackaged tool selected: $tool" >&2; exit 1 ;;
      esac
    done

    python3 ${./f4pga-packaging.py}
    FPGA_FAM=xc7 symbiflow_pack --help > /dev/null
    FPGA_FAM=eos-s3 symbiflow_pack --help > /dev/null
    qlfasm --help > /dev/null
    qlf_fasm --help > /dev/null

    touch "$out"
  ''
