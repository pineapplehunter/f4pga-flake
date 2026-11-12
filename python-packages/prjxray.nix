{
  lib,
  buildPythonPackage,
  fasm,
  intervaltree,
  numpy,
  prjxray-tools,
  pyjson5,
  pyyaml,
  setuptools,
  simplejson,
}:

buildPythonPackage {
  pname = "prjxray";
  # Keep the Python library and native tools on the same database/API revision.
  # Update the shared source through prjxray-tools.
  inherit (prjxray-tools) src version;
  pyproject = true;

  build-system = [ setuptools ];

  dependencies = [
    fasm
    intervaltree
    numpy
    pyjson5
    pyyaml
    simplejson
  ];

  pythonImportsCheck = [
    "prjxray"
    "prjxray.fasm_assembler"
  ];

  meta = {
    description = "Python library for the Project X-Ray Xilinx 7-series database";
    homepage = "https://github.com/f4pga/prjxray";
    license = lib.licenses.isc;
  };
}
