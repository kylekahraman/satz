// Legal complaint components — shared rendering for ZPO Klageschrift templates.

/// Renders the Rubrum (party identification block).
///
/// Format: Kläger → "— Klägerin —" → "gegen" → Beklagter → "— Beklagter —"
///
/// - klagername (str): Plaintiff name
/// - klagerin_adresse (content): Plaintiff address (strasse, plz_ort)
/// - beklagter (str): Defendant name
/// - beklagter_adresse (content): Defendant address (strasse, plz_ort)
#let rubrum_block(
  klagername,
  klagerin_adresse,
  beklagter,
  beklagter_adresse
) = {
  text(size: 10pt)[
    #text(weight: "bold")[#klagername] \
    #klagerin_adresse \
    \
    — Klägerin — \
    \
    #text(weight: "bold")[gegen] \
    \
    #text(weight: "bold")[#beklagter] \
    #beklagter_adresse \
    \
    — Beklagter —
  ]
}

/// Renders the Streitwert (amount in dispute) between two horizontal rules.
///
/// - streitwert (str): Amount, e.g. "600,00 EUR"
#let streitwert_block(streitwert) = {
  line(length: 100%, stroke: 0.5pt)
  v(0.3em)
  text(size: 10pt)[*vorläufiger Streitwert:* #streitwert]
  line(length: 100%, stroke: 0.5pt)
}

/// Renders the list of attachments (Anlagenverzeichnis).
///
/// - anlagen (array): Attachment descriptions as strings
/// - zeilenabstand (length): Spacing before the list
#let anlagen_liste(anlagen, zeilenabstand) = {
  if anlagen.len() > 0 {
    v(3em)
    text(weight: "bold", size: 10pt)[Anlagen:]
    v(0.3em)
    list(..anlagen.map(a => text(size: 9.5pt)[#a]))
  }
}

/// Renders the court-sender block (top-right, smaller than standard letter).
///
/// - name (str): Plaintiff name
/// - adresse (content): Street + zip/city
/// - zeilenabstand (length): Line spacing
#let court_absender_block(name, adresse, zeilenabstand) = {
  align(right, text(size: 8.5pt)[
    #name \
    #adresse
  ])
}

/// Renders the court-empfaenger block (recipient field for window envelopes).
///
/// - return_name (str): Name for the return-address line
/// - return_adresse (content): Return address (strasse, plz_ort)
/// - empfaenger_name (str): Court name
/// - empfaenger_adresse (content): Court address
#let court_empfaenger_block(return_name, return_adresse, empfaenger_name, empfaenger_adresse) = {
  block(width: 85mm)[
    #text(size: 7.5pt, fill: black)[#return_name · #return_adresse]
    #v(-2.5mm)
    #line(length: 100%, stroke: 0.25pt + black)
    #v(1.5mm)
    #text(size: 11pt)[
      #empfaenger_name \
      #empfaenger_adresse
    ]
  ]
}
