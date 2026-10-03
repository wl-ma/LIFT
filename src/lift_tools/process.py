"""Bounded subprocess execution; terminate the process group on POSIX timeout."""

from __future__ import annotations

import os
import signal
import subprocess
from pathlib import Path


def run(
    command: list[str], *, cwd: Path, timeout: float
) -> subprocess.CompletedProcess:
    process = subprocess.Popen(
        command,
        cwd=cwd,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        start_new_session=os.name == "posix",
    )
    try:
        stdout, stderr = process.communicate(timeout=timeout)
    except subprocess.TimeoutExpired:
        if os.name == "posix":
            os.killpg(process.pid, signal.SIGKILL)
        else:
            process.kill()
        stdout, stderr = process.communicate()
        raise subprocess.TimeoutExpired(
            command, timeout, output=stdout, stderr=stderr
        ) from None
    return subprocess.CompletedProcess(command, process.returncode, stdout, stderr)
