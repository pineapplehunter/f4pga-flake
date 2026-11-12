"""Packaging regressions that do not need architecture bundles or boards."""

import os
from pathlib import Path
import subprocess
import sys
import tempfile
from types import SimpleNamespace

from f4pga.flows.common import ResolutionEnv
from f4pga.flows.modules.generic_script_wrapper import GenericScriptWrapperModule


def make_stage(inputs):
    stage = GenericScriptWrapperModule.__new__(GenericScriptWrapperModule)
    stage.takes = []
    stage.values = []
    stage._init_inputs(inputs)
    return stage


ctx = SimpleNamespace(r_env=ResolutionEnv({}))
assert make_stage({}).get_env(ctx) is None

os.environ["F4PGA_PACKAGING_PROBE"] = "inherited"
inherited_path = os.environ["PYTHONPATH"]
env = make_stage({"$F4PGA_PACKAGING_PROBE": "stage"}).get_env(ctx)
assert env["F4PGA_PACKAGING_PROBE"] == "stage"
assert env["PATH"] == os.environ["PATH"]
assert env["PYTHONPATH"] == inherited_path
assert os.environ["F4PGA_PACKAGING_PROBE"] == "inherited"

with tempfile.TemporaryDirectory() as architecture_dir:
    Path(architecture_dir, "architecture_probe.py").write_text("value = 'architecture'\n")
    stage = make_stage({"$PYTHONPATH": architecture_dir})
    env = stage.get_env(ctx)
    assert env["PYTHONPATH"] == architecture_dir + os.pathsep + inherited_path
    assert stage.get_env(ctx) == env  # Repeated calls must not append the path again.
    subprocess.run(
        [
            sys.executable,
            "-c",
            "import architecture_probe, f4pga, constraint, quicklogic_fasm; "
            "assert architecture_probe.value == 'architecture'",
        ],
        env=env,
        check=True,
    )

assert os.environ["PYTHONPATH"] == inherited_path
print("F4PGA subprocess environment: PASS")
