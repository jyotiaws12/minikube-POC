"""Minimal Ollama chat client built on the stdlib (no third-party deps).

Talks to a local Ollama server over its HTTP API. Defaults to the standard
``http://localhost:11434`` endpoint but honours the ``OLLAMA_HOST`` env var.
"""

from __future__ import annotations

import json
import os
import urllib.error
import urllib.request
from dataclasses import dataclass, field


class OllamaError(RuntimeError):
    """Raised when the Ollama server cannot be reached or returns an error."""


@dataclass
class ChatMessage:
    role: str
    content: str

    def as_dict(self) -> dict[str, str]:
        return {"role": self.role, "content": self.content}


@dataclass
class OllamaClient:
    """Tiny wrapper around the Ollama ``/api/chat`` endpoint."""

    model: str = "qwen2.5-coder:3b"
    host: str = field(default_factory=lambda: os.environ.get("OLLAMA_HOST", "http://localhost:11434"))
    temperature: float = 0.2
    timeout: float = 600.0

    def chat(self, messages: list[ChatMessage], temperature: float | None = None) -> str:
        """Send a list of chat messages and return the assistant's reply text."""
        payload = {
            "model": self.model,
            "messages": [m.as_dict() for m in messages],
            "stream": False,
            "options": {"temperature": self.temperature if temperature is None else temperature},
        }
        url = f"{self.host.rstrip('/')}/api/chat"
        data = json.dumps(payload).encode("utf-8")
        request = urllib.request.Request(url, data=data, headers={"Content-Type": "application/json"})
        try:
            with urllib.request.urlopen(request, timeout=self.timeout) as response:
                body = json.loads(response.read().decode("utf-8"))
        except urllib.error.HTTPError as exc:  # pragma: no cover - network error path
            detail = exc.read().decode("utf-8", "replace")
            raise OllamaError(f"Ollama returned HTTP {exc.code}: {detail}") from exc
        except urllib.error.URLError as exc:  # pragma: no cover - network error path
            raise OllamaError(
                f"Could not reach Ollama at {self.host}. Is `ollama serve` running? ({exc.reason})"
            ) from exc

        message = body.get("message", {})
        content = message.get("content", "")
        if not content:
            raise OllamaError(f"Ollama returned an empty response: {body!r}")
        return content

    def is_available(self) -> bool:
        """Return True if the Ollama server responds on ``/api/tags``."""
        url = f"{self.host.rstrip('/')}/api/tags"
        try:
            with urllib.request.urlopen(url, timeout=10) as response:
                return response.status == 200
        except (urllib.error.URLError, urllib.error.HTTPError):
            return False
