"""Developer agent: implements a spec as a single Python module."""

from __future__ import annotations

from ..ollama_client import OllamaClient
from ..utils import extract_code_block
from .base import Agent

SYSTEM_PROMPT = """You are a senior Python engineer.
You implement a specification as a SINGLE, self-contained Python module.

Rules:
- Output ONLY one Python code block (```python ... ```), nothing else.
- No external dependencies; standard library only.
- Match the exact function/class names and signatures from the spec.
- Handle the edge cases the spec calls out (raise ValueError where sensible).
- Write clean, readable code with type hints."""


def build(client: OllamaClient) -> Agent:
    return Agent(
        name="Dev the Developer",
        role="developer",
        system_prompt=SYSTEM_PROMPT,
        client=client,
    )


def write_implementation(agent: Agent, spec: str, module_name: str) -> str:
    prompt = (
        f"Specification:\n{spec}\n\n"
        f"Implement this as `{module_name}`. Output only the Python code block."
    )
    return extract_code_block(agent.respond(prompt), language="python")


def fix_implementation(
    agent: Agent,
    spec: str,
    module_name: str,
    code: str,
    test_code: str,
    failure: str,
) -> str:
    prompt = (
        f"Specification:\n{spec}\n\n"
        f"Your current `{module_name}` implementation:\n```python\n{code}\n```\n\n"
        f"The test suite (`{module_name}` is imported by it):\n```python\n{test_code}\n```\n\n"
        f"Running the tests produced this failure output:\n{failure}\n\n"
        "Fix the implementation so all tests pass. Keep the same public API. "
        "Output only the corrected Python code block."
    )
    return extract_code_block(agent.respond(prompt), language="python")
