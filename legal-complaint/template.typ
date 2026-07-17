// Klageschrift template — ZPO-compliant civil complaint (Amtsgericht).
//
// Uses a wider right margin (35mm) for judicial binding margins.
// Includes Rubrum, Streitwert, Anträge section, and attachment list.

#import "components.typ": rubrum_block, streitwert_block, anlagen_liste, court_absender_block, court_empfaenger_block

/// A Klageschrift (statement of claim) for German civil courts (Amtsgericht).
///
/// Follows ZPO formatting conventions: party identification (Rubrum),
/// amount in dispute (Streitwert), numbered claims (Anträge), and
/// attachment list (Anlagenverzeichnis). Optionally includes anlagen PDF.
///
/// ```example
/// #show: klageschrift.with(
///   gericht: "Amtsgericht Musterstadt",
///   gericht_ort: "Gerichtsstraße 1, 12345 Musterstadt",
///   klagername: "Max Mustermann",
///   klagerin_str: "Musterstraße 1",
///   klagerin_plz: "12345 Musterstadt",
///   beklagter: "Erika Beispiel",
///   beklagter_str: "Beispielweg 2",
///   beklagter_plz: "54321 Beispielstadt",
///   streitwert: "1.000,00 EUR",
///   anlagen: ("Anlage K 1: Vertrag", "Anlage K 2: Rechnung"),
/// )
/// = Anträge
/// ...
/// ```
///
/// - gericht (str): Court name
/// - gericht_ort (str): Court address
/// - klagername (str): Plaintiff name
/// - klagerin_str (str): Plaintiff street
/// - klagerin_plz (str): Plaintiff postal code + city
/// - beklagter (str): Defendant name
/// - beklagter_str (str): Defendant street
/// - beklagter_plz (str): Defendant postal code + city
/// - streitwert (str): Amount in dispute, e.g. "600,00 EUR"
/// - anlagen (array): Attachment descriptions
/// - anlagen_pdf_path (none, str): Path to merged anlagen PDF. None = skip.
/// - anlagen_max_pages (int): Pages to include from the anlagen PDF
/// - font (str): Body font. Defaults to "Inter".
/// - body (content): Complaint body (Anträge + Begründung)
#let klageschrift(
  gericht: "Amtsgericht",
  gericht_ort: "",
  klagername: "",
  klagerin_str: "",
  klagerin_plz: "",
  beklagter: "",
  beklagter_str: "",
  beklagter_plz: "",
  streitwert: "",
  anlagen: (),
  anlagen_pdf_path: none,
  anlagen_max_pages: 30,
  font: "Inter",
  body,
) = {
  let zeilenabstand = 0.75em

  // --- Global styles ---
  set text(font: font, size: 11pt, lang: "de", hyphenate: false)
  set page(
    "a4",
    // Right margin 35mm — judicial binding margin (Heftrand)
    margin: (left: 25mm, right: 35mm, top: 25mm, bottom: 25mm),
    footer: context [
      #set text(size: 8.5pt)
      #align(center)[Seite #counter(page).get().first() von #counter(page).final().last()]
    ],
  )
  set par(justify: true, leading: zeilenabstand)

  // --- Sender block (top-right, smaller than letter version) ---
  court_absender_block(klagername, klagerin_str + " " + klagerin_plz, zeilenabstand)
  v(1.5em)

  // --- Recipient (window envelope field) ---
  court_empfaenger_block(
    klagername,
    klagerin_str + ", " + klagerin_plz,
    gericht,
    gericht_ort,
  )
  v(4em)

  // --- Title ---
  align(center, text(weight: "bold", size: 12pt)[Klage])
  v(1em)

  // --- Rubrum (party identification) ---
  rubrum_block(
    klagername,
    [#klagerin_str, #klagerin_plz],
    beklagter,
    [#beklagter_str, #beklagter_plz],
  )

  v(0.5em)

  // --- Streitwert ---
  streitwert_block(streitwert)
  v(1.5em)

  // --- Anträge ---
  text(weight: "bold", size: 11pt)[Anträge:]
  v(0.5em)

  body

  // --- Datum ---
  v(2em)
  align(right)[#datetime.today().display("[day].[month].[year]")]

  // --- Unterschrift ---
  v(4em)
  line(length: 40%, stroke: 0.5pt)
  v(0.3em)
  [#klagername \
  Klägerin]

  // --- Anlagenverzeichnis ---
  anlagen_liste(anlagen, zeilenabstand)

  // --- Anlagen PDF (optional) ---
  if anlagen_pdf_path != none {
    pagebreak()
    for p in range(1, anlagen_max_pages + 1) {
      set page(margin: 0cm, header: none, footer: none)
      image(anlagen_pdf_path, page: p, width: 100%, height: 100%)
    }
  }
}
