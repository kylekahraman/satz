// Invoice-specific components — absender, empfaenger, and geschaeftszeile are shared from letter.

/// Renders the line-item table (Posten) with quantity, unit price, and subtotals.
///
/// - posten (array): Line items as (("Description", quantity, unit-price), ...)
/// -> content
#let posten_table(posten) = {
  if posten.len() > 0 {
    let gesamt_summe = posten.map(p => p.at(1) * p.at(2)).sum()
    
    table(
      columns: (1fr, auto, auto, auto),
      inset: 7pt,
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
}

/// Renders the bank details and optional EPC QR code section.
///
/// - absender (dictionary): Sender details (name, bank, iban, bic)
/// - qr (bool): Show QR code
/// - epc-string (str): EPC QR code data string
/// - zeilenabstand (length): Line spacing
#let bank_qr_block(absender, qr, epc-string, zeilenabstand) = {
  let kontoinhaber = if absender.at("kontoinhaber", default: none) != none {
    absender.kontoinhaber
  } else {
    absender.name
  }
  let bic = absender.at("bic", default: "")
  block(width: 100%, breakable: false)[
    #v(2 * zeilenabstand)
    
    #if qr and absender.iban != "" [
      // QR Code and bank details side by side
      #grid(
        columns: (1fr, auto),
        gutter: 2em,
        [
          Bitte überweisen Sie den Gesamtbetrag innerhalb von 14 Tagen auf das folgende Konto:
          #v(0.5em)
          #grid(
            columns: (auto, 1fr),
            gutter: 12pt,
            [*Kontoinhaber:*], [#kontoinhaber],
            [*Bank:*], [#absender.bank],
            [*IBAN:*], [#absender.iban],
          )
        ],
        [
          #import "@preview/cades:0.3.1": qr-code
          #qr-code(epc-string, width: 3.5cm)
          #v(0.3em)
          #text(size: 7pt, fill: black.lighten(40%))[Scannen für Überweisung]
        ],
      )
    ] else [
      Bitte überweisen Sie den Gesamtbetrag innerhalb von 14 Tagen auf das folgende Konto:
      #v(0.5em)
      #grid(
        columns: (auto, 1fr),
        gutter: 12pt,
        [*Kontoinhaber:*], [#kontoinhaber],
        [*Bank:*], [#absender.bank],
        [*IBAN:*], [#absender.iban],
      )
    ]
  ]
}

/// Shows the Kleinunternehmer notice (§ 19 UStG) when enabled.
///
/// German small businesses are exempt from VAT — this notice is legally required.
///
/// - zeilenabstand (length): Line spacing
#let kleinunternehmer_notice(zeilenabstand) = {
  v(1 * zeilenabstand)
  text(size: 9pt, style: "italic")[
    Als Kleinunternehmer im Sinne von § 19 Abs. 1 UStG wird keine Umsatzsteuer berechnet.
  ]
}

/// Builds the EPC QR code data string (GiroCode BCD format).
///
/// Banking apps parse this to auto-fill SEPA transfer forms.
///
/// - kontoinhaber (str): Bank account holder name
/// - bic (str): BIC/SWIFT code
/// - iban (str): IBAN
/// - qr-amount (float): Transfer amount
/// - qr-verwendungszweck (str): Payment reference
/// -> str
#let build_epc_string(kontoinhaber, bic, iban, qr-amount, qr-verwendungszweck) = {
  "BCD\n002\n1\nSCT\n" + bic + "\n" + kontoinhaber + "\n" + iban + "\nEUR" + str(qr-amount) + "\n\n" + qr-verwendungszweck + "\n"
}
