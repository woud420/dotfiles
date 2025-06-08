#!/usr/bin/env python3
"""Generate tools.yaml for Cursor from brew packages and shell aliases."""

from __future__ import annotations

import json
import os
import subprocess
from pathlib import Path


def get_brew_packages() -> list[str]:
    """Return a sorted list of installed Homebrew formula packages."""
    brew = subprocess.run(["which", "brew"], capture_output=True, text=True)
    if brew.returncode != 0 or not brew.stdout.strip():
        return []

    try:
        result = subprocess.run([
            "brew",
            "list",
            "--formula",
        ], capture_output=True, text=True, check=True)
    except subprocess.CalledProcessError:
        return []
    packages = [line.strip() for line in result.stdout.splitlines() if line.strip()]
    return sorted(packages)


def get_shell_aliases() -> dict[str, str]:
    """Return shell aliases available in an interactive bash shell."""
    try:
        result = subprocess.run(
            ["bash", "-ic", "alias"], capture_output=True, text=True, check=True
        )
    except subprocess.CalledProcessError:
        return {}
    aliases: dict[str, str] = {}
    for line in result.stdout.splitlines():
        if not line.startswith("alias "):
            continue
        # alias ll='ls -l'
        try:
            name, value = line[6:].split("=", 1)
        except ValueError:
            continue
        value = value.strip()
        if (value.startswith("'") and value.endswith("'")) or (
            value.startswith('"') and value.endswith('"')
        ):
            value = value[1:-1]
        aliases[name.strip()] = value
    return aliases


def dump_yaml(data: dict) -> str:
    """Return YAML representation of the provided data.

    Falls back to JSON if PyYAML is not available.
    """
    try:
        import yaml  # type: ignore

        return yaml.safe_dump(data, sort_keys=False)
    except Exception:
        return json.dumps(data, indent=2)


def main() -> None:
    data = {
        "brew_packages": get_brew_packages(),
        "aliases": get_shell_aliases(),
    }
    out_path = Path.home() / ".config/cursor/generated/tools.yaml"
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(dump_yaml(data))
    print(f"Wrote {out_path}")


if __name__ == "__main__":
    main()
