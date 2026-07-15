#import "components.typ": absender_block, empfaenger_block, geschaeftszeile_block, signatur_block
#import "layout.typ": falz_und_locher_marken, seiten_footer

#let brief(
  absender: (name: "", strasse: "", plz_ort: "", telefon: "", email: ""),
  empfaenger: (name: "", zusatz: none, strasse: "", plz_ort: "", land: ""),
  datum: datetime.today().display("[day].[month].[year]"),
  geschaeftszeile: (),
  betreff: "",
  anlagenverzeichnis: (),
  anlagen: (),
  signatur_zusatz: "",
  postvermerk: "",
  lang: "de",
  body
) = {
  let zeilenabstand = 0.65em
  
  let strings = if lang == "de" {
    (
      tel: "Tel.",
      email: "E-Mail",
      datum: "Datum",
      anlagen: "Anlagen",
      betreff: betreff,
      page: "Seite",
      of: "von",
    )
  } else {
    (
      tel: "Phone",
      email: "Email",
      datum: "Date",
      anlagen: "Attachments",
      betreff: if betreff == "" { "Subject" } else { betreff },
      page: "Page",
      of: "of",
    )
  }
  
  // Stile konfigurieren
  set text(font: "Inter", size: 11pt, lang: lang, hyphenate: false, weight: "regular")
  set par(leading: zeilenabstand, justify: true)
  set page(
    "a4",
    margin: (left: 25mm, right: 20mm, top: 25mm, bottom: 25mm),
    background: falz_und_locher_marken(),
    footer: seiten_footer(strings),
  )

  // Dokumentenstruktur aufbauen
  absender_block(absender, zeilenabstand, strings)
  v(3 * zeilenabstand)
  
  empfaenger_block(absender, empfaenger, postvermerk, strings)
  v(4 * zeilenabstand)
  
  geschaeftszeile_block(geschaeftszeile, datum, zeilenabstand, strings)
  v(2 * zeilenabstand)

  block(width: 100%)[
    #set text(weight: "bold", size: 11.5pt)
    #betreff
  ]
  v(2 * zeilenabstand)

  // Inhalt aus main.typ
  body
  
  // Abschluss-Segmente
  signatur_block(absender.name, signatur_zusatz, zeilenabstand)

  if anlagen.len() > 0 {
    v(3 * zeilenabstand)
    block(breakable: false, [
      #text(weight: "bold", size: 10pt)[#strings.anlagen:] \
      #v(0.5em)
      #list(..anlagen.map(a => text(size: 9.5pt)[#a]))
    ])
    
    // PDF-Anhänge rendern
    for pdf_pfad in anlagen {
      set page(margin: 0mm, background: none, header: none, footer: none)
      image(pdf_pfad, width: 100%, height: 100%)
    }
  }  
}
