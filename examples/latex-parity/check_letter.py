"""Check letter enclosures and independent date/reference visibility."""

from pathlib import Path
import subprocess

import pymupdf as fitz


ROOT = Path(__file__).resolve().parents[2]
OUTPUT = Path(__file__).resolve().parent / "output"


def compile_letter(name, source):
    path = OUTPUT / f"{name}.typ"
    path.write_text(source)
    pdf = path.with_suffix(".pdf")
    subprocess.run(["typst", "compile", "--root", str(ROOT), str(path), str(pdf)], check=True)
    return pdf


def main():
    OUTPUT.mkdir(exist_ok=True)
    pdf = compile_letter("letter-enclosures", '''#import "/lib.typ": letter
#show: letter.with(
  sender: (name: "Example Author", street: "Example Street 1", postal-code-city: "12345 Example City"),
  recipient: (name: "Example Recipient", street: "Sample Road 2", postal-code-city: "54321 Sample City"),
  subject: "Enclosure example",
  date: "2026-10-18",
  language: "en",
  enclosure-list: ("Protocol copy", "Schedule copy"),
)
Dear Example Recipient,

Please find the enclosed documents.

Kind regards,
''')
    with fitz.open(pdf) as document:
        assert len(document) == 1
        text = document[0].get_text()
        assert "Attachments:" in text, "Named enclosure list is missing"
        assert text.count("Protocol copy") == 1 and text.count("Schedule copy") == 1
        assert "Example Author" in text and "Example Recipient" in text
        document[0].get_pixmap().save(OUTPUT / "letter-enclosures.png")

    hidden_date = compile_letter("letter-hidden-date", '''#import "/lib.typ": letter
#show: letter.with(
  sender: (name: "Example Author", street: "Example Street 1", postal-code-city: "12345 Example City"),
  recipient: (name: "Example Recipient", street: "Sample Road 2", postal-code-city: "54321 Sample City"),
  date: "2026-10-18",
  show-date: false,
  reference-line: (("Reference", "REF-1"),),
  subject: "Reference without date",
  signature: false,
)
Dear Example Recipient,

The reference line must remain visible when the date is hidden.
''')
    with fitz.open(hidden_date) as document:
        text = "\n".join(page.get_text() for page in document)
        assert "Reference" in text and "REF-1" in text, "Hiding the date also hid reference fields"
        assert "18.10.2026" not in text and "2026-10-18" not in text, "show-date: false still rendered a date"

    invalid = OUTPUT / "letter-invalid-language.typ"
    invalid.write_text('#import "/lib.typ": letter\n#show: letter.with(language: "nl")\nBody')
    result = subprocess.run(["typst", "compile", "--root", str(ROOT), str(invalid), str(invalid.with_suffix(".pdf"))], text=True, capture_output=True)
    assert result.returncode != 0 and "Letter language must be `de` or `en`" in result.stderr
    print("Passed: enclosures render once, hiding the date preserves reference fields, and invalid languages fail clearly.")


if __name__ == "__main__":
    main()
