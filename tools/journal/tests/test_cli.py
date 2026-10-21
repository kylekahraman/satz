import datetime as dt
import json
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

from satz_journal import cli


class JournalCliTests(unittest.TestCase):
    def project(self, root: Path) -> Path:
        path = root / "a journal with spaces"
        path.mkdir()
        (path / "entries").mkdir()
        (path / "main.typ").write_text("// --- entries ---\n// --- end entries ---\n", encoding="utf-8")
        return path

    def test_typst_string_escapes_quotes_backslashes_and_unicode(self):
        self.assertEqual(cli.typst_string('A "quote" \\ Δ'), '"A \\"quote\\" \\\\ Δ"')

    def test_entry_is_added_and_included_for_project_path_with_spaces(self):
        with tempfile.TemporaryDirectory() as temporary:
            project = self.project(Path(temporary))
            path = cli.create_entry(project, 'Meet "A" \\ Δ', "meeting", "alpha, β", dt.date(2026, 10, 21))
            self.assertEqual(path.parent.resolve(), (project / "entries").resolve())
            text = path.read_text(encoding="utf-8")
            self.assertIn('title: "Meet \\"A\\" \\\\ Δ"', text)
            self.assertIn("2026-10-21-meet-a-δ.typ", path.name.lower())
            self.assertIn(f'#include "entries/{path.name}"', (project / "main.typ").read_text(encoding="utf-8"))

    def test_collision_does_not_change_entry_or_main(self):
        with tempfile.TemporaryDirectory() as temporary:
            project = self.project(Path(temporary))
            old = "// --- entries ---\n// --- end entries ---\n"
            (project / "main.typ").write_text(old, encoding="utf-8")
            target = project / "entries/2026-01-02-same-title.typ"
            target.write_text("keep me", encoding="utf-8")
            with self.assertRaises(FileExistsError):
                cli.create_entry(project, "Same Title", "notes", "", dt.date(2026, 1, 2))
            self.assertEqual(target.read_text(encoding="utf-8"), "keep me")
            self.assertEqual((project / "main.typ").read_text(encoding="utf-8"), old)

    def test_invalid_project_fails_before_mutating(self):
        with tempfile.TemporaryDirectory() as temporary:
            project = Path(temporary) / "not a journal"
            project.mkdir()
            before = list(project.iterdir())
            with self.assertRaises(ValueError):
                cli.create_entry(project, "Title", "notes", "")
            self.assertEqual(list(project.iterdir()), before)

    def test_unavailable_editor_keeps_saved_entry(self):
        with tempfile.TemporaryDirectory() as temporary:
            project = self.project(Path(temporary))
            with patch.object(cli.shutil, "which", return_value=None), patch.object(cli.subprocess, "Popen") as popen:
                entry = cli.create_entry(project, "Saved", "notes", "")
                self.assertFalse(cli.open_editor(project, entry, "missing-editor"))
                popen.assert_not_called()
                self.assertTrue(entry.is_file())

    def test_editor_invocation_opens_project_and_new_file(self):
        with tempfile.TemporaryDirectory() as temporary:
            project = self.project(Path(temporary))
            project = project.resolve()
            entry = project / "entries/note.typ"
            with patch.object(cli.shutil, "which", return_value="/bin/code"), patch.object(cli.subprocess, "Popen") as popen:
                self.assertTrue(cli.open_editor(project, entry, "code"))
                popen.assert_called_once_with(["code", "--reuse-window", str(project.resolve()), str(entry)])

    def test_windows_editor_path_with_spaces_is_unquoted_before_lookup(self):
        with tempfile.TemporaryDirectory() as temporary:
            project = Path(temporary) / "journal folder"
            executable = r"C:\Program Files\Microsoft VS Code\Code.exe"
            command = cli.editor_command(
                project,
                project / "entries" / "entry.typ",
                f'"{executable}" --wait',
                windows=True,
                which=lambda candidate: candidate if candidate == executable else None,
            )
            self.assertEqual(command, [executable, "--wait", "--reuse-window", str(project), str(project / "entries" / "entry.typ")])

    def test_starter_config_keeps_only_small_overrides(self):
        setup = Path(__file__).parents[1] / "src/satz_journal/templates/setup.typ"
        source = setup.read_text(encoding="utf-8")
        self.assertIn('merge((page: (paper: journal-style.paper,)), journal-overrides)', source)
        self.assertNotIn("defaults", source)

    def test_init_delivers_preview_guidance_and_current_dated_entry(self):
        with tempfile.TemporaryDirectory() as temporary:
            project = Path(temporary) / "journal"
            cli.init_project(project)
            today = dt.date.today().isoformat()
            self.assertTrue((project / "entries" / f"{today}-getting-started.typ").is_file())
            self.assertIn("Typst: Preview", (project / "README.md").read_text(encoding="utf-8"))
            self.assertIn("Typst: Pin Main", (project / "README.md").read_text(encoding="utf-8"))
            self.assertIn("journal-overrides", (project / "config.typ").read_text(encoding="utf-8"))
            self.assertIn("Source revision:", (project / "_satz/VERSION.txt").read_text(encoding="utf-8"))

    def test_missing_marker_leaves_no_partial_entry(self):
        with tempfile.TemporaryDirectory() as temporary:
            project = self.project(Path(temporary))
            (project / "main.typ").write_text("// no marker\n", encoding="utf-8")
            with self.assertRaises(ValueError):
                cli.create_entry(project, "Title", "notes", "")
            self.assertEqual(list((project / "entries").iterdir()), [])

    def test_meeting_and_session_get_distinct_research_scaffolds(self):
        with tempfile.TemporaryDirectory() as temporary:
            project = self.project(Path(temporary))
            meeting = cli.create_entry(project, "Team meeting", "meeting", "", dt.date(2026, 1, 1))
            session = cli.create_entry(project, "Lab session", "session", "", dt.date(2026, 1, 2))
            meeting_source = meeting.read_text(encoding="utf-8")
            session_source = session.read_text(encoding="utf-8")
            for heading in ("Agenda", "What we talked about", "Outcomes", "Rationale", "Action Items", "Questions"):
                self.assertIn(f"== {heading}", meeting_source)
            for heading in ("Goal", "Log", "Outcomes", "Rationale", "Next Steps", "Questions"):
                self.assertIn(f"== {heading}", session_source)
            self.assertNotIn("== Agenda", session_source)
            self.assertNotIn("== Goal", meeting_source)

    def test_empty_title_or_unknown_kind_fails_before_writing(self):
        with tempfile.TemporaryDirectory() as temporary:
            project = self.project(Path(temporary))
            for title, kind in (("  ", "notes"), ("Title", "proposal")):
                with self.assertRaises(ValueError):
                    cli.create_entry(project, title, kind, "")
            self.assertEqual(list((project / "entries").iterdir()), [])
            self.assertEqual((project / "main.typ").read_text(encoding="utf-8"), "// --- entries ---\n// --- end entries ---\n")

    def test_macos_config_path(self):
        with patch.object(cli.sys, "platform", "darwin"):
            self.assertTrue(str(cli.config_dir()).endswith("Library/Application Support/satz-journal"))


if __name__ == "__main__":
    unittest.main()
