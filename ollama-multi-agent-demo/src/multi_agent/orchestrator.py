"""Orchestrates the PM -> Developer -> Tester collaboration loop."""

from __future__ import annotations

import re
from dataclasses import dataclass, field
from pathlib import Path

from .agents import developer, product_manager, tester
from .ollama_client import OllamaClient


def _infer_module_name(spec: str, fallback: str = "feature.py") -> str:
    """Pull the target module filename out of the PM's spec text."""
    match = re.search(r"([a-zA-Z_][a-zA-Z0-9_]*\.py)", spec)
    return match.group(1) if match else fallback


@dataclass
class PipelineResult:
    feature_idea: str
    module_name: str
    spec: str
    implementation: str
    tests: str
    passed: bool
    iterations: int
    test_output: str
    transcript: list[str] = field(default_factory=list)


def run_pipeline(
    feature_idea: str,
    *,
    client: OllamaClient,
    workspace: Path,
    max_fix_attempts: int = 2,
    log=print,
) -> PipelineResult:
    """Drive the three agents end-to-end and return the result.

    Flow: the PM writes a spec, the Developer implements it, the Tester writes
    and runs a pytest suite. On failure, the Developer gets the failure output
    and tries again, up to ``max_fix_attempts`` times.
    """
    workspace.mkdir(parents=True, exist_ok=True)
    transcript: list[str] = []

    pm = product_manager.build(client)
    dev = developer.build(client)
    qa = tester.build(client)

    log(f"\n=== [1/3] {pm.name} (Product Manager) is writing the spec ===")
    spec = product_manager.write_spec(pm, feature_idea)
    transcript.append(f"# Spec by {pm.name}\n\n{spec}")
    log(spec)

    module_name = _infer_module_name(spec)
    module_stem = Path(module_name).stem
    test_filename = f"test_{module_stem}.py"
    (workspace / "spec.md").write_text(spec, encoding="utf-8")

    log(f"\n=== [2/3] {dev.name} (Developer) is implementing `{module_name}` ===")
    implementation = developer.write_implementation(dev, spec, module_name)
    (workspace / module_name).write_text(implementation + "\n", encoding="utf-8")
    transcript.append(f"# Implementation by {dev.name}\n\n```python\n{implementation}\n```")
    log(implementation)

    log(f"\n=== [3/3] {qa.name} (Tester) is writing tests `{test_filename}` ===")
    tests = tester.write_tests(qa, spec, module_name)
    (workspace / test_filename).write_text(tests + "\n", encoding="utf-8")
    transcript.append(f"# Tests by {qa.name}\n\n```python\n{tests}\n```")
    log(tests)

    log("\n=== Running the test suite ===")
    result = tester.run_tests(workspace, test_filename)
    log(result.output)

    iterations = 0
    while not result.passed and iterations < max_fix_attempts:
        iterations += 1
        failure = result.output
        log(f"\n=== Tests failed. Fix round {iterations}/{max_fix_attempts} ===")

        log(f"--- {qa.name} reviewing the test suite for test-side bugs ---")
        tests = tester.fix_tests(qa, spec, module_name, implementation, tests, failure)
        (workspace / test_filename).write_text(tests + "\n", encoding="utf-8")
        transcript.append(f"# Test fix {iterations} by {qa.name}\n\n```python\n{tests}\n```")
        log(tests)

        log(f"--- {dev.name} fixing the implementation ---")
        implementation = developer.fix_implementation(
            dev, spec, module_name, implementation, tests, failure
        )
        (workspace / module_name).write_text(implementation + "\n", encoding="utf-8")
        transcript.append(
            f"# Code fix {iterations} by {dev.name}\n\n```python\n{implementation}\n```"
        )
        log(implementation)

        result = tester.run_tests(workspace, test_filename)
        log(result.output)

    status = "PASSED" if result.passed else "FAILED"
    log(f"\n=== Pipeline finished: {status} after {iterations} fix attempt(s) ===")

    return PipelineResult(
        feature_idea=feature_idea,
        module_name=module_name,
        spec=spec,
        implementation=implementation,
        tests=tests,
        passed=result.passed,
        iterations=iterations,
        test_output=result.output,
        transcript=transcript,
    )
