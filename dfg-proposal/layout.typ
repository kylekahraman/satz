// Private DFG heading renderer. Keep original heading identity/counter/labels;
// translate KOMA's skips without adding Typst's own heading block a second time.
#let proposal-headings(c, body) = {
  show par: it => {
    state("satz-dfg-previous-block", none).update("body")
    it
  }
  show list: it => {
    it
    state("satz-dfg-previous-block", none).update("body")
  }
  show enum: it => {
    it
    state("satz-dfg-previous-block", none).update("body")
  }
  show math.equation.where(block: true): it => {
    it
    state("satz-dfg-previous-block", none).update("body")
  }
  show table: it => {
    it
    state("satz-dfg-previous-block", none).update("body")
  }
  show figure: it => {
    it
    state("satz-dfg-previous-block", none).update("body")
  }
  show heading: it => {
    context {
      let level = calc.min(it.level, 4)
      let previous = state("satz-dfg-previous-block", none).get()
      let above = if previous == "heading" { 0pt } else { c.headings.at("h" + str(level) + "-above") }
      let below = c.headings.at("h" + str(level) + "-below")
      let prefix = if it.numbering == none { none } else {
        numbering(it.numbering, ..counter(heading).at(it.location()))
      }
      let indent = if prefix == none { 0pt } else { measure(prefix).width + 0.5em }
      let spacing = if above == auto { (:) } else { (above: above) }
      // TeX's page-top baseline uses topskip, even for headings.
      let advance = 11 * 72 / 72.27 * 1pt - 1467 / 2048 * 11pt
      let at-top = it.location().position().y <= c.page.margin.top + advance + 0.1pt
      block(..spacing, below: below, sticky: true, breakable: false)[
        #if at-top { v(advance) }
        #set par(first-line-indent: 0pt, justify: false)
        #grid(columns: (indent, 1fr), if prefix != none { prefix } else { [] }, it.body)
      ]
    }
    state("satz-dfg-previous-block", none).update("heading")
  }
  body
}

// The reference title has five baseline rows, with a rule on the fourth.
#let proposal-title(c, title, applicant, project, description) = {
  set text(weight: "bold")
  grid(
    columns: (1fr,), row-gutter: c.typography.paragraph-spacing,
    title, applicant, project,
    box(width: 100%, height: 1467 / 2048 * 1em)[
      #place(bottom, dy: -0.25 * 72 / 72.27 * 1pt, line(length: 100%, stroke: 0.5 * 72 / 72.27 * 1pt))
    ],
    description,
  )
}
