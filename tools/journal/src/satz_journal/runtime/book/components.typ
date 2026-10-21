// Components for authoring educational books.

#let book-style = state("satz-book-style", (
  accent: rgb("#23616B"),
  ink: rgb("#24313B"),
  contents: (
    title-before: 24.5pt,
    title-after: 26pt,
    title-size: 17pt,
    entry-size: 10pt,
    entry-spacing: 11.8pt,
  ),
  worked-example: (
    inset: 27pt,
    above: 26pt,
    below: 27pt,
    label-gap: 0pt,
    label-size: 9pt,
    body-size: 9pt,
  ),
  exercise: (
    grid-gap: 11pt,
    group-gap: 20pt,
  ),
  footer-dy: 5pt,
  footer: black,
  grid: rgb("#D2D2D2"),
  grid-width: 0.2pt,
))

/// A worked example with a restrained label and indented content.
///
/// - body (content): worked steps or a short worked calculation
/// - above (length, none): optional local space before the block
/// - below (length, none): optional local space after the block
/// - inset (length, none): optional local left inset
#let worked-example(body, above: none, below: none, inset: none) = context {
  let style = book-style.get()
  let layout = style.worked-example
  let top-space = if above == none { layout.above } else { above }
  let bottom-space = if below == none { layout.below } else { below }
  let left-inset = if inset == none { layout.inset } else { inset }
  block(above: top-space, below: bottom-space, inset: (left: left-inset, right: 20pt))[
    #text(size: layout.label-size, weight: "bold", fill: style.accent)[Worked example]
    #v(layout.label-gap)
    #set text(size: layout.body-size)
    #set par(spacing: 0pt)
    #body
  ]
}

/// A short connection from the current topic to the reader's analysis.
#let analysis-note(body, title: [In your analysis]) = context {
  let style = book-style.get()
  block(breakable: false, above: 8pt, below: 8pt)[
    #text(weight: "bold", fill: style.accent)[#title]
    #parbreak()
    #body
  ]
}

/// A square writing grid whose cell size and height can be adjusted.
///
/// The grid fills the available text width. Its lines remain vector shapes.
#let answer-grid(height: 25mm, cell: 5mm, color: none, width: none) = context {
  let style = book-style.get()
  let line-color = if color == none { style.grid } else { color }
  let line-width = if width == none { style.grid-width } else { width }
  block(width: 100%, height: height, breakable: false)[
    #layout(size => {
      let grid-width = size.width - 0.4pt
      let grid-height = height - 0.4pt
      let cols = calc.floor(grid-width / cell)
      let rows = calc.floor(grid-height / cell)
      let stroke = (paint: line-color, thickness: line-width)
      for x in range(0, cols + 1) {
        place(line(start: (x * cell, 0pt), end: (x * cell, grid-height), stroke: stroke))
      }
      place(line(start: (grid-width, 0pt), end: (grid-width, grid-height), stroke: stroke))
      for y in range(0, rows + 1) {
        place(line(start: (0pt, y * cell), end: (grid-width, y * cell), stroke: stroke))
      }
      place(line(start: (0pt, grid-height), end: (grid-width, grid-height), stroke: stroke))
    })
  ]
}

/// A numbered exercise followed by a writing grid.
///
/// Exercise numbers restart at each numbered level-one heading. Attach a Typst
/// label immediately after the call when a solution needs to link back to it.
///
/// - body (content): the exercise prompt
/// - kind (str): label such as "Core" or "Optional challenge"
/// - grid (length): answer-space height; defaults to 20 mm for core exercises
#let exercise(body, kind: "Core", grid: none) = {
  let height = if grid != none { grid } else if kind == "Core" { 20mm } else { 25mm }
  [
    #counter("satz-exercise").step()
    #context {
      let style = book-style.get()
      let layout = style.exercise
      let chapter = counter(heading).display(style.numbering)
      let number = counter("satz-exercise").get().first()
      block(breakable: false, below: layout.group-gap)[
        #set par(spacing: 0pt)
        #text(weight: "bold", fill: style.accent)[
          Exercise #chapter.#number (#kind).
        ]
        #h(0.5em)
        #body
        #v(layout.grid-gap)
        #answer-grid(height: height)
      ]
    }
  ]
}
