#import "brief.typ": brief

#show: brief.with(
  empfaenger: (
    "Musterfirma GmbH",
    "Frau Erika Beispiel",
    "Beispielallee 42",
    "60311 Frankfurt am Main",
  ),
  betreff: "Subject Line",
  geschaeftszeile: (
    ("Mietsache", "{{PROPERTY_ADDRESS}}"),
    // man kann beliebige zeichen hinzufügen in dem man ("Zeichen", "Wert") hinzufügt, z.B. ("Kundennummer", "123456")
  )
)

Sehr geehrte Damen und Herren,

#lorem(500)


// Grußformel und Unterschrift werden automatisch eingesetzt