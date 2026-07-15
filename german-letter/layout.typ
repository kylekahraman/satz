#let falz_und_locher_marken() = context {
  if counter(page).get().first() == 1 [
    #place(top + left, dx: 0mm, dy: 0mm)[
      #place(top + left, dx: 4mm, dy: 105mm)[#line(length: 5mm, stroke: 0.35pt + luma(120))]
      #place(top + left, dx: 4mm, dy: 148.5mm)[#line(length: 7mm, stroke: 0.35pt + luma(120))]
      #place(top + left, dx: 4mm, dy: 210mm)[#line(length: 5mm, stroke: 0.35pt + luma(120))]
    ]
  ]
}

#let seiten_footer() = context {
  let p = counter(page).get().first()
  let last = counter(page).final().first()
  if p > 1 {
    align(center)[
      #text(size: 8.5pt, fill: black)[Seite #p von #last]
    ]
  }
}