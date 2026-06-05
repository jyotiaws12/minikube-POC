# Ollama Multi-Agent Demo

Three local LLM agents (powered by [Ollama](https://ollama.com)) collaborate to
ship a software feature end-to-end:

| Agent | Role | What it does |
|-------|------|--------------|
| **Pat the PM** | Product Manager | Turns a one-line feature idea into a concrete spec (API, edge cases, examples). |
| **Dev the Developer** | Engineer | Implements the spec as a single Python module. |
| **Tess the Tester** | QA | Writes a `pytest` suite from the spec, runs it, and reports. |

If the tests fail, the failure output is fed **back to the team**: the Tester
first repairs any bugs in its own suite, then the Developer fixes the
implementation. They retry up to `--max-fix-attempts` times — a small but real
agent feedback loop.

```
feature idea ──▶ PM (spec) ──▶ Developer (code) ──▶ Tester (tests + run)
                                     ▲                       │
                                     └──── failures ◀────────┘
```

## Requirements

- Python 3.10+
- [Ollama](https://ollama.com) installed and running
- A pulled model (default `qwen2.5-coder:3b` — a code-specialized model that
  produces far more reliable Python than small general models)

```bash
# install ollama (linux); see ollama.com for mac/windows
curl -fsSL https://ollama.com/install.sh | sh
ollama pull qwen2.5-coder:3b   # or a smaller/faster one, e.g. llama3.2:3b

# python deps (only pytest, used to run the generated tests)
pip install -r requirements.txt
```

## Run it

```bash
# default feature: a calculator
python main.py

# or your own feature idea / model
python main.py --feature "a temperature converter (celsius/fahrenheit/kelvin)" --model qwen2.5-coder:3b
```

Generated artifacts land in `./workspace/`:

- `spec.md` — the PM's specification
- `<feature>.py` — the Developer's implementation
- `test_<feature>.py` — the Tester's suite

Exit code is `0` when the generated tests pass, `1` otherwise.

## Project layout

```
main.py                         CLI entrypoint
src/multi_agent/
  ollama_client.py              stdlib-only Ollama HTTP client
  orchestrator.py               wires the three agents + feedback loop
  utils.py                      code-block extraction helpers
  agents/
    base.py                     Agent persona (role + system prompt)
    product_manager.py          writes the spec
    developer.py                writes / fixes the implementation
    tester.py                   writes + runs the pytest suite
tests/test_pipeline.py          deterministic tests (fake client, no Ollama)
```

## Tests

The repo's own tests use a fake client, so they run without Ollama:

```bash
pytest -q
```
