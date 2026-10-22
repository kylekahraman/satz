"""Check theme/direct/config precedence for shared document appearance."""
from pathlib import Path
import subprocess
import tempfile

import pymupdf


ROOT = Path(__file__).resolve().parents[2]
IMPORT = "../../../lib.typ"
OVERRIDE = "#336699"


def compile_pdf(folder, name, source):
    path = folder / f"{name}.typ"
    path.write_text(source)
    result = subprocess.run(
        ["typst", "compile", "--root", str(ROOT), str(path), str(path.with_suffix(".pdf"))],
        text=True,
        capture_output=True,
    )
    return result, path.with_suffix(".pdf")


def text_color(pdf, text):
    with pymupdf.open(pdf) as document:
        spans = [
            span
            for page in document
            for block in page.get_text("dict")["blocks"]
            for line in block.get("lines", ())
            for span in line["spans"]
            if text in span["text"]
        ]
    assert spans, f"Could not find {text!r} in {pdf}"
    return spans[0]["color"]


def main():
    with tempfile.TemporaryDirectory(prefix="satz-appearance-", dir=ROOT / "examples/latex-parity") as directory:
        folder = Path(directory)
        letter = f'''#import "{IMPORT}": letter
#show: letter.with(
  sender: (name: "Sender", street: "One Street", postal-code-city: "London"),
  recipient: (name: "Recipient", street: "Two Street", postal-code-city: "York"),
  subject: "LETTER_OVERRIDE",
  theme: "soft-rose",
  config: (colors: (brand-primary: rgb("{OVERRIDE}"),)),
)
Body.
'''
        invoice = f'''#import "{IMPORT}": invoice
#show: invoice.with(
  sender: (name: "Sender", street: "One Street", postal-code-city: "London", iban: "", bank: "Bank"),
  recipient: (name: "Recipient", street: "Two Street", postal-code-city: "York"),
  subject: "INVOICE_OVERRIDE", invoice-number: "INV-1", service-date: "2026-10-01",
  items: ((description: "Work", quantity: 1, unit-price: 10),), qr: false,
  theme: "soft-rose",
  config: (colors: (brand-primary: rgb("{OVERRIDE}"),)),
)
Body.
'''
        book = f'''#import "{IMPORT}": book
#show: book.with(
  title: "Book title", eyebrow: "BOOK_OVERRIDE", date: "2026",
  accent: green, theme: "soft-rose",
  config: (colors: (brand-primary: rgb("{OVERRIDE}"),), typography: (math-font: "Libertinus Math")),
)
= Chapter
Equation: $x^2$
'''

        for name, source in (("letter", letter), ("invoice", invoice), ("book", book)):
            result, pdf = compile_pdf(folder, name, source)
            assert result.returncode == 0, result.stderr
            target = {"letter": "LETTER_OVERRIDE", "invoice": "INVOICE_OVERRIDE", "book": "BOOK_OVERRIDE"}[name]
            assert text_color(pdf, target) == 0x336699, f"{name} nested config did not override its theme/direct setting"

        invalid = f'''#import "{IMPORT}": letter
#show: letter.with(config: (typography: (mystery-size: 12pt)))
Body.
'''
        result, _ = compile_pdf(folder, "invalid", invalid)
        assert result.returncode != 0
        assert "typography.mystery-size" in result.stderr

        invalid_heading = f'''#import "{IMPORT}": personal
#show: personal.with(config: (headings: (spacing: "koma-ish")))
Body.
'''
        result, _ = compile_pdf(folder, "invalid-heading-policy", invalid_heading)
        assert result.returncode != 0
        assert "headings.spacing must be koma or native" in result.stderr

        invalid_shared_key = f'''#import "{IMPORT}": personal
#show: personal.with(config: (typography: (leadng: 0.7em)))
Body.
'''
        result, _ = compile_pdf(folder, "invalid-shared-key", invalid_shared_key)
        assert result.returncode != 0
        assert "Unknown Satz config key `typography.leadng`" in result.stderr

        extension_group = f'''#import "{IMPORT}": personal
#show: personal.with(config: (caller-extension: (custom: true)))
Body.
'''
        result, _ = compile_pdf(folder, "extension-group", extension_group)
        assert result.returncode == 0, result.stderr

    print("Passed: themes apply across letter, invoice and book; nested config wins, shared typos fail, caller extension groups remain open, and invalid postal/heading settings fail clearly.")


if __name__ == "__main__":
    main()
