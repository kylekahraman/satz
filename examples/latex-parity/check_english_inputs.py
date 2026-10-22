"""Check English letter/invoice inputs normalize to the existing German API."""
from pathlib import Path
import subprocess
import tempfile

import pymupdf as fitz


ROOT = Path(__file__).resolve().parents[2]
# Fixtures live in a temporary child of examples/latex-parity. Typst resolves
# absolute paths beneath --root, so use a relative import that stays in-root.
IMPORT = "../../../lib.typ"


def compile_pdf(folder, name, source):
    path = folder / f"{name}.typ"
    path.write_text(source)
    result = subprocess.run(
        ["typst", "compile", "--root", str(ROOT), str(path), str(path.with_suffix(".pdf"))],
        text=True,
        capture_output=True,
    )
    return result, path.with_suffix(".pdf")


def render_text(folder, name, source):
    result, pdf = compile_pdf(folder, name, source)
    assert result.returncode == 0, result.stderr
    with fitz.open(pdf) as document:
        return "\n".join(page.get_text() for page in document)


def main():
    with tempfile.TemporaryDirectory(prefix="satz-english-inputs-", dir=ROOT / "examples/latex-parity") as directory:
        folder = Path(directory)
        german_letter = f'''#import "{IMPORT}": brief
#show: brief.with(
  absender: (name: "Example Sender", strasse: "Example Street 1", plz_ort: "12345 Example City", telefon: "555-0100"),
  empfaenger: (name: "Example Recipient", strasse: "Sample Road 2", plz_ort: "54321 Sample City", land: "UK"),
  datum: "2026-10-01", betreff: "English aliases", lang: "de",
  anlagenverzeichnis: ("Protocol copy",), signatur: false,
)
Dear Example Recipient,\nLetter body.\n'''
        english_letter = f'''#import "{IMPORT}": letter
#show: letter.with(
  sender: (name: "Example Sender", street: "Example Street 1", postal-code-city: "12345 Example City", phone: "555-0100"),
  recipient: (name: "Example Recipient", street: "Sample Road 2", postal-code-city: "54321 Sample City", country: "UK"),
  date: "2026-10-01", subject: "English aliases", language: "de",
  enclosure-list: ("Protocol copy",), signatur: false,
)
Dear Example Recipient,\nLetter body.\n'''
        assert render_text(folder, "german-letter", german_letter) == render_text(folder, "english-letter", english_letter)

        german_invoice = f'''#import "{IMPORT}": rechnung
#show: rechnung.with(
  absender: (name: "Example Company", strasse: "Main Street 3", plz_ort: "London", steuernummer: "TAX-1", iban: "", bank: "Example Bank"),
  empfaenger: (name: "Example Customer", strasse: "Side Road 4", plz_ort: "York", land: "UK"),
  datum: "01.10.2026", rechnungsnummer: "INV-1", leistungsdatum: "01.10.2026",
  betreff: "Example invoice", posten: (("Consulting", 2, 80),), qr: false,
  kleinunternehmer: true,
)
Invoice text body.\n'''
        english_invoice = f'''#import "{IMPORT}": invoice
#show: invoice.with(
  sender: (name: "Example Company", street: "Main Street 3", postal-code-city: "London", tax-number: "TAX-1", iban: "", bank: "Example Bank"),
  recipient: (name: "Example Customer", street: "Side Road 4", postal-code-city: "York", country: "UK"),
  date: "01.10.2026", invoice-number: "INV-1", service-date: "01.10.2026",
  subject: "Example invoice", items: ((description: "Consulting", quantity: 2, unit-price: 80),), qr: false,
  small-business: true,
)
Invoice text body.\n'''
        assert render_text(folder, "german-invoice", german_invoice) == render_text(folder, "english-invoice", english_invoice)

        conflicts = {
            "sender-record": '''absender: (name: "German"), sender: (name: "English"),''',
            "sender-field": '''sender: (street: "English", strasse: "German"),''',
            "invoice-item": '''items: ((description: "Consulting", quantity: 2),),''',
            "sender-record-type": '''sender: "not a record",''',
            "sender-field-type": '''sender: (street: 12),''',
            "invoice-item-quantity": '''items: ((description: "Consulting", quantity: 0, unit-price: 80),),''',
            "invoice-item-tuple": '''items: (("Consulting", 2),),''',
        }
        for name, arguments in conflicts.items():
            template = "rechnung" if name.startswith("invoice-item") else "brief"
            source = f'''#import "{IMPORT}": {template}\n#show: {template}.with({arguments})\nBody.\n'''
            result, _ = compile_pdf(folder, name, source)
            assert result.returncode != 0, f"{name} should fail validation"
            if name == "sender-record":
                assert "Conflicting sender records" in result.stderr
            elif name == "sender-field":
                assert "Conflicting sender fields" in result.stderr
            elif name == "sender-record-type":
                assert "English sender must be a dictionary" in result.stderr
            elif name == "sender-field-type":
                assert "Sender field `strasse` must be a string" in result.stderr
            elif name == "invoice-item-quantity":
                assert "`quantity` must be a positive number" in result.stderr
            elif name == "invoice-item-tuple":
                assert "must be a three-value tuple" in result.stderr
            else:
                assert "unit-price" in result.stderr
    print("Passed: equivalent German/English inputs render the same text; alias conflicts, malformed addresses, and invalid invoice items fail clearly.")


if __name__ == "__main__":
    main()
