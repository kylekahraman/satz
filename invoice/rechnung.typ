#import "@preview/cades:0.3.1": qr-code

/// A German invoice (Rechnung) with optional EPC QR code (GiroCode).
///
/// Generates a DIN 5008 conform invoice with automatic line item calculation,
/// bank details, and an optional scannable QR code for SEPA bank transfers.
/// When scanned, banking apps auto-fill IBAN, amount, and purpose.
///
/// - absender (dictionary): Sender/billing details
///   - name (str): Full name or company
///   - zusatz (none, str): Optional additional line (e.g. c/o)
///   - strasse (str): Street and house number
///   - plz_ort (str): Postal code and city
///   - steuernummer (str): Tax number (Steuernummer)
///   - iban (str): IBAN for bank transfer
///   - bic (str): BIC/SWIFT code (optional)
///   - bank (str): Bank name
/// - empfaenger (dictionary): Recipient details
///   - name (str): Full name or company
///   - zusatz (none, str): Optional additional line (e.g. c/o, z.Hd.)
///   - strasse (str): Street and house number
///   - plz_ort (str): Postal code and city
///   - land (str): Country (optional, for international mail)
/// - datum (str): Invoice date, defaults to today
/// - rechnungsnummer (str): Invoice number
/// - leistungsdatum (str): Service period (Leistungszeitraum)
/// - betreff (str): Subject line, defaults to "Rechnung"
/// - posten (array): Line items as (("Description", quantity, unit-price), ...)
/// - qr (bool): Enable EPC QR code (GiroCode) for scan-to-pay
/// - qr-betrag (none, float): Override QR amount. None = auto-calculate from posten
/// - qr-verwendungszweck (str): Payment reference for QR code
/// - font (str): Body font family. Defaults to "Inter".
/// - kleinunternehmer (bool): Show German small business tax exemption notice (§ 19 UStG).
/// - body (content): Invoice body content (letter text)
#let rechnung(
  absender: (
    name: "Musterfirma GmbH",
    zusatz: none,
    strasse: "Musterstraße 1",
    plz_ort: "12345 Musterstadt",
    steuernummer: "000/000/00000",
    iban: "DE00 0000 0000 0000 0000 00",
    bic: "",
    bank: "Musterbank"
  ),
  empfaenger: (name: "", zusatz: none, strasse: "", plz_ort: "", land: ""),
  datum: datetime.today().display("[day].[month].[year]"),
  rechnungsnummer: "",
  leistungsdatum: "",
  betreff: "Rechnung",
  posten: (), // Format: (("Text", Menge, Preis),)
  qr: true,
  qr-betrag: none,
  qr-verwendungszweck: "",
  font: "Inter",
  kleinunternehmer: false,
  body
) = {
  // --- Globale Stile & Raster ---
  let zeilenabstand = 0.65em
  set text(font: font, size: 11pt, lang: "de", hyphenate: false, weight: "regular")
  
  set page(
    "a4",
    margin: (left: 25mm, right: 20mm, top: 25mm, bottom: 25mm),
    background: context {
      if counter(page).get().first() == 1 [
        #place(top + left, dx: 0mm, dy: 0mm)[
          #place(top + left, dx: 2.5mm, dy: 105mm)[#line(length: 5mm, stroke: 0.25pt + black)]
          #place(top + left, dx: 2.5mm, dy: 148.5mm)[#line(length: 7mm, stroke: 0.25pt + black)]
          #place(top + left, dx: 2.5mm, dy: 210mm)[#line(length: 5mm, stroke: 0.25pt + black)]
        ]
      ]
    },
  )

  set par(leading: zeilenabstand, justify: true)

  // --- Absenderblock (rechts) ---
  align(right, text(size: 9pt)[
    #text(weight: "bold")[#absender.name] \
    #if absender.zusatz != none and absender.zusatz != "" [
      #absender.zusatz \
    ]
    #absender.strasse \
    #absender.plz_ort
  ])

  v(3 * zeilenabstand)

  // --- Empfänger ---
  block(width: 85mm)[
    #text(size: 8pt, fill: black)[
      #absender.name · #absender.strasse · #absender.plz_ort
    ]
    #v(-2.5mm)
    #line(length: 100%, stroke: 0.25pt)
    #v(1.5mm)
    #text(size: 11pt)[
      #if empfaenger.zusatz != none and empfaenger.zusatz != "" [
        #empfaenger.zusatz \
      ]
      #empfaenger.name \
      #empfaenger.strasse \
      #empfaenger.plz_ort
      #if empfaenger.land != "" and empfaenger.land != none [
        \
        #empfaenger.land
      ]
    ]
  ]

  v(4 * zeilenabstand)

  // --- Geschäftszeile ---
  block(width: 100%)[
    #grid(
      columns: (1fr, 1fr, 1fr, 1fr),
      gutter: 10pt,
      [
        #text(size: 7.5pt, fill: black.lighten(30%))[Rechnungsnummer] \
        #text(size: 9pt)[#rechnungsnummer]
      ],
      [
        #text(size: 7.5pt, fill: black.lighten(30%))[Leistungszeitraum] \
        #text(size: 9pt)[#leistungsdatum]
      ],
      [
        #text(size: 7.5pt, fill: black.lighten(30%))[Steuernummer] \
        #text(size: 9pt)[#absender.steuernummer]
      ],
      align(right)[
        #text(size: 7.5pt, fill: black.lighten(30%))[Datum] \
        #text(size: 9pt)[#datum]
      ]
    )
  ]
  
  v(2 * zeilenabstand)

  // --- Betreff ---
  block(width: 100%)[
    #set text(weight: "bold", size: 11pt)
    #betreff
  ]

  v(2 * zeilenabstand)

  body

  v(2 * zeilenabstand)

  if posten.len() > 0 {
    let gesamt_summe = posten.map(p => p.at(1) * p.at(2)).sum()
    
    table(
      columns: (1fr, auto, auto, auto),
      inset: 5pt,
      align: (left, center, right, right),
      stroke: none,
      
      table.hline(stroke: 0.5pt),
      [*Beschreibung*], [*Anzahl*], [*Einzelpreis*], [*Gesamt*],
      table.hline(stroke: 0.25pt),
      
      ..posten.map(p => (
        [#p.at(0)],
        [#p.at(1)],
        [#p.at(2) €],
        [#(p.at(1) * p.at(2)) €]
      )).flatten(),
      
      table.hline(stroke: 0.5pt),
      [], [], [*Gesamtbetrag:*], [*#gesamt_summe €*],
      table.hline(stroke: 0.5pt)
    )
  }

  // --- Bank details + QR Code section ---
  v(2 * zeilenabstand)
  
  // Calculate the actual amount for QR code
  let qr-amount = if qr-betrag != none {
    qr-betrag
  } else if posten.len() > 0 {
    posten.map(p => p.at(1) * p.at(2)).sum()
  } else {
    0
  }
  
  // Build EPC QR code string
  // Format: Service Tag\nVersion\nEncoding\nIdentification\nBIC\nName\nIBAN\nAmount\nPurpose\nReference\nInfo
  let epc-string = "BCD\n002\n1\nSCT\n" + absender.bic + "\n" + absender.name + "\n" + absender.iban + "\nEUR" + str(qr-amount) + "\n\n" + qr-verwendungszweck + "\n"

  block(width: 100%, breakable: false)[
    #if kleinunternehmer [
      #text(size: 9pt, style: "italic")[
        Als Kleinunternehmer im Sinne von § 19 Abs. 1 UStG wird keine Umsatzsteuer berechnet.
      ]
      #v(2 * zeilenabstand)
    ]
    
    #v(2 * zeilenabstand)
    
    #if qr and absender.iban != "" [
      // QR Code and bank details side by side
      #grid(
        columns: (auto, 1fr),
        gutter: 2em,
        [
          // EPC QR Code
          #qr-code(epc-string, width: 3.5cm)
          #v(0.3em)
          #text(size: 7pt, fill: black.lighten(40%))[Scannen für Überweisung]
        ],
        [
          Bitte überweisen Sie den Gesamtbetrag auf das folgende Bankkonto:
          #v(0.5em)
          #grid(
            columns: (auto, 1fr),
            gutter: 12pt,
            [*Kontoinhaber:*], [#absender.name],
            [*Bank:*], [#absender.bank],
            [*IBAN:*], [#absender.iban],
          )
          #if absender.bic != "" [
            #grid(
              columns: (auto, 1fr),
              gutter: 12pt,
              [*BIC:*], [#absender.bic],
            )
          ]
        ]
      )
    ] else [
      Bitte überweisen Sie den Gesamtbetrag auf das folgende Bankkonto:
      #v(0.5em)
      #grid(
        columns: (auto, 1fr),
        gutter: 12pt,
        [*Kontoinhaber:*], [#absender.name],
        [*Bank:*], [#absender.bank],
        [*IBAN:*], [#absender.iban],
      )
      #if absender.bic != "" [
        #grid(
          columns: (auto, 1fr),
          gutter: 12pt,
          [*BIC:*], [#absender.bic],
        )
      ]
    ]
  ]

  v(2 * zeilenabstand)
  [Mit freundlichen Grüßen]
  v(5 * zeilenabstand)
  absender.name
}
