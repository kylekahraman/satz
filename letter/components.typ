#let absender_block(absender, zeilenabstand, strings) = {
  align(right, text(size: 9pt)[
    #absender.name \
    #absender.strasse \
    #absender.plz_ort \
    #if absender.telefon != "" and absender.telefon != none [
      #strings.tel: #absender.telefon \
    ]
    #if absender.email != "" and absender.email != none [
      #strings.email: #link("mailto:" + absender.email)[#absender.email]
    ]
  ])
}

#let empfaenger_block(absender, empfaenger, postvermerk, strings) = {
  // DIN 5008: address field for window envelope
  // Window position: 45mm from top, 20mm from left, 85mm × 45mm
  // The page top margin (25mm) + preceding content positions this correctly.
  // Verify with actual window envelope before production use.
  block(width: 85mm)[
    // Small sender reference line above the address
    #if absender.name != "" [
      #text(size: 7pt, fill: black)[
        #absender.name · #absender.strasse · #absender.plz_ort
      ]
      #v(-2.5mm)
      #line(length: 100%, stroke: 0.25pt + black)
      #v(1.5mm)
    ]
    // Postal remark (Versendungsvermerk) — right-aligned above recipient
    #if postvermerk != "" [
      #align(right, text(weight: "bold", size: 10pt)[#postvermerk])
      #v(0.3em)
    ]
    // Recipient address
    #text(size: 11pt)[
      #if empfaenger.name != "" [
        #empfaenger.name
        \
      ]
      #if empfaenger.zusatz != none and empfaenger.zusatz != "" [
        #empfaenger.zusatz
        \
      ]
      #if empfaenger.strasse != "" [
        #empfaenger.strasse
        \
      ]
      #if empfaenger.plz_ort != "" [
        #empfaenger.plz_ort
      ]
      #if empfaenger.land != "" [
        \
        #empfaenger.land
      ]
    ]
  ]
}

#let geschaeftszeile_block(geschaeftszeile, datum, zeilenabstand, strings) = {
  block(width: 100%)[
    #let alle_posten = geschaeftszeile + ((strings.datum, datum),)
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
  v(5 * zeilenabstand)
  line(length: 40%, stroke: 0.5pt + black)
  v(1 * zeilenabstand)
  name
  if zusatz != "" {
    v(0.3em)
    text(size: 9pt)[#zusatz]
  }
}
