"""Check accepted journal date forms, month grouping, and invalid-date errors."""
from pathlib import Path
import subprocess
import tempfile

import pdfplumber


ROOT = Path(__file__).resolve().parents[2]


def compile_doc(folder, name, source):
    path = folder / f"{name}.typ"
    path.write_text(source)
    result = subprocess.run(
        ["typst", "compile", "--root", str(ROOT), str(path), str(path.with_suffix(".pdf"))],
        text=True,
        capture_output=True,
    )
    return result, path.with_suffix(".pdf")


def main():
    with tempfile.TemporaryDirectory(prefix="satz-journal-dates-", dir=ROOT) as directory:
        folder = Path(directory)
        source = '''#import "/lib.typ": journal-entry, journal-index
#journal-index()
#journal-entry(title: "ISO", date: "2026-10-21")[ISO body]
#journal-entry(title: "Weekday comma", date: "Wednesday, 21/10/26")[Body]
#journal-entry(title: "Weekday space", date: "Mon 03/03/2026")[Body]
#journal-entry(title: "Four digit", date: "18/10/2025")[Body]
#journal-entry(title: "Undated", date: "")[Body]
'''
        result, pdf = compile_doc(folder, "valid", source)
        assert result.returncode == 0, result.stderr
        with pdfplumber.open(pdf) as document:
            text = "\n".join(page.extract_text() or "" for page in document.pages)
        for expected in ("October 2026", "March 2026", "October 2025", "Undated"):
            assert expected in text, f"Missing index group {expected!r}: {text}"

        invalid = '''#import "/lib.typ": journal-entry
#journal-entry(title: "Bad", date: "2026-02-30")[Body]
'''
        result, _ = compile_doc(folder, "invalid", invalid)
        assert result.returncode != 0
        assert "Journal date day is outside the selected month" in result.stderr

    print("Passed: ISO and slash dates, weekday prefixes, monthly/year groups, undated drafts, and invalid calendar dates.")


if __name__ == "__main__":
    main()
