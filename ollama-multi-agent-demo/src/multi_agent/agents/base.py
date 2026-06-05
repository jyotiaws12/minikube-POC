"""Base agent: a named role with a system prompt backed by an Ollama model."""

from __future__ import annotations

from dataclasses import dataclass

from ..ollama_client import ChatMessage, OllamaClient


@dataclass
class Agent:
    name: str
    role: str
    system_prompt: str
    client: OllamaClient

    def respond(self, user_prompt: str, temperature: float | None = None) -> str:
        """Run a single-turn chat with this agent's persona."""
        messages = [
            ChatMessage(role="system", content=self.system_prompt),
            ChatMessage(role="user", content=user_prompt),
        ]
        return self.client.chat(messages, temperature=temperature)
