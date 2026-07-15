#import "template.typ": brief

#show: brief.with(
  absender: (
    name: "Max Mustermann",
    strasse: "Musterstraße 1",
    plz_ort: "12345 Musterstadt",
    telefon: "+49 123 4567890",
    email: "max.mustermann@gmail.com"),
  empfaenger: (
    "Musterfirma GmbH",
    "Frau Erika Beispiel",
    "Beispielallee 42",
    "60311 Frankfurt am Main",
  ),
  betreff: "Subject Line",
  geschaeftszeile: (
    ("Mietsache", "112345"),
    ("Kundennummer", "123456"),
    ("Rechnungsnummer", "2023-001"),
    // man kann beliebige zeichen hinzufügen in dem man ("Zeichen", "Wert") hinzufügt, z.B. ("Kundennummer", "123456")
  )
)

Sehr geehrte Damen und Herren,

#lorem(200)

#v(2*0.65em)

Mit freundlichen Grüßen
// Linie für Unterschrift kommt automatisch