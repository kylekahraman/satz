#import "components.typ": absender_block, digitaler_absender_block, empfaenger_block, digitaler_empfaenger_block, geschaeftszeile_block, digitales_datum_block, signatur_block
#import "layout.typ": falz_und_locher_marken, seiten_footer

/// A letter with optional postal and digital components.
///
/// Defaults to a DIN 5008 layout that fits window envelopes. For a PDF letter,
/// disable the envelope features and use the digital sender and date blocks.
/// Set `lang` to "de" or "en" to switch languages.
///
/// - absender (dictionary): your details
///   - name (str): your name or company
///   - zusatz (none, str): extra line if you need it (e.g. c/o)
///   - strasse (str): street and number
///   - plz_ort (str): zip and city
///   - telefon (str): phone (optional)
///   - email (str): email (optional)
///   - website (str): website without https:// (optional; digital sender only)
///   - logo (none, content): e.g. `image("logo.pdf", width: 3cm)`
/// - empfaenger (dictionary): who gets the letter
///   - name (str): name or company
///   - zusatz (str, none): extra line (e.g. c/o, z.Hd.)
///   - strasse (str): street and number
///   - plz_ort (str): zip and city
///   - land (str): country (for international mail)
/// - datum (str): date — defaults to today (YYYY-MM-DD)
/// - geschaeftszeile (array): ref line as (("Label", "Value"), ...)
/// - betreff (str): subject line
/// - postvermerk (str): postal note like "Einschreiben"
/// - anlagenverzeichnis (array): what you attach (just the names)
/// - anlagen (array): PDFs to include inline
/// - signatur_zusatz (str): extra line under your name
/// - lang (str): "de" or "en"
/// - font (str): body font — defaults to "Inter"
/// - falzmarken (bool): show fold and punch marks (default: true)
/// - adressfenster (bool): use the window-envelope recipient field (default: true)
/// - seitenzahlen (bool): show page numbers after page 1 (default: true)
/// - digitaler_absender (bool): show a name/contact header without postal address (default: false)
/// - datum_rechts (bool): put the date at the right when there are no reference fields (default: false)
/// - blocksatz (bool): justify body paragraphs (default: true)
/// - absender_anzeigen (bool): include the sender block (default: true)
/// - empfaenger_anzeigen (bool): include the recipient block (default: true)
/// - datum_anzeigen (bool): include the date block (default: true)
/// - betreff_anzeigen (bool): include the subject line (default: true)
/// - papier (str): page size, e.g. "a4" (default: "a4")
/// - seitenraender (dictionary): page margins; partial overrides are allowed
/// - schriftgroesse (length): body text size (default: 11pt)
/// - zeilenabstand (length): body leading, also used for default block gaps
/// - abstaende (dictionary): vertical gaps between sender, recipient, date, subject, and body
/// - betreff_groesse (length): subject size (default: 11.5pt)
/// - digitaler_absender_hoehe (length): reserved digital sender-header height (default: 19mm)
/// - body (content): your letter text
#let brief(
  absender: (name: "", zusatz: none, strasse: "", plz_ort: "", telefon: "", email: "", logo: none),
  empfaenger: (name: "", zusatz: none, strasse: "", plz_ort: "", land: ""),
  datum: datetime.today().display("[year]-[month]-[day]"),
  geschaeftszeile: (),
  betreff: "",
  anlagenverzeichnis: (),
  anlagen: (),
  signatur_zusatz: "",
  signatur: true,
  postvermerk: "",
  lang: "de",
  font: "Inter",
  falzmarken: true,
  adressfenster: true,
  seitenzahlen: true,
  digitaler_absender: false,
  datum_rechts: false,
  blocksatz: true,
  absender_anzeigen: true,
  empfaenger_anzeigen: true,
  datum_anzeigen: true,
  betreff_anzeigen: true,
  papier: "a4",
  seitenraender: (:),
  schriftgroesse: 11pt,
  zeilenabstand: 0.65em,
  abstaende: (:),
  betreff_groesse: 11.5pt,
  digitaler_absender_hoehe: 19mm,
  body
) = {
  // Ensure optional keys exist in absender and empfaenger (callers may omit them)
  let absender = (telefon: "", email: "", zusatz: none, ..absender)
  let empfaenger = (zusatz: none, land: "", ..empfaenger)
  let seitenraender = (
    left: 25mm,
    right: 20mm,
    top: 25mm,
    bottom: 25mm,
    ..seitenraender,
  )
  let abstaende = (
    absender_empfaenger: 3 * zeilenabstand,
    absender_datum: 4 * zeilenabstand,
    absender_betreff: 4 * zeilenabstand,
    absender_text: 2 * zeilenabstand,
    empfaenger_datum: 4 * zeilenabstand,
    empfaenger_betreff: 4 * zeilenabstand,
    empfaenger_text: 2 * zeilenabstand,
    datum_betreff: 2 * zeilenabstand,
    betreff_text: 2 * zeilenabstand,
    datum_text: 2 * zeilenabstand,
    signatur: 5 * zeilenabstand,
    ..abstaende,
  )
  
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
  set text(font: font, size: schriftgroesse, lang: lang, hyphenate: false, weight: "regular")
  set par(leading: zeilenabstand, justify: blocksatz)
  set list(spacing: zeilenabstand)
  set page(
    paper: papier,
    margin: seitenraender,
    background: if falzmarken { falz_und_locher_marken() } else { none },
    footer: if seitenzahlen { seiten_footer(strings) } else { none },
  )

  // Heading show rules — headings match body size (11pt), only differ by weight/style.
  // This keeps the Betreff (11.5pt bold) as the visually dominant element per DIN 5008.
  show heading.where(level: 1): it => block(below: 0.65em)[
    #set text(weight: "bold", size: 11pt)
    #it
  ]
  show heading.where(level: 2): it => block(below: 0.65em)[
    #set text(weight: "bold", size: 11pt)
    #it
  ]
  show heading.where(level: 3): it => block(below: 0.65em)[
    #set text(weight: "bold", size: 11pt)
    #it
  ]
  show heading.where(level: 4): it => block(below: 0.65em)[
    #set text(weight: "italic", size: 11pt)
    #it
  ]

  // Dokumentenstruktur aufbauen
  if absender_anzeigen {
    if digitaler_absender {
      digitaler_absender_block(absender, hoehe: digitaler_absender_hoehe)
    } else {
      absender_block(absender, zeilenabstand, strings)
    }
  }
  if absender_anzeigen {
    if empfaenger_anzeigen {
      v(abstaende.absender_empfaenger)
    } else if datum_anzeigen {
      v(abstaende.absender_datum)
    } else if betreff_anzeigen {
      v(abstaende.absender_betreff)
    } else {
      v(abstaende.absender_text)
    }
  }
  if empfaenger_anzeigen {
    if adressfenster {
      empfaenger_block(absender, empfaenger, postvermerk, strings)
    } else {
      digitaler_empfaenger_block(empfaenger)
    }
  }
  if empfaenger_anzeigen {
    if datum_anzeigen {
      v(abstaende.empfaenger_datum)
    } else if betreff_anzeigen {
      v(abstaende.empfaenger_betreff)
    } else {
      v(abstaende.empfaenger_text)
    }
  }
  if datum_anzeigen {
    if datum_rechts and geschaeftszeile.len() == 0 {
      digitales_datum_block(datum, strings)
    } else {
      geschaeftszeile_block(geschaeftszeile, datum, zeilenabstand, strings)
    }
  }
  if datum_anzeigen {
    if betreff_anzeigen {
      v(abstaende.datum_betreff)
    } else {
      v(abstaende.datum_text)
    }
  }
  if betreff_anzeigen {
    block(width: 100%)[
      #set text(weight: "bold", size: betreff_groesse)
      #betreff
    ]
    v(abstaende.betreff_text)
  }

  // Inhalt aus main.typ
  body
  
  // Abschluss-Segmente
  if signatur {
    signatur_block(absender.name, signatur_zusatz, zeilenabstand, abstaende.signatur)
  }

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
