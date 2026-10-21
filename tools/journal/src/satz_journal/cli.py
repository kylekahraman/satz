"""Create portable Satz journal projects and add entries without overwriting."""
from __future__ import annotations

import argparse
import datetime as dt
import json
import ntpath
import os
from pathlib import Path
import re
import shlex
import shutil
import subprocess
import sys
import tempfile
from importlib.resources import files


MARKER = "// --- end entries ---"


def config_dir() -> Path:
    if os.name == "nt":
        return Path(os.environ.get("APPDATA", Path.home() / "AppData/Roaming")) / "satz-journal"
    if sys.platform == "darwin":
        return Path.home() / "Library/Application Support/satz-journal"
    return Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config")) / "satz-journal"


def safe_component(value: str) -> str:
    value = value.strip().lower()
    value = re.sub(r"[^\w-]+", "-", value, flags=re.UNICODE).strip("-_")
    return value[:60] or "entry"


def typst_string(value: str) -> str:
    """Escape user text for a Typst quoted string."""
    value = value.replace("\\", "\\\\").replace('"', '\\"')
    return "\"" + value.replace("\r", "").replace("\n", "\\n") + "\""


def runtime_path() -> Path:
    return Path(str(files("satz_journal").joinpath("runtime")))


def init_project(destination: Path) -> None:
    destination = destination.expanduser().resolve()
    if destination.exists() and any(destination.iterdir()):
        raise ValueError(f"Destination already exists and is not empty: {destination}")
    runtime = runtime_path()
    if not runtime.is_dir() or not any(runtime.rglob("*.typ")):
        raise ValueError("The packaged Satz runtime is missing. Rebuild the starter from a Satz checkout.")
    destination.mkdir(parents=True, exist_ok=True)
    (destination / "entries").mkdir(exist_ok=True)
    (destination / ".vscode").mkdir(exist_ok=True)
    template_dir = files("satz_journal").joinpath("templates")
    for name in ("config.typ", "setup.typ", "cover.typ", "main.typ"):
        shutil.copyfile(str(template_dir.joinpath(name)), destination / name)
    today = dt.date.today()
    first_entry_path = f"entries/{today.isoformat()}-getting-started.typ"
    first_entry = template_dir.joinpath("first-entry.typ").read_text(encoding="utf-8")
    first_entry = first_entry.replace("{{DATE_DISPLAY}}", today.strftime("%A, %d/%m/%Y"))
    (destination / first_entry_path).write_text(first_entry, encoding="utf-8")
    main_source = (destination / "main.typ").read_text(encoding="utf-8")
    (destination / "main.typ").write_text(main_source.replace("{{FIRST_ENTRY_PATH}}", first_entry_path), encoding="utf-8")
    shutil.copyfile(str(template_dir.joinpath("extensions.json")), destination / ".vscode/extensions.json")
    shutil.copytree(runtime, destination / "_satz", dirs_exist_ok=True)
    (destination / ".gitignore").write_text("*.pdf\n", encoding="utf-8")
    (destination / "README.md").write_text(
        "# Your Satz research journal\n\n"
        "Open this folder in VS Code and install the recommended Tinymist extension. "
        "Open `main.typ` first, then choose **Typst: Preview** to see the whole journal. "
        "If you later open an entry and want its preview to stay on the whole journal, "
        "run **Typst: Pin Main** with `main.typ` active. Edit `config.typ` "
        "to change the cover identity, theme, layout, and paper size. Add entries "
        "in `entries/` and include them in `main.typ`. The `_satz/` folder keeps "
        "this starter self-contained. With the optional launcher installed, run "
        "`journal update-satz .` in this folder to refresh it from that helper's "
        "bundled runtime. See `_satz/VERSION.txt` "
        "for the bundled Satz source revision.\n",
        encoding="utf-8",
    )


def append_include(main: Path, relative: str) -> None:
    source = main.read_text(encoding="utf-8")
    line = f'#include "{relative}"'
    if line in source:
        return
    if MARKER not in source:
        raise ValueError(f"{main} is missing the entries marker: {MARKER}")
    updated = source.replace(MARKER, line + "\n" + MARKER, 1)
    with tempfile.NamedTemporaryFile("w", encoding="utf-8", dir=main.parent, delete=False) as tmp:
        tmp.write(updated)
        temp_name = tmp.name
    os.replace(temp_name, main)


def create_entry(project: Path, title: str, kind: str, keywords: str, date: dt.date | None = None) -> Path:
    project = project.expanduser().resolve()
    title = title.strip()
    kind = kind.strip().lower()
    if not title:
        raise ValueError("Title cannot be empty.")
    if kind not in {"meeting", "session", "notes"}:
        raise ValueError("Entry type must be meeting, session, or notes.")
    main = project / "main.typ"
    entries = project / "entries"
    if not main.is_file() or not entries.is_dir():
        raise ValueError(f"Not a journal project (expected main.typ and entries/): {project}")
    if MARKER not in main.read_text(encoding="utf-8"):
        raise ValueError(f"{main} is missing the entries marker: {MARKER}")
    date = date or dt.date.today()
    filename = f"{date.isoformat()}-{safe_component(title)}.typ"
    target = entries / filename
    relative = "entries/" + filename
    if target.exists():
        raise FileExistsError(f"Entry already exists; nothing was changed: {target}")
    weekday = date.strftime("%A")
    sections = {
        "meeting": (
            "  == Agenda\n  - Add agenda items here.\n\n"
            "  == What we talked about\n\n"
            "  == Outcomes\n\n"
            "  == Rationale\n\n"
            "  == Action Items\n  - [ ] Add an action item\n\n"
            "  == Questions\n"
        ),
        "session": (
            "  == Goal\n  Describe the goal for this session.\n\n"
            "  == Log\n\n"
            "  == Outcomes\n\n"
            "  == Rationale\n\n"
            "  == Next Steps\n  - [ ] Add the next step\n\n"
            "  == Questions\n"
        ),
        "notes": "  == Notes\n  Add your notes here.\n",
    }
    content = (
        '#import "../setup.typ": journal-entry\n\n'
        "#journal-entry(\n"
        f"  title: {typst_string(title)},\n"
        f"  date: {typst_string(weekday + ', ' + date.strftime('%d/%m/%Y'))},\n"
        f"  keywords: {typst_string(keywords)},\n"
        ")[\n"
        + sections[kind]
        + "]\n"
    )
    # Exclusive create protects existing entries. All validation happens first.
    with target.open("x", encoding="utf-8", newline="\n") as stream:
        stream.write(content)
    try:
        append_include(main, relative)
    except Exception:
        target.unlink(missing_ok=True)
        raise
    return target


def editor_command(
    project: Path,
    entry: Path,
    requested: str | None = None,
    *,
    windows: bool | None = None,
    which=None,
) -> list[str] | None:
    value = requested or os.environ.get("VISUAL") or os.environ.get("EDITOR") or "code"
    windows = os.name == "nt" if windows is None else windows
    which = which or shutil.which
    try:
        # shlex in non-POSIX mode preserves quotes and splits a quoted Windows
        # executable path at its spaces. Parse that first path explicitly.
        stripped = value.lstrip()
        if windows and stripped[:1] in {'"', "'"}:
            quote = stripped[0]
            end = stripped.find(quote, 1)
            if end < 0:
                return None
            executable = stripped[1:end]
            remaining = shlex.split(stripped[end + 1 :].strip(), posix=True)
            parts = [executable, *remaining]
        else:
            parts = shlex.split(value, posix=not windows)
    except ValueError:
        return None
    if not parts or which(parts[0]) is None:
        return None
    executable_name = ntpath.basename(parts[0]).lower() if windows else Path(parts[0]).name.lower()
    if executable_name in {"code", "code.exe", "code.cmd"}:
        return parts + ["--reuse-window", str(project), str(entry)]
    return parts + [str(entry)]


def open_editor(project: Path, entry: Path, requested: str | None = None) -> bool:
    command = editor_command(project, entry, requested)
    if command is None:
        return False
    subprocess.Popen(command)
    return True


def load_project(path: str | None) -> Path:
    if path:
        return Path(path).expanduser().resolve()
    saved = config_dir() / "project.json"
    if saved.exists():
        return Path(json.loads(saved.read_text(encoding="utf-8"))["path"])
    current = Path.cwd()
    if (current / "main.typ").is_file() and (current / "entries").is_dir():
        return current
    raise ValueError("No journal selected. Run `journal use PATH`, or run this inside a journal folder.")


def remember_project(path: Path) -> None:
    target = config_dir() / "project.json"
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(json.dumps({"path": str(path.resolve())}, indent=2), encoding="utf-8")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(prog="journal", description="Create and open entries in a Satz research journal.")
    commands = parser.add_subparsers(dest="command")
    init = commands.add_parser("init", help="create a ready-to-edit journal project")
    init.add_argument("path", type=Path)
    use = commands.add_parser("use", help="remember a journal folder for the short `journal` command")
    use.add_argument("path", type=Path)
    update = commands.add_parser("update-satz", help="refresh _satz/ from the installed starter runtime")
    update.add_argument("path", nargs="?", default=".", type=Path)
    new = commands.add_parser("new", help="create and open an entry")
    new.add_argument("path", nargs="?", help="journal folder; defaults to the remembered/current folder")
    new.add_argument("--editor")
    args = parser.parse_args(argv)
    try:
        if args.command == "init":
            init_project(args.path)
            remember_project(args.path)
            print(f"Journal created and selected: {args.path.resolve()}\nOpen that folder in VS Code and preview main.typ.")
            return 0
        if args.command == "use":
            path = args.path.expanduser().resolve()
            if not (path / "main.typ").is_file() or not (path / "entries").is_dir():
                raise ValueError(f"Not a journal project: {path}")
            remember_project(path)
            print(f"Journal selected: {path}")
            return 0
        if args.command == "update-satz":
            project = args.path.expanduser().resolve()
            if not (project / "main.typ").is_file():
                raise ValueError(f"Not a journal project: {project}")
            shutil.rmtree(project / "_satz", ignore_errors=True)
            shutil.copytree(runtime_path(), project / "_satz")
            print(f"Updated Satz runtime in {project / '_satz'}")
            return 0
        if args.command == "new" or args.command is None:
            project = load_project(getattr(args, "path", None))
            title = input("Entry title: ").strip()
            if not title:
                raise ValueError("Title cannot be empty.")
            kind = input("Entry type (meeting/session/notes) [notes]: ").strip().lower() or "notes"
            if kind not in {"meeting", "session", "notes"}:
                raise ValueError("Entry type must be meeting, session, or notes.")
            keywords = input("Keywords (comma-separated, optional): ").strip()
            entry = create_entry(project, title, kind, keywords)
            print(f"Created {entry}")
            if not open_editor(project, entry, getattr(args, "editor", None)):
                print("Your entry is saved. Open the project folder in your editor and select this file.")
            return 0
        parser.print_help()
        return 0
    except (OSError, ValueError, KeyError, json.JSONDecodeError) as exc:
        print(f"journal: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
