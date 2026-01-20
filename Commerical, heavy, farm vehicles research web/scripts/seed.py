#!/usr/bin/env python3
"""
Wrapper to run the consolidated seed pipeline.
"""
from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path


def main() -> None:
    mode = os.getenv("MODE", "medium")
    root = Path(__file__).resolve().parent.parent
    script = root / "apps" / "api" / "seed" / "seed.py"
    env_path = root / "apps" / "api" / ".env"
    env = os.environ.copy()
    if env_path.exists():
        # Lightweight .env loader (avoid extra dependency)
        for line in env_path.read_text().splitlines():
            if line.strip().startswith("#") or "=" not in line:
                continue
            key, value = line.split("=", 1)
            env.setdefault(key.strip(), value.strip())
    env["PYTHONPATH"] = str(root)
    cmd = [sys.executable, str(script), "--mode", mode]
    subprocess.check_call(cmd, env=env, cwd=root)


if __name__ == "__main__":
    main()
