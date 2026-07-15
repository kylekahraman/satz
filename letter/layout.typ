/// Draws fold and punch marks (Falz- und Lochmarken) on page 1.
///
/// DIN 5008: three horizontal marks on the left edge at 105mm, 148.5mm, and 210mm
/// from the top. Only rendered on the first page.
/// -> content (background for set page)
#let falz_und_locher_marken() = context {
  if counter(page).get().first() == 1 [
    #place(top + left, dx: 0mm, dy: 0mm)[
      #place(top + left, dx: 4mm, dy: 105mm)[#line(length: 5mm, stroke: 0.35pt + luma(120))]
      #place(top + left, dx: 4mm, dy: 148.5mm)[#line(length: 7mm, stroke: 0.35pt + luma(120))]
      #place(top + left, dx: 4mm, dy: 210mm)[#line(length: 5mm, stroke: 0.35pt + luma(120))]
    ]
  ]
}

/// Renders the page footer with localized page numbering.
///
/// Shows "Page X of Y" (or "Seite X von Y") on pages 2+.
/// Page 1 has no footer (assumed to be the letterhead page).
///
/// - strings (dictionary): i18n strings (page, of keys)
/// -> content (footer for set page)
#let seiten_footer(strings) = context {
  let p = counter(page).get().first()
  let last = counter(page).final().first()
  if p > 1 {
    align(center)[
      #text(size: 8.5pt, fill: black)[#strings.page #p #strings.of #last]
    ]
  }
}
