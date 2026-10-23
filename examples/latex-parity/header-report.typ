// Original comparison fixture, MIT, satz contributors (2026).
// Explicit page breaks make header selection independent of line breaking.
#import "../../lib.typ": document-class

#show: document-class.with(kind: "thesis", config: (
  page: (
    binding: if sys.inputs.at("single-sided", default: "false") == "true" { none } else { left },
    headers: sys.inputs.at("headers", default: "true") == "true",
  ),
  typography: (font: "New Computer Modern", leading: 6pt, hyphenate: true),
  colors: (bg-paper: white, text-main: black, text-muted: rgb("45556c")),
  lof: (depth: 0),
  lot: (depth: 0),
),
  header: if sys.inputs.at("custom-header", default: "false") == "true" { [Custom header] } else { none },
  footer: if sys.inputs.at("custom-footer", default: "false") == "true" { [Custom footer] } else { none },
)

#let case-body(marker) = [
  *#marker*

  This report records a fictional instrument check. The values illustrate
  document structure and do not describe an experiment. Each page has a fixed
  break so that the LaTeX and Typst versions exercise the same header case.

  A useful running head identifies the current chapter or section without
  carrying information from a previous chapter. Chapter-opening pages leave
  the running head empty. Continuation pages retain their context even when
  the chapter has no sections of its own.
]

= Instrument checks <ch:instrument>
== Aim
#case-body("CASE opening-a")
#pagebreak()

== Measurements
#case-body("CASE section-change")
#figure(
  table(
    columns: (1fr, auto),
    table.hline(stroke: 0.7pt),
    table.header([*Setting*], [*Example value*]),
    table.hline(stroke: 0.4pt),
    [Reference], [1.00],
    [Repeat], [1.02],
    table.hline(stroke: 0.7pt),
  ),
  kind: table,
  caption: [Illustrative readings; no experimental data.],
  placement: top,
) <tab:readings>
== Repeat measurements
The final section on this page supplies the running head.
#pagebreak()

#case-body("CASE continuation-a")
The readings in @tab:readings belong to @ch:instrument.
#figure(
  rect(width: 75%, height: 32mm, fill: luma(240), stroke: 0.5pt),
  caption: [Placeholder for an instrument diagram.],
  placement: top,
) <fig:instrument>
#pagebreak()

= Section-free chapter
#case-body("CASE opening-b")
#pagebreak()

#case-body("CASE continuation-b-even")
#pagebreak()

#heading(level: 2, numbering: none, outlined: false)[Local note]
#case-body("CASE continuation-b-odd")
#pagebreak()

== Follow-up
#case-body("CASE follow-up-even")
#pagebreak()

#case-body("CASE follow-up-odd")
The diagram in @fig:instrument remains linked across chapters.
#pagebreak()

#heading(level: 1, numbering: none)[Closing remarks]
#case-body("CASE opening-unnumbered")
#pagebreak()

#case-body("CASE unnumbered-odd")
#pagebreak()
#counter(page).update(4)
#case-body("CASE counter-reset")
