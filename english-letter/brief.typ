#let brief(
  absender: (
    name: "Kyle Kahraman",
    strasse: "Konrad-Broßwitz-Straße 43",
    plz_ort: "60487 Frankfurt am Main",
    telefon: "+49 176 32730934",
    email: "kylekahraman@gmail.com",
  ),
  empfaenger: [],
  datum: datetime.today().display("[day].[month].[year]"),
  geschaeftszeile: (),
  betreff: "",
  anlagenverzeichnis: (), // Optional
  anlagen: (),
  body,
) = {
  // --- Globale Stile ---
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
    footer: context {
      let p = counter(page).get().first()
      let last = counter(page).final().first()
      if p > 1 {
        align(center)[
          #text(size: 8.5pt, fill: black)[Seite #p von #last]
        ]
      }
    },
  )
  
  set par(leading: zeilenabstand, justify: true)
  
  // --- Absenderblock ---
  align(right, text(size: 9pt)[
    #absender.name \
    #absender.strasse \
    #absender.plz_ort \
    #if absender.telefon != none [Phone: #absender.telefon \ ]
    #if absender.email != none [E-Mail: #link("mailto:" + absender.email)[#absender.email]]
  ])
  
  v(3 * zeilenabstand)
  
  // --- Empfänger ---
  block(width: 85mm)[
    #text(size: 7pt, fill: black)[
      #absender.name · #absender.strasse · #absender.plz_ort
    ]
    #v(-2.5mm)
    #line(length: 100%, stroke: 0.25pt)
    #v(1.5mm)
    #text(size: 11pt)[
      #empfaenger.join("\n")
    ]
  ]
  
  v(4 * zeilenabstand)
  
  // --- Geschaeftszeile ---
  block(width: 100%)[
    #let spalten_anzahl = geschaeftszeile.len() + 1
    #grid(
      columns: (1fr,) * spalten_anzahl,
      gutter: 10pt,
      // 1. Alle vom User definierten Variablen rendern
      ..geschaeftszeile.map(item => [
        #text(size: 7.5pt)[#item.at(0)] \
        #text(size: 9pt)[#item.at(1)]
      ]),
      // 2. Das Datum steht als letztes Element IMMER ganz rechts
      align(right)[
        #text(size: 7.5pt)[Date] \
        #text(size: 9pt)[#datum]
      ]
    )
  ]
  
  v(2 * zeilenabstand)
  
  // --- Betreff ---
  block(width: 100%)[
    #set text(weight: "bold", size: 11.5pt)
    #betreff
  ]
  
  v(2 * zeilenabstand)
  
  // --- Textkörper (Inhalt aus main.typ) ---
  body
  
  // --- Grußformel & Unterschriftenlinie ---
  v(2 * zeilenabstand)
  [Sincerely]
  
  v(5 * zeilenabstand)
  line(length: 40%, stroke: 0.5pt)
  v(1 * zeilenabstand)
  absender.name
  
  // --- Text-Anlagenverzeichnis ---
  if anlagen.len() > 0 {
    v(3 * zeilenabstand)
    block(breakable: false, [
      #text(weight: "bold", size: 10pt)[Anlagen:] \
      #v(0.5em)
      #list(..anlagen.map(a => text(size: 9.5pt)[#a]))
    ])
  }
  
  // --- NEU: PDF-ANHÄNGE DIREKT INJEZIEREN ---
  if anlagen.len() > 0 {
    for pdf_pfad in anlagen {
      set page(margin: 0mm, background: none, header: none, footer: none)
      image(pdf_pfad, width: 100%, height: 100%)
    }
  }
}