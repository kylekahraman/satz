"""Optional end-to-end checks; run with Typst installed and package access."""
import datetime as dt
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest

from satz_journal.cli import create_entry, init_project


@unittest.skipUnless(shutil.which("typst"), "Typst CLI is not installed")
class TypstStarterSmokeTests(unittest.TestCase):
    def test_palette_defaults_b5_and_escaped_entry_compile(self):
        with tempfile.TemporaryDirectory() as temporary:
            project = Path(temporary) / "journal"
            init_project(project)
            config = project / "config.typ"
            source = config.read_text(encoding="utf-8")
            source = source.replace('theme: "soft-slate"', 'theme: "plum"')
            source = source.replace('paper: "a4"', 'paper: "iso-b5"')
            config.write_text(source, encoding="utf-8")

            pdf = project / "baseline.pdf"
            subprocess.run(["typst", "compile", "--root", str(project), str(project / "main.typ"), str(pdf)], check=True)
            # ISO B5 is 176 x 250 mm; these are its PDF point dimensions.
            self.assertRegex(pdf.read_bytes().decode("latin-1"), r"MediaBox\[0 0 498\.\d+ 708\.\d+\]")

            svg_pattern = project / "page-{p}.svg"
            subprocess.run(["typst", "compile", "--root", str(project), "--format", "svg", str(project / "main.typ"), str(svg_pattern)], check=True)
            entry_page = (project / "page-3.svg").read_text(encoding="utf-8")
            self.assertIn("#674666", entry_page)  # plum palette reaches entry headings

            defaults = project / "_satz/defaults.typ"
            defaults_source = defaults.read_text(encoding="utf-8")
            self.assertIn("    size: 11pt,\n    leading:", defaults_source)
            defaults.write_text(defaults_source.replace("    size: 11pt,\n    leading:", "    size: 17pt,\n    leading:", 1), encoding="utf-8")
            changed_svg_pattern = project / "changed-{p}.svg"
            subprocess.run(["typst", "compile", "--root", str(project), "--format", "svg", str(project / "main.typ"), str(changed_svg_pattern)], check=True)
            self.assertNotEqual(entry_page, (project / "changed-3.svg").read_text(encoding="utf-8"))

            create_entry(project, 'Quoted "Meeting" \\ Δ', "meeting", "unicode", dt.date(2026, 10, 21))
            escaped_pdf = project / "escaped-entry.pdf"
            subprocess.run(["typst", "compile", "--root", str(project), str(project / "main.typ"), str(escaped_pdf)], check=True)
            self.assertGreater(escaped_pdf.stat().st_size, 0)


if __name__ == "__main__":
    unittest.main()
