"""Check named letter enclosures without treating their names as image paths."""

from pathlib import Path
import subprocess

import pymupdf as fitz


ROOT = Path(__file__).resolve().parents[2]
OUTPUT = Path(__file__).resolve().parent / "output"


def main():
    OUTPUT.mkdir(exist_ok=True)
    source = OUTPUT / "letter-enclosures.typ"
    source.write_text('''#import "/lib.typ": brief
#show: brief.with(
  absender: (name: "Example Author", strasse: "Example Street 1", plz_ort: "12345 Example City"),
  empfaenger: (name: "Example Recipient", strasse: "Sample Road 2", plz_ort: "54321 Sample City"),
  betreff: "Enclosure example",
  datum: "2026-10-18",
  lang: "en",
  anlagenverzeichnis: ("Protocol copy", "Schedule copy"),
)
Dear Example Recipient,

Please find the enclosed documents.

Kind regards,
''')
    pdf = source.with_suffix(".pdf")
    subprocess.run(["typst", "compile", "--root", str(ROOT), str(source), str(pdf)], check=True)
    with fitz.open(pdf) as document:
        assert len(document) == 1
        text = document[0].get_text()
        assert "Attachments:" in text, "Named enclosure list is missing"
        assert text.count("Protocol copy") == 1 and text.count("Schedule copy") == 1
        assert "Example Author" in text and "Example Recipient" in text
        document[0].get_pixmap().save(OUTPUT / "letter-enclosures.png")
    invalid = OUTPUT / "letter-invalid-language.typ"
    invalid.write_text('#import "/lib.typ": letter\n#show: letter.with(language: "nl")\nBody')
    result = subprocess.run(["typst", "compile", "--root", str(ROOT), str(invalid), str(invalid.with_suffix(".pdf"))], text=True, capture_output=True)
    assert result.returncode != 0 and "Letter language must be `de` or `en`" in result.stderr
    print("Passed: labeled enclosures render once without opening nonexistent files.")


if __name__ == "__main__":
    main()
