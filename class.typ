// Unified document class — kind: "journal" | "report" | "thesis" | "letter"

#import "defaults.typ": defaults, merge

/// The core satz document class — sets up page, typography, headings, and more.
///
/// All templates (report, journal-entry, etc.) delegate to this function.
/// Direct use is possible for custom document types:
///
/// ```example
/// #show: personal.with(kind: "thesis", config: (page: (paper: "a5")))
/// = My Thesis
/// ```
///
/// - kind (str): Document kind — "journal", "report", "thesis", or "letter"
/// - config (dictionary): Partial overrides for satz defaults
/// - header (none, content): Custom page header
/// - footer (none, content): Custom page footer
/// - body (content): Document body
#let personal(
  kind: "report",
  config: (:),
  header: none,
  footer: none,
  body,
) = {
  let c = merge(defaults, config)

  // --- Build page arguments ---
  let page-args = (
    paper: c.page.paper,
    margin: c.page.margin,
    fill: c.colors.bg-paper,
  )
  if header != none {
    page-args.insert("header", header)
  }
  if footer != none {
    page-args.insert("footer", footer)
  }
  if kind == "report" or kind == "thesis" {
    page-args.insert("numbering", (current, total) => if current > 1 { str(current - 1) })
  }
  set page(..page-args)

  // --- Text ---
  set text(
    font: c.typography.font,
    size: c.typography.size,
    fill: c.colors.text-main,
    hyphenate: c.typography.hyphenate,
    lang: "en",
  )

  // --- Paragraph ---
  set par(
    justify: c.typography.justify,
    leading: c.typography.leading,
  )

  // --- List spacing ---
  set list(spacing: c.decorative.list-spacing)

  // --- Heading numbering (not for journal) ---
  if kind != "journal" {
    set heading(numbering: c.headings.numbering)
  }

  // --- Heading show rules ---
  show heading.where(level: 1): it => block(width: 100%, below: c.headings.h1-below)[
    #set text(fill: c.colors.brand-primary, weight: "bold", size: c.headings.h1-size)
    #v(0.5em)
    #if kind == "journal" {
      smallcaps(it.body)
    } else {
      it
    }
  ]
  show heading.where(level: 2): it => block(below: c.headings.h2-below)[
    #set text(fill: c.colors.brand-primary, weight: "bold", size: c.headings.h2-size)
    #it
  ]
  show heading.where(level: 3): it => block(below: c.headings.h3-below)[
    #set text(fill: c.colors.brand-primary, weight: "bold", size: c.headings.h3-size)
    #it
  ]
  show heading.where(level: 4): it => block(below: c.headings.h4-below)[
    #set text(fill: c.colors.brand-primary, weight: "bold", size: c.headings.h4-size)
    #it
  ]

  // --- Links (not for journal) ---
  if kind != "journal" {
    show link: it => text(fill: c.links.color, it)
  }

  // --- Table styling (booktabs-style) ---
  set table(
    stroke: none,
    inset: (x: 8pt, y: 4pt),
  )

  // --- Bibliography (not for journal) ---
  if kind != "journal" {
    set bibliography(style: c.bibliography.style)
  }

  body
}
