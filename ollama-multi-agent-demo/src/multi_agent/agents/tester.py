"""Tester agent: writes a pytest suite for the spec and runs it."""

from __future__ import annotations

import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path

from ..ollama_client import OllamaClient
from ..utils import extract_code_block
from .base import Agent

SYSTEM_PROMPT = """You are a meticulous QA engineer.
You write a pytest test suite that verifies an implementation against its spec.

Rules:
- Output ONLY one Python code block (```python ... ```), nothing else.
- ALWAYS start the file with `import pytest` followed by importing the module
  under test by its module name (e.g. `import calculator`).
- Use plain `pytest` (no third-party plugins) and the `assert` statement.
- Cover the happy path AND the edge cases from the spec. Use `pytest.raises` for
  error conditions, referencing the real exception type (e.g.
  `pytest.raises(ZeroDivisionError)`), NOT `module.ZeroDivisionError`.
- Tests must rely only on the public API described in the spec."""


@dataclass
class TestRunResult:
    passed: bool
    output: str


def build(client: OllamaClient) -> Agent:
    return Agent(
        name="Tess the Tester",
        role="tester",
        system_prompt=SYSTEM_PROMPT,
        client=client,
    )


def write_tests(agent: Agent, spec: str, module_name: str) -> str:
    module_import = Path(module_name).stem
    prompt = (
        f"Specification:\n{spec}\n\n"
        f"Write a pytest suite (in a file `test_{module_import}.py`) that imports "
        f"`{module_import}` and verifies the spec. Output only the Python code block."
    )
    return extract_code_block(agent.respond(prompt), language="python")


def fix_tests(agent: Agent, spec: str, module_name: str, code: str, test_code: str, failure: str) -> str:
    module_import = Path(module_name).stem
    prompt = (
        f"Specification:\n{spec}\n\n"
        f"The implementation under test (`{module_name}`):\n```python\n{code}\n```\n\n"
        f"Your current test suite:\n```python\n{test_code}\n```\n\n"
        f"Running the suite produced this output:\n{failure}\n\n"
        "Some failures may be bugs in the TESTS themselves (e.g. a missing "
        f"`import pytest`, or asserting wrong expected values). Correct ONLY the "
        f"tests so they faithfully verify the spec against `{module_import}`. Do "
        "not weaken assertions just to pass. Output only the corrected Python "
        "code block."
    )
    return extract_code_block(agent.respond(prompt), language="python")


def run_tests(workspace: Path, test_filename: str) -> TestRunResult:
    """Run pytest on a single test file inside ``workspace``."""
    proc = subprocess.run(
        [sys.executable, "-m", "pytest", test_filename, "-q", "--no-header"],
        cwd=workspace,
        capture_output=True,
        text=True,
        timeout=120,
    )
    output = (proc.stdout + "\n" + proc.stderr).strip()
    return TestRunResult(passed=proc.returncode == 0, output=output)
