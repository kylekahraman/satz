#import "rechnung.typ": rechnung

#show: rechnung.with(
  // Überschreibt bei Bedarf eure Band-Stammdaten:
  absender: (
    name: "sun's sons GbR",
    strasse: "Vogelsbergstraße 32",
    plz_ort: "60316 Frankfurt am Main",
    steuernummer: "014 373 30175",
    iban: "DE64 1001 1001 2623 4414 56",
    bank: "N26 Bank",
    logo: none, // Hier einfach "logo.png" eintragen, sobald ihr eins habt!
  ),
  empfaenger: [
    Musterfirma GmbH \
    Frau Erika Beispiel \
    Beispielallee 42 \
    60311 Frankfurt am Main \
  ],
  
  rechnungsnummer: "2026-02",
  leistungsdatum: "01.01.2025 – 31.12.2025",
  betreff: "Abrechnung Einnahmen Digitalvertrieb 2025",
  posten: (
    ("Digitalvertrieb Einnahmen Q1/2025", 1, 94.43),
    ("Digitalvertrieb Einnahmen Q2/2025", 1, 37.46),
    ("Digitalvertrieb Einnahmen Q3/2025", 1, 32.31),
    ("Digitalvertrieb Einnahmen Q4/2025", 1, 21.72),
    ("Abzüglich 20% Vertriebsgebühr ALL ROOMS", 1, -37.18),
  ),
)

Hallo Erika,

vielen Dank für die erfolgreiche Zusammenarbeit im vergangenen Jahr.

Bezugnehmend auf die Auswertungen des Digitalvertriebs für das Jahr 2025 stellen wir dir hiermit unseren verbleibenden Anteil wie folgt in Rechnung.