// Reuses letter address components (absender/empfaenger/geschaeftszeile)
#import "../letter/components.typ": absender_block, empfaenger_block, geschaeftszeile_block

// Import invoice-specific components
#import "components.typ": posten_table, bank_qr_block, kleinunternehmer_notice, build_epc_string

/// A German invoice (Rechnung) with optional EPC QR code (GiroCode).
///
/// Generates a DIN 5008 conform invoice with automatic line item calculation,
/// bank details, and an optional scannable QR code for SEPA bank transfers.
/// When scanned, banking apps auto-fill IBAN, amount, and purpose.
///
/// Shares the letter template's address field, business line, and signature components.
///
/// - absender (dictionary): Sender/billing details
///   - name (str): Full name or company
///   - zusatz (str, none): Additional line (e.g. c/o)
///   - strasse (str): Street and house number
///   - plz_ort (str): Postal code and city
///   - steuernummer (str): Tax number
///   - iban (str): IBAN for bank transfer
///   - bic (str): BIC/SWIFT code (optional)
///   - bank (str): Bank name
///   - kontoinhaber (str): Bank account holder name. Defaults to absender.name.
/// - empfaenger (dictionary): Recipient
///   - name (str): Full name or company
///   - zusatz (str, none): Additional line (e.g. c/o)
///   - strasse (str): Street and house number
///   - plz_ort (str): Postal code and city
///   - land (str): Country (optional)
/// - datum (str): Invoice date, defaults to today
/// - rechnungsnummer (str): Invoice number
/// - leistungsdatum (str): Service period
/// - betreff (str): Subject line, defaults to "Rechnung"
/// - posten (array): Line items as (("Description", quantity, unit-price), ...)
/// - qr (bool): Enable EPC QR code for scan-to-pay
/// - qr-betrag (none, float): Override QR amount. None = auto-calculate from posten
/// - qr-verwendungszweck (str): Payment reference for QR code
/// - font (str): Body font family. Defaults to "Inter".
/// - kleinunternehmer (bool): Show German small business tax notice (§ 19 UStG)
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
    bank: "Musterbank",
    kontoinhaber: none,
    logo: none,
  ),
  empfaenger: (name: "", zusatz: none, strasse: "", plz_ort: "", land: ""),
  datum: datetime.today().display("[day].[month].[year]"),
  rechnungsnummer: "",
  leistungsdatum: "",
  betreff: "Rechnung",
  posten: (),
  qr: true,
  qr-betrag: none,
  qr-verwendungszweck: "",
  font: "Inter",
  kleinunternehmer: false,
  body
) = {
  let zeilenabstand = 0.65em

  // Ensure optional keys exist in absender and empfaenger (callers may omit them)
  let absender = (telefon: "", email: "", bic: "", zusatz: none, ..absender)
  let empfaenger = (zusatz: none, land: "", ..empfaenger)

  // --- Global styles ---
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
  set list(spacing: zeilenabstand)

  // --- Sender block (top-right) ---
  absender_block(absender, zeilenabstand, (tel: "Tel.", email: "E-Mail"))
  v(3 * zeilenabstand)

  // --- Recipient (window envelope field, shared with letter) ---
  // The letter's empfaenger_block takes (absender, empfaenger, postvermerk, strings).
  // Invoice: no postal remark, no i18n — pass empty postvermerk and dummy strings.
  empfaenger_block(absender, empfaenger, "", (:))
  v(4 * zeilenabstand)

  // --- Business reference line (shared with letter) ---
  geschaeftszeile_block(
    (
      ("Rechnungsnummer", rechnungsnummer),
      ("Leistungsdatum", leistungsdatum),
      ("Steuernummer", absender.steuernummer),
    ),
    datum,
    zeilenabstand,
    (datum: "Datum"),
  )
  v(2 * zeilenabstand)

  // --- Subject ---
  block(width: 100%)[
    #set text(weight: "bold", size: 11pt)
    #betreff
  ]
  v(2 * zeilenabstand)

  // --- Body ---
  body
  v(2 * zeilenabstand)

  // --- Line item table ---
  posten_table(posten)

  // --- Kleinunternehmer notice ---
  if kleinunternehmer {
    kleinunternehmer_notice(zeilenabstand)
  }

  // --- Bank details + QR code ---
  let qr-amount = if qr-betrag != none {
    qr-betrag
  } else if posten.len() > 0 {
    posten.map(p => p.at(1) * p.at(2)).sum()
  } else {
    0
  }
  let kontoinhaber = if absender.at("kontoinhaber", default: none) != none {
    absender.kontoinhaber
  } else {
    absender.name
  }
  let epc-string = build_epc_string(kontoinhaber, absender.at("bic", default: ""), absender.iban, qr-amount, qr-verwendungszweck)
  bank_qr_block(absender, qr, epc-string, zeilenabstand)

  [Mit freundlichen Grüßen]
  v(-1*zeilenabstand)
  absender.name

}
