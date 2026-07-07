#let rechnung(
  absender: (
    name: "Sun's Sons GbR",
    strasse: "Vogelsbergstr. 32",
    plz_ort: "60316 Frankfurt am Main",
    steuernummer: "014 373 30175",
    iban: "DE64 1001 1001 2623 4414 56",
    bank: "N26 Bank"
  ),
  empfaenger: [], 
  datum: datetime.today().display("[day].[month].[year]"),
  rechnungsnummer: "",
  leistungsdatum: "", 
  betreff: "Rechnung",
  posten: (), // Format: (("Text", Menge, Preis),)
  body
) = {
  // --- Globale Stile & Raster ---
  let zeilenabstand = 0.65em
  set text(font: "Inter", size: 11pt, lang: "de", hyphenate: false, weight: "regular")
  
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
      #empfaenger
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

  //v(2*zeilenabstand)


  block(width: 100%, breakable: false)[
    #text(size: 9pt, style: "italic")[
      Als Kleinunternehmer im Sinne von § 19 Abs. 1 UStG wird keine Umsatzsteuer berechnet.
    ]
    
    #v(2 * zeilenabstand)
    Bitte überweisen Sie den Gesamtbetrag auf das folgende Bankkonto:
    #grid(
      columns: (auto, 1fr),
      gutter: 12pt,
      [*Kontoinhaber:*], [Kyle Kahraman],
      [*Bank:*], [#absender.bank],
      [*IBAN:*], [#absender.iban],
    )
  ]

  v(2 * zeilenabstand)
  [Mit freundlichen Grüßen]
  v(5 * zeilenabstand)
  absender.name
}