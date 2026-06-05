"""Product Manager agent: turns a feature idea into a written spec."""

from __future__ import annotations

from ..ollama_client import OllamaClient
from .base import Agent

SYSTEM_PROMPT = """You are a pragmatic Product Manager.
Given a short feature idea, you write a concise, unambiguous specification for a
single Python module. Keep it implementable in one file with a small public API.

Your spec MUST include:
1. A one-paragraph overview.
2. The module/file name to create (snake_case, e.g. `calculator.py`).
3. A list of public functions or a class, each with: name, signature, behaviour,
   and edge cases (e.g. division by zero).
4. 3-6 concrete example input/output pairs the implementation must satisfy.

Be specific about function names and signatures so an engineer and a tester can
both rely on them. Do NOT write the implementation or the tests yourself."""


def build(client: OllamaClient) -> Agent:
    return Agent(
        name="Pat the PM",
        role="product_manager",
        system_prompt=SYSTEM_PROMPT,
        client=client,
    )


def write_spec(agent: Agent, feature_idea: str) -> str:
    prompt = (
        f"Feature idea: {feature_idea}\n\n"
        "Write the specification following your required format."
    )
    return agent.respond(prompt)
