#let absender_block(absender, zeilenabstand) = {
  align(right, text(size: 9pt)[
    #absender.name \
    #absender.strasse \
    #absender.plz_ort \
    #if absender.telefon != none [Tel.: #absender.telefon \ ]
    #if absender.email != none [E-Mail: #link("mailto:" + absender.email)[#absender.email]]
  ])
}

#let empfaenger_block(absender, empfaenger) = {
  block(width: 85mm)[
    #text(size: 7pt, fill: black)[
      #absender.name · #absender.strasse · #absender.plz_ort
    ]
    #v(-2.5mm)
    #line(length: 100%, stroke: 0.25pt + black) 
    #v(1.5mm)
    #text(size: 11pt)[
      #empfaenger.join("\n")
    ]
  ]
}

#let geschaeftszeile_block(geschaeftszeile, datum, zeilenabstand) = {
  block(width: 100%)[
    #let alle_posten = geschaeftszeile + (("Datum", datum),)
    #let spalten_anzahl = alle_posten.len()
    
    #let bloecke = alle_posten.enumerate().map(((i, pair)) => {
      let text_ausrichtung = if i == spalten_anzahl - 1 { right } else { left }
      block(align(text_ausrichtung)[
        #text(size: 7.5pt)[#pair.at(0)] \
        #text(size: 9pt)[#pair.at(1)]
      ])
    })
    
    #stack(dir: ltr, spacing: 1fr, ..bloecke)
  ]
}

#let signatur_block(name, zusatz, zeilenabstand) = {
  //* commmented out if i want to write this myself
  // v(2 * zeilenabstand)
  // [Mit freundlichen Grüßen]
  v(5 * zeilenabstand)
  line(length: 40%, stroke: 0.5pt + black)
  v(1 * zeilenabstand)
  name
  if zusatz != "" {
    v(0.3em)
    text(size: 9pt)[#zusatz]
  }
}