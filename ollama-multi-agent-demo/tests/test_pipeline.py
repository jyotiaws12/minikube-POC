"""Tests for the deterministic parts of the demo (no Ollama required).

These use a fake client so the full PM -> Developer -> Tester pipeline can be
exercised in CI without a running Ollama server or model download.
"""

from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))

from multi_agent.orchestrator import _infer_module_name, run_pipeline  # noqa: E402
from multi_agent.utils import extract_code_block  # noqa: E402

SPEC = "Create `calculator.py` with add(a, b) and divide(a, b) (raise on zero)."

IMPL = '''```python
def add(a, b):
    return a + b


def divide(a, b):
    if b == 0:
        raise ValueError("division by zero")
    return a / b
```'''

TESTS = '''```python
import pytest
import calculator


def test_add():
    assert calculator.add(2, 3) == 5


def test_divide():
    assert calculator.divide(6, 2) == 3


def test_divide_by_zero():
    with pytest.raises(ValueError):
        calculator.divide(1, 0)
```'''


class FakeClient:
    """Returns canned responses keyed off the agent's system prompt."""

    host = "fake://"

    def chat(self, messages, temperature=None):
        system = messages[0].content
        if "Product Manager" in system:
            return SPEC
        if "Python engineer" in system:
            return IMPL
        if "QA engineer" in system:
            return TESTS
        raise AssertionError("unexpected agent system prompt")

    def is_available(self):
        return True


def test_extract_code_block_prefers_language():
    text = "blah\n```python\nx = 1\n```\ntrailing"
    assert extract_code_block(text, language="python") == "x = 1"


def test_extract_code_block_falls_back_to_raw():
    assert extract_code_block("just code, no fence") == "just code, no fence"


def test_infer_module_name():
    assert _infer_module_name("Build `calculator.py` please") == "calculator.py"
    assert _infer_module_name("no filename here", fallback="feature.py") == "feature.py"


def test_pipeline_end_to_end(tmp_path):
    result = run_pipeline(
        "a calculator",
        client=FakeClient(),
        workspace=tmp_path,
        max_fix_attempts=1,
        log=lambda *a, **k: None,
    )
    assert result.passed is True
    assert result.module_name == "calculator.py"
    assert (tmp_path / "calculator.py").exists()
    assert (tmp_path / "test_calculator.py").exists()
    assert (tmp_path / "spec.md").exists()
