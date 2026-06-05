"""A tiny multi-agent demo on top of Ollama.

Three agents collaborate to ship a feature:
- Product Manager: writes the spec.
- Developer: implements it.
- Tester: writes and runs a pytest suite, feeding failures back to the Developer.
"""

from .ollama_client import OllamaClient
from .orchestrator import PipelineResult, run_pipeline

__all__ = ["OllamaClient", "PipelineResult", "run_pipeline"]
