// Compare the public report with equivalent native heading styling.
#import "../../lib.typ": report
#import "typography-content.typ": specimen

#let native(body) = {
  set page(paper: "a4", margin: 25mm, fill: white)
  set text(font: "New Computer Modern", size: 11pt, fill: black)
  set par(leading: 6pt, spacing: 1.2em, justify: true)
  set heading(numbering: "1.1")
  show heading.where(level: 1): set text(size: 14pt, weight: "bold")
  show heading.where(level: 2): set text(size: 12pt, weight: "bold")
  show heading.where(level: 3): set text(size: 11pt, weight: "bold")
  show heading.where(level: 4): set text(size: 11pt, weight: "bold")
  show heading.where(level: 1): set block(below: 1em)
  show heading.where(level: 2): set block(below: 1em)
  show heading.where(level: 3): set block(below: 0.9em)
  show heading.where(level: 4): set block(below: 0.75em)
  set list(tight: false, spacing: 0.9em)
  body
}

#let template = if sys.inputs.at("mode", default: "report") == "native" {
  native
} else {
  report.with(config: (
    typography: (font: "New Computer Modern", size: 11pt, leading: 6pt),
    colors: (bg-paper: white, text-main: black, brand-primary: black),
    toc: (depth: 0),
  ))
}
#show: template
#specimen
