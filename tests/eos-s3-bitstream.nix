{
  f4pga-eos-s3,
  runCommand,
}:

runCommand "f4pga-eos-s3-bitstream-test"
  {
    strictDeps = true;
    __structuredAttrs = true;
    nativeBuildInputs = [ f4pga-eos-s3 ];
  }
  ''
    cp -r ${./eos-s3-bitstream} source
    chmod -R u+w source
    cd source

    f4pga-eos-s3 build --flow flow.json

    test -s build/top.bit
    mkdir -p $out
    cp build/top.bit $out/top.bit
  ''
