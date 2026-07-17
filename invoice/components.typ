// Invoice-specific components — shared rendering not provided by the letter template.

/// Renders the sender block (Absender) top-right, invoice style.
///
/// Includes zusatz (c/o) line and bold company name.
/// No phone/email — those are letter-specific.
///
/// - absender (dictionary): Sender details (name, zusatz, strasse, plz_ort)
/// - zeilenabstand (length): Line spacing
#let absender_block(absender, zeilenabstand) = {
  align(right, text(size: 9pt)[
    #text(weight: "bold")[#absender.name] \
    #if absender.zusatz != none and absender.zusatz != "" [
      #absender.zusatz \
    ]
    #absender.strasse \
    #absender.plz_ort
  ])
}

/// Renders the line-item table (Posten) with quantity, unit price, and subtotals.
///
/// - posten (array): Line items as (("Description", quantity, unit-price), ...)
/// -> content
#let posten_table(posten) = {
  if posten.len() > 0 {
    let gesamt_summe = posten.map(p => p.at(1) * p.at(2)).sum()
    
    table(
      columns: (1fr, auto, auto, auto),
      inset: 5pt,
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
  block(width: 100%, breakable: false)[
    #v(2 * zeilenabstand)
    
    #if qr and absender.iban != "" [
      // QR Code and bank details side by side
      #grid(
        columns: (auto, 1fr),
        gutter: 2em,
        [
          #import "@preview/cades:0.3.1": qr-code
          #qr-code(epc-string, width: 3.5cm)
          #v(0.3em)
          #text(size: 7pt, fill: black.lighten(40%))[Scannen für Überweisung]
        ],
        [
          Bitte überweisen Sie den Gesamtbetrag auf das folgende Bankkonto:
          #v(0.5em)
          #grid(
            columns: (auto, 1fr),
            gutter: 12pt,
            [*Kontoinhaber:*], [#absender.name],
            [*Bank:*], [#absender.bank],
            [*IBAN:*], [#absender.iban],
          )
          #if absender.bic != "" [
            #grid(
              columns: (auto, 1fr),
              gutter: 12pt,
              [*BIC:*], [#absender.bic],
            )
          ]
        ]
      )
    ] else [
      Bitte überweisen Sie den Gesamtbetrag auf das folgende Bankkonto:
      #v(0.5em)
      #grid(
        columns: (auto, 1fr),
        gutter: 12pt,
        [*Kontoinhaber:*], [#absender.name],
        [*Bank:*], [#absender.bank],
        [*IBAN:*], [#absender.iban],
      )
      #if absender.bic != "" [
        #grid(
          columns: (auto, 1fr),
          gutter: 12pt,
          [*BIC:*], [#absender.bic],
        )
      ]
    ]
  ]
}

/// Shows the Kleinunternehmer notice (§ 19 UStG) when enabled.
///
/// German small businesses are exempt from VAT — this notice is legally required.
///
/// - zeilenabstand (length): Line spacing
#let kleinunternehmer_notice(zeilenabstand) = {
  v(2 * zeilenabstand)
  text(size: 9pt, style: "italic")[
    Als Kleinunternehmer im Sinne von § 19 Abs. 1 UStG wird keine Umsatzsteuer berechnet.
  ]
}

/// Builds the EPC QR code data string (GiroCode BCD format).
///
/// Banking apps parse this to auto-fill SEPA transfer forms.
///
/// - absender (dictionary): Sender details (name, iban, bic)
/// - qr-amount (float): Transfer amount
/// - qr-verwendungszweck (str): Payment reference
/// -> str
#let build_epc_string(absender, qr-amount, qr-verwendungszweck) = {
  "BCD\n002\n1\nSCT\n" + absender.bic + "\n" + absender.name + "\n" + absender.iban + "\nEUR" + str(qr-amount) + "\n\n" + qr-verwendungszweck + "\n"
}
