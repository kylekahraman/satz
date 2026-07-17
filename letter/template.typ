#import "components.typ": absender_block, empfaenger_block, geschaeftszeile_block, signatur_block
#import "layout.typ": falz_und_locher_marken, seiten_footer

/// A DIN 5008 conform German business letter with fold and punch marks.
///
/// Supports window envelopes (Fensterbriefumschlag) with automatic
/// positioning of the address field. Internationalization via `lang` parameter.
///
/// - absender (dictionary): Sender details
///   - name (str): Full name or company
///   - zusatz (none, str): Optional additional line (e.g. c/o)
///   - strasse (str): Street and house number
///   - plz_ort (str): Postal code and city
///   - telefon (str): Phone number (optional)
///   - email (str): Email address (optional)
/// - empfaenger (dictionary): Recipient details
///   - name (str): Full name or company
///   - zusatz (str, none): Additional line (e.g. c/o, z.Hd.)
///   - strasse (str): Street and house number
///   - plz_ort (str): Postal code and city
///   - land (str): Country (optional, for international mail)
/// - datum (str): Date string. Defaults to today in DIN 5008 format (YYYY-MM-DD).
/// - geschaeftszeile (array): Reference line as (("Label", "Value"), ...)
/// - betreff (str): Subject line
/// - postvermerk (str): Postal remark (e.g. "Einschreiben", "Eilzustellung")
/// - anlagenverzeichnis (array): Attachment descriptions
/// - anlagen (array): Attachment file paths (PDFs are rendered inline)
/// - signatur_zusatz (str): Additional text below signature name
/// - lang (str): Language — "de" (German) or "en" (English)
/// - font (str): Body font family. Defaults to "Inter".
/// - body (content): Letter body content
#let brief(
  absender: (name: "", zusatz: none, strasse: "", plz_ort: "", telefon: "", email: ""),
  empfaenger: (name: "", zusatz: none, strasse: "", plz_ort: "", land: ""),
  datum: datetime.today().display("[year]-[month]-[day]"),
  geschaeftszeile: (),
  betreff: "",
  anlagenverzeichnis: (),
  anlagen: (),
  signatur_zusatz: "",
  postvermerk: "",
  lang: "de",
  font: "Inter",
  body
) = {
  // Ensure zusatz exists in absender (callers may omit it)
  let absender = (zusatz: none, ..absender)
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
  set text(font: font, size: 11pt, lang: lang, hyphenate: false, weight: "regular")
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
