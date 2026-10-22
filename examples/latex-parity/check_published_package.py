"""Compile stable public starters against the actual published 0.1.1 package."""
from pathlib import Path
import subprocess
import tempfile

import pymupdf


VERSION = "0.1.1"


def main():
    with tempfile.TemporaryDirectory(prefix="satz-published-package-") as directory:
        stage = Path(directory)
        project = stage / "project"
        packages = stage / "packages"
        cache = stage / "cache"
        project.mkdir()
        packages.mkdir()
        cache.mkdir()
        sources = {
            "letter": f'''#import "@preview/satz:{VERSION}": brief
#show: brief.with(
  absender: (name: "Published Sender", strasse: "One Street", plz_ort: "London"),
  empfaenger: (name: "Published Recipient", strasse: "Two Street", plz_ort: "York"),
  datum: "2026-10-22", betreff: "Published letter", lang: "en",
)
Letter marker.
''',
            "invoice": f'''#import "@preview/satz:{VERSION}": rechnung
#show: rechnung.with(
  absender: (name: "Published Company", strasse: "One Street", plz_ort: "London", steuernummer: "TAX-1", iban: "", bank: "Bank"),
  empfaenger: (name: "Published Customer", strasse: "Two Street", plz_ort: "York"),
  datum: "22.10.2026", rechnungsnummer: "INV-1", leistungsdatum: "22.10.2026",
  betreff: "Published invoice", posten: (("Work", 1, 10),), qr: false,
)
Invoice marker.
''',
            "report": f'''#import "@preview/satz:{VERSION}": report
#show: report.with()
= Published report
Report marker.
''',
            "journal": f'''#import "@preview/satz:{VERSION}": journal-entry, journal-index
#journal-index()
#journal-entry(title: "Published entry", date: "2026-10-22")[Journal marker.]
''',
            "cover": f'''#import "@preview/satz:{VERSION}": cover-page
#cover-page([Published cover marker.])
''',
        }
        for name, source in sources.items():
            path = project / f"{name}.typ"
            path.write_text(source)
            output = stage / f"{name}.pdf"
            result = subprocess.run(
                [
                    "typst", "compile", "--package-path", str(packages),
                    "--package-cache-path", str(cache), "--root", str(project),
                    str(path), str(output),
                ],
                text=True,
                capture_output=True,
            )
            assert result.returncode == 0, f"Published {VERSION} {name} starter failed:\n{result.stderr}"
            with pymupdf.open(output) as document:
                text = "\n".join(page.get_text() for page in document)
            marker = {
                "letter": "Letter marker.", "invoice": "Invoice marker.",
                "report": "Report marker.", "journal": "Journal marker.",
                "cover": "Published cover marker.",
            }[name]
            assert marker in text, f"Published {VERSION} {name} marker missing from PDF"

    print(f"Passed: letter, invoice, report, journal, and cover compile against isolated @preview/satz:{VERSION}.")


if __name__ == "__main__":
    main()
