"""Refresh the packaged Typst runtime and optionally build a portable ZIP."""
from __future__ import annotations

import argparse
from pathlib import Path
import shutil
import subprocess
import sys
import zipfile


HERE = Path(__file__).resolve().parent
REPO = HERE.parents[1]
PACKAGE = HERE / "src/satz_journal"


def refresh_runtime() -> None:
    target = PACKAGE / "runtime"
    shutil.rmtree(target, ignore_errors=True)
    target.mkdir(parents=True)
    # Only the public runtime and its local Typst dependencies are shipped.
    for path in sorted(REPO.rglob("*.typ")):
        relative = path.relative_to(REPO)
        if any(part.startswith(".") for part in relative.parts):
            continue
        if relative.parts[0] in {"testing", "workbook-conversion", "examples", "tools", "docs"}:
            continue
        if "example" in path.name.lower() or path.name.endswith("-test.typ"):
            continue
        output = target / relative
        output.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(path, output)
    shutil.copyfile(REPO / "LICENSE", target / "LICENSE")
    version = "unknown"
    for line in (REPO / "typst.toml").read_text(encoding="utf-8").splitlines():
        if line.startswith("version ="):
            version = line.split('"')[1]
            break
    try:
        commit = subprocess.check_output(["git", "rev-parse", "--short", "HEAD"], cwd=REPO, text=True).strip()
    except Exception:
        commit = "working-tree"
    (target / "VERSION.txt").write_text(f"Satz {version}\nSource revision: {commit}\n", encoding="utf-8")


def build_zip(output: Path) -> None:
    # Build a temporary project using the same code users will invoke.
    sys.path.insert(0, str(PACKAGE.parent))
    from satz_journal.cli import init_project
    import tempfile
    with tempfile.TemporaryDirectory() as temporary:
        project = Path(temporary) / "satz-journal-starter"
        init_project(project)
        output.parent.mkdir(parents=True, exist_ok=True)
        with zipfile.ZipFile(output, "w", zipfile.ZIP_DEFLATED) as archive:
            for path in project.rglob("*"):
                if path.is_file():
                    archive.write(path, Path(project.name) / path.relative_to(project))


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--zip", type=Path, help="also generate a starter ZIP at this path")
    args = parser.parse_args()
    if args.zip:
        refresh_runtime()
        build_zip(args.zip)
        print(f"Starter ZIP written to {args.zip}")
    else:
        refresh_runtime()
        print(f"Packaged Satz runtime refreshed: {PACKAGE / 'runtime'}")


if __name__ == "__main__":
    main()
