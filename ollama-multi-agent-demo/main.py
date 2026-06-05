"""CLI entrypoint for the Ollama multi-agent demo.

Example:
    python main.py --feature "a calculator with add, subtract, multiply, divide"
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent / "src"))

from multi_agent.ollama_client import OllamaClient  # noqa: E402
from multi_agent.orchestrator import run_pipeline  # noqa: E402

DEFAULT_FEATURE = (
    "a calculator module that supports add, subtract, multiply and divide on two "
    "numbers, raising an error on division by zero"
)


def main() -> int:
    parser = argparse.ArgumentParser(description="Multi-agent feature factory powered by Ollama.")
    parser.add_argument("--feature", default=DEFAULT_FEATURE, help="The feature idea to build.")
    parser.add_argument("--model", default="qwen2.5-coder:3b", help="Ollama model name.")
    parser.add_argument("--workspace", default="workspace", help="Directory for generated artifacts.")
    parser.add_argument("--max-fix-attempts", type=int, default=2, help="Developer retry budget.")
    args = parser.parse_args()

    client = OllamaClient(model=args.model)
    if not client.is_available():
        print(
            f"ERROR: Cannot reach Ollama at {client.host}.\n"
            "Start it with `ollama serve` and pull the model, e.g. `ollama pull "
            f"{args.model}`.",
            file=sys.stderr,
        )
        return 2

    print(f"Multi-agent run using model '{args.model}'.")
    print(f"Feature request: {args.feature}\n")

    result = run_pipeline(
        args.feature,
        client=client,
        workspace=Path(args.workspace),
        max_fix_attempts=args.max_fix_attempts,
    )

    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print(f"Feature : {result.feature_idea}")
    print(f"Module  : {result.module_name}")
    print(f"Result  : {'PASSED' if result.passed else 'FAILED'}")
    print(f"Fixes   : {result.iterations}")
    print(f"Artifacts written to: {Path(args.workspace).resolve()}")
    return 0 if result.passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
