"""Fail early when the release-check runner lacks fonts used by its fixtures."""

from __future__ import annotations

import subprocess
import sys


REQUIRED_FONTS = ("Arial", "Fira Code", "STIX Two Math", "STIX Two Text")


def main() -> None:
    result = subprocess.run(
        ["typst", "fonts"], capture_output=True, text=True, check=True
    )
    available = set(result.stdout.splitlines())
    missing = [font for font in REQUIRED_FONTS if font not in available]
    if missing:
        print(
            "Missing Typst fonts required by representative-document checks: "
            + ", ".join(missing),
            file=sys.stderr,
        )
        raise SystemExit(1)
    print("All fonts required by representative-document checks are available.")


if __name__ == "__main__":
    main()
