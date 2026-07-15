#import "rechnung.typ": rechnung

#show: rechnung.with(
  // Überschreibt bei Bedarf eure Band-Stammdaten:
  absender: (
    name: "Musterfirma GmbH",
    strasse: "Musterstraße 1",
    plz_ort: "12345 Musterstadt",
    steuernummer: "000/000/00000",
    iban: "DE00 0000 0000 0000 0000 00",
    bic: "EXAMPLEBICXXX",
    bank: "Musterbank",
    logo: none, // Replace with your logo file, e.g. "logo.png"
  ),
  empfaenger: [
    Musterfirma GmbH \
    Frau Erika Beispiel \
    Beispielallee 42 \
    60311 Frankfurt am Main \
  ],
  
  rechnungsnummer: "2026-02",
  leistungsdatum: "01.01.2025 – 31.12.2025",
  betreff: "Abrechnung Q1/2026",
  posten: (
    ("Dienstleistung Projekt Alpha", 1, 100.00),
    ("Dienstleistung Projekt Beta", 1, 75.50),
    ("Beratungspauschale März 2026", 1, 50.00),
    ("Abzüglich Rabatt 10%", 1, -22.55),
  ),
  qr: true,
  qr-verwendungszweck: "*RECHNUNGSNUMMER*",
)

Hallo Frau Beispiel,

vielen Dank für die erfolgreiche Zusammenarbeit.

Bezugnehmend auf die Auswertungen des Digitalvertriebs für das Jahr 2025 stellen wir dir hiermit unseren verbleibenden Anteil wie folgt in Rechnung.
