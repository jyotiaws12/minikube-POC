"""Shared helpers for parsing LLM output."""

from __future__ import annotations

import re

_FENCE_RE = re.compile(r"```(?:[a-zA-Z0-9_+-]*)\n(.*?)```", re.DOTALL)


def extract_code_block(text: str, *, language: str | None = None) -> str:
    """Extract the first fenced code block from LLM output.

    Falls back to returning the whole text (stripped) when no fence is present,
    since small models sometimes emit bare code. When ``language`` is given we
    prefer a fence tagged with that language but still fall back to the first.
    """
    if language:
        tagged = re.compile(rf"```{re.escape(language)}\n(.*?)```", re.DOTALL)
        match = tagged.search(text)
        if match:
            return match.group(1).strip()

    match = _FENCE_RE.search(text)
    if match:
        return match.group(1).strip()
    return text.strip()
