"""Check canonical English inputs against German compatibility aliases."""
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
  falzmarken: false, adressfenster: false, seitenzahlen: false,
  digitaler_absender: true, datum_rechts: true, blocksatz: false,
  absender_anzeigen: true, empfaenger_anzeigen: true,
  datum_anzeigen: true, betreff_anzeigen: true,
  papier: "a4", seitenraender: (left: 25mm, right: 20mm, top: 25mm, bottom: 25mm),
  schriftgroesse: 10.5pt, zeilenabstand: 0.7em, betreff_groesse: 12pt,
  digitaler_absender_hoehe: 20mm,
  abstaende: (signatur: 2em,), config: (typography: (justify: false)),
)
Dear Example Recipient,\nLetter body.\n'''
        english_letter = f'''#import "{IMPORT}": letter
#show: letter.with(
  sender: (name: "Example Sender", street: "Example Street 1", postal-code-city: "12345 Example City", phone: "555-0100"),
  recipient: (name: "Example Recipient", street: "Sample Road 2", postal-code-city: "54321 Sample City", country: "UK"),
  date: "2026-10-01", subject: "English aliases", language: "de",
  enclosure-list: ("Protocol copy",), signature: false,
  fold-marks: false, address-window: false, page-numbers: false,
  digital-sender: true, date-right: true, justify: false,
  show-sender: true, show-recipient: true, show-date: true, show-subject: true,
  paper: "a4", margins: (left: 25mm, right: 20mm, top: 25mm, bottom: 25mm),
  font-size: 10.5pt, line-spacing: 0.7em, subject-size: 12pt,
  digital-sender-height: 20mm,
  block-spacing: (signature: 2em, "sender-recipient": 2em), config: (typography: (justify: false)),
)
Dear Example Recipient,\nLetter body.\n'''
        assert render_text(folder, "german-letter", german_letter) == render_text(folder, "english-letter", english_letter)

        german_invoice = f'''#import "{IMPORT}": rechnung
#show: rechnung.with(
  absender: (name: "Example Company", strasse: "Main Street 3", plz_ort: "London", steuernummer: "TAX-1", iban: "", bank: "Example Bank"),
  empfaenger: (name: "Example Customer", strasse: "Side Road 4", plz_ort: "York", land: "UK"),
  datum: "01.10.2026", rechnungsnummer: "INV-1", leistungsdatum: "01.10.2026",
  betreff: "Example invoice", posten: (("Consulting", 2, 80),), qr: false,
  qr-verwendungszweck: "Payment reference",
  kleinunternehmer: true,
)
Invoice text body.\n'''
        english_invoice = f'''#import "{IMPORT}": invoice
#show: invoice.with(
  sender: (name: "Example Company", street: "Main Street 3", postal-code-city: "London", tax-number: "TAX-1", iban: "", bank: "Example Bank"),
  recipient: (name: "Example Customer", street: "Side Road 4", postal-code-city: "York", country: "UK"),
  date: "01.10.2026", invoice-number: "INV-1", service-date: "01.10.2026",
  subject: "Example invoice", items: ((description: "Consulting", quantity: 2, unit-price: 80),), qr: false,
  qr-purpose: "Payment reference",
  small-business: true,
)
Invoice text body.\n'''
        assert render_text(folder, "german-invoice", german_invoice) == render_text(folder, "english-invoice", english_invoice)

        german_guest = f'''#import "{IMPORT}": gastspielvertrag
#show: gastspielvertrag.with(
  dokument: "angebot", kuenstler: "Example Artist", kuenstler_vertreter: "Alex Example",
  kuenstler_anschrift: "Example Street 1, 12345 Example City",
  veranstaltung: "Example concert", location: "Example Hall", datum: "15.03.2026",
  auftrittszeit: "20:00", auftrittsdauer: "90 min", einlass: "19:00", curfew: "23:00",
  musiker: 3, techniker: false, fotograf: true,
  gage_typ: "prozent", festgage: 500, prozentsatz: 70, mindestgage: 300,
  kleinunternehmer: false, transport_km: 100, transport_satz: 0.4,
  techniker_honorar: 50, uebernachtung: 80,
  sonstiges_text: "Parking", sonstiges_betrag: 10, buyout_pro_person: 20,
  font: "Libertinus Serif",
)[Extra clause.]
'''
        english_guest = f'''#import "{IMPORT}": guest-contract
#show: guest-contract.with(
  document-type: "angebot", artist: "Example Artist", artist-representative: "Alex Example",
  artist-address: "Example Street 1, 12345 Example City",
  event: "Example concert", venue: "Example Hall", date: "15.03.2026",
  performance-time: "20:00", performance-duration: "90 min", doors: "19:00", curfew: "23:00",
  musicians: 3, technician: false, photographer: true,
  fee-type: "prozent", fixed-fee: 500, percentage: 70, minimum-fee: 300,
  small-business: false, travel-km: 100, travel-rate: 0.4,
  technician-fee: 50, accommodation: 80,
  other-description: "Parking", other-amount: 10, buyout-per-person: 20,
  font: "Libertinus Serif",
)[Extra clause.]
'''
        assert render_text(folder, "german-guest", german_guest) == render_text(folder, "english-guest", english_guest)

        german_complaint = f'''#import "{IMPORT}": klageschrift
#show: klageschrift.with(
  gericht: "Amtsgericht Musterstadt", gericht_ort: "Gerichtsstraße 1, 12345 Musterstadt",
  klagername: "Alex Example", klagerin_str: "Example Street 1", klagerin_plz: "12345 Example City",
  beklagter: "Robin Sample", beklagter_str: "Sample Road 2", beklagter_plz: "54321 Sample City",
  streitwert: "1.000,00 EUR", anlagen: ("Anlage K 1: Contract",),
  datum: "27.10.2026",
)
= Anträge
The claim.
'''
        english_complaint = f'''#import "{IMPORT}": complaint
#show: complaint.with(
  court: "Amtsgericht Musterstadt", court-address: "Gerichtsstraße 1, 12345 Musterstadt",
  plaintiff: "Alex Example", plaintiff-street: "Example Street 1", plaintiff-postal-code-city: "12345 Example City",
  defendant: "Robin Sample", defendant-street: "Sample Road 2", defendant-postal-code-city: "54321 Sample City",
  amount-in-dispute: "1.000,00 EUR", exhibits: ("Anlage K 1: Contract",),
  date: "27.10.2026",
)
= Anträge
The claim.
'''
        assert render_text(folder, "german-complaint", german_complaint) == render_text(folder, "english-complaint", english_complaint)

        conflicts = {
            "sender-record": ("brief", '''absender: (name: "German"), sender: (name: "English"),'''),
            "sender-field": ("brief", '''sender: (street: "English", strasse: "German"),'''),
            "sender-record-type": ("brief", '''sender: "not a record",'''),
            "sender-field-type": ("brief", '''sender: (street: 12),'''),
            "letter-flag": ("brief", '''signatur: "yes",'''),
            "letter-layout-flag": ("brief", '''fold-marks: "yes",'''),
            "letter-alias-conflict": ("brief", '''signatur: false, signature: true,'''),
            "letter-reference-line": ("brief", '''reference-line: (("Ref", 1),),'''),
            "invoice-item": ("rechnung", '''items: ((description: "Consulting", quantity: 2),),'''),
            "invoice-item-quantity": ("rechnung", '''items: ((description: "Consulting", quantity: 0, unit-price: 80),),'''),
            "invoice-item-tuple": ("rechnung", '''items: (("Consulting", 2),),'''),
            "invoice-qr-flag": ("rechnung", '''qr: "yes",'''),
            "invoice-qr-amount": ("rechnung", '''qr-amount: -1,'''),
            "guest-alias-conflict": ("gastspielvertrag", '''festgage: 100, fixed-fee: 100,'''),
            "complaint-alias-conflict": ("klageschrift", '''gericht: "A", court: "B",'''),
            "complaint-page-limit": ("klageschrift", '''exhibit-page-limit: 0,'''),
        }
        for name, (template, arguments) in conflicts.items():
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
            elif name == "letter-flag":
                assert "Letter `signature` option must be a boolean" in result.stderr
            elif name == "letter-layout-flag":
                assert "Letter `fold-marks` option must be a boolean" in result.stderr
            elif name == "letter-alias-conflict":
                assert "either `signatur` or `signature`" in result.stderr
            elif name == "letter-reference-line":
                assert "reference-line must be an array of two-string pairs" in result.stderr
            elif name == "invoice-qr-flag":
                assert "Invoice qr option must be a boolean" in result.stderr
            elif name == "invoice-qr-amount":
                assert "qr-amount must be a nonnegative number" in result.stderr
            elif name == "guest-alias-conflict":
                assert "either `festgage` or `fixed-fee`" in result.stderr
            elif name == "complaint-alias-conflict":
                assert "either `gericht` or `court`" in result.stderr
            elif name == "complaint-page-limit":
                assert "Complaint `exhibit-page-limit` must be a positive integer" in result.stderr
            else:
                assert "unit-price" in result.stderr
    print("Passed: canonical English and German compatibility inputs render the same text; alias conflicts and malformed values fail clearly.")


if __name__ == "__main__":
    main()
