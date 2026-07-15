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
  let numbering = if kind == "report" or kind == "thesis" {
    (n) => { if n > 1 { str(n - 1) } else { none } }
  } else {
    none
  }
  let page-args = (
    paper: c.page.paper,
    margin: c.page.margin,
    fill: c.colors.bg-paper,
    header: if header != none { header } else { none },
    footer: if footer != none { footer } else { none },
    numbering: numbering,
  )
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

  // --- Heading numbering (journal uses none) ---
  set heading(numbering: if kind == "journal" { none } else { c.headings.numbering })

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
  show link: it => if kind != "journal" { text(fill: c.links.color, it) } else { it }

  // --- Table styling (booktabs-style) ---
  set table(
    stroke: none,
    inset: (x: 8pt, y: 4pt),
  )

  // --- Bibliography ---
  set bibliography(style: c.bibliography.style)

  // --- Table of Contents (report/thesis) ---
  if kind != "journal" and c.toc.depth != 0 {
    outline(
      title: c.toc.title,
      depth: c.toc.depth,
      indent: c.toc.indent,
    )
    v(c.toc.below)
  }

  body
}
