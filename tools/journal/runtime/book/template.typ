// Book entry point — a KOMA-inspired authoring path over satz's shared class.

#import "../class.typ": document-class
#import "../defaults.typ": defaults, merge
#import "components.typ": book-style

/// A configurable book with a title page, front matter, contents, and main matter.
///
/// Common choices are direct arguments; less common layout details stay available
/// through `config`. Put preliminary pages before `book-contents()`, then place
/// numbered chapters inside `book-mainmatter[...]`.
///
/// ```example
/// #import "@local/satz:0.1.1": book, book-contents, book-mainmatter
/// #show: book.with(
///   title: [The Maths Behind Your Analysis],
///   author: [Your Name],
///   accent: teal,
///   font: "Georgia",
/// )
///
/// = How to use this book
/// ...
/// #book-contents()
/// #book-mainmatter[
///   = Chapter one
///   ...
/// ]
/// ```
///
/// - title (content): title shown on the cover
/// - subtitle (content, none): optional subtitle
/// - author (content, none): author or recipient line
/// - eyebrow (content, none): small line above the title
/// - note (content, none): small text near the bottom of the cover
/// - date (content, none): date near the bottom of the cover
/// - accent (color): heading and component accent
/// - ink (color): cover title and chapter-heading color
/// - font (str): body text family
/// - math-font (str): equation font family
/// - font-size (length): main text size
/// - leading (length): extra line spacing
/// - paragraph-spacing (length): space between paragraphs
/// - paper (str): page format
/// - margin (dictionary): page margins
/// - binding (alignment, none): inside edge for two-sided pages
/// - binding-correction (length): extra room at the binding edge
/// - config (dictionary): advanced shared satz overrides
/// - config.book.contents: contents title position, size, entry size, and row spacing
/// - config.book.worked-example: default spacing, inset, and type sizes
/// - config.book.exercise: spacing between each prompt and its grid, and between exercise groups
/// - config.book.footer-dy: vertical position of the page number
/// - body (content): preliminary pages and book structure
#let book(
  body,
  title: none,
  subtitle: none,
  author: none,
  eyebrow: none,
  note: none,
  date: none,
  accent: rgb("#23616B"),
  ink: rgb("#24313B"),
  paper: "a4",
  margin: (left: 27mm, right: 25mm, top: 25mm, bottom: 27mm),
  math-font: "New Computer Modern Math",
  font: "Libertinus Serif",
  font-size: 11pt,
  leading: 0.74em,
  paragraph-spacing: 14pt,
  binding: left,
  binding-correction: 5mm,
  config: (:),
) = {
  // Keep links legible while deriving their shade from the selected accent.
  let link-accent = color.mix((accent, 60%), (black, 40%), space: rgb)
  let book-defaults = merge(defaults, (
    page: (
      paper: paper,
      margin: margin,
      binding: binding,
      binding-correction: binding-correction,
      headers: false,
    ),
    typography: (
      font: font,
      size: font-size,
      leading: leading,
      paragraph-spacing: paragraph-spacing,
      first-line-indent: 0pt,
      hyphenate: true,
      justify: true,
    ),
    page-footer: (weight: "regular"),
    headings: (
      numbering: "1",
      h1-size: 18pt,
      h1-number-size: 25pt,
      h1-below: 33pt,
      h2-above: 22pt,
      h2-size: 12pt,
      h2-below: 13pt,
      h3-size: 11pt,
      h3-below: 9pt,
    ),
    colors: (
      bg-paper: white,
      brand-primary: accent,
      brand-accent: accent,
      text-main: black,
      text-muted: luma(110),
    ),
    links: (color: link-accent, url-color: link-accent),
    book: (
      ink: ink,
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
      cover-top: 28mm,
      cover-eyebrow-size: 14.3pt,
      cover-eyebrow-below: 14mm,
      cover-title-size: 25pt,
      cover-title-leading: 8pt,
      cover-title-below: 13.5mm,
      cover-subtitle-size: 14.3pt,
      cover-subtitle-leading: 6.5pt,
      cover-subtitle-below: 21.6mm,
      cover-rule-width: 0.8pt,
      cover-author-size: 12pt,
      cover-author-below: 3pt,
      cover-note-size: 10pt,
      cover-note-below: 11.2mm,
      cover-date-dy: 6.5pt,
    ),
    toc: (depth: 0),
  ))
  let c = merge(book-defaults, config)

  document-class(kind: "book", config: c, [
    #book-style.update((
      accent: c.colors.brand-primary,
      ink: c.book.ink,
      contents: c.book.contents,
      worked-example: c.book.worked-example,
      exercise: c.book.exercise,
      footer-dy: c.book.footer-dy,
      footer: c.colors.text-main,
      grid: rgb("#D2D2D2"),
      grid-width: 0.2pt,
      footer-size: c.page-footer.size,
      footer-weight: c.page-footer.weight,
      numbering: c.headings.numbering,
    ))
    #set page(numbering: none)
    #set heading(numbering: none)
    #show math.equation: set text(font: math-font)
    #show heading.where(level: 1): it => context {
      let style = book-style.get()
      let number = if it.numbering == none { none } else { counter(heading).display(it.numbering) }
      [
        #pagebreak(weak: true)
        #v(19pt)
        #if number != none { counter("satz-exercise").update(0) }
        #block(above: 0pt, below: c.headings.h1-below)[
          #if number != none {
            place(top, dx: -48pt)[
              #text(size: c.headings.h1-number-size, fill: style.accent, weight: "bold")[#number]
            ]
          }
          #move(dy: 5.5pt)[
            #text(size: c.headings.h1-size, fill: style.ink, weight: "bold")[#it.body]
          ]
        ]
      ]
    }
    #show heading.where(level: 2): set block(above: c.headings.h2-above, below: c.headings.h2-below)
    #show heading.where(level: 2): set text(size: c.headings.h2-size, fill: c.colors.brand-primary, weight: "bold")
    #show heading.where(level: 2): set heading(numbering: none)
    #show heading.where(level: 3): set text(size: c.headings.h3-size, fill: c.colors.text-main, weight: "bold")
    #show heading.where(level: 4): set text(size: c.headings.h4-size, fill: c.colors.text-main, weight: "bold")
    #set page(footer: none)
    #block(width: 100%, height: 100%)[
      #v(c.book.cover-top)
      #if eyebrow != none { block(below: c.book.cover-eyebrow-below, text(size: c.book.cover-eyebrow-size, fill: accent)[#eyebrow]) }
      #block(below: c.book.cover-title-below)[
        #set par(leading: c.book.cover-title-leading)
        #text(size: c.book.cover-title-size, weight: "bold", fill: c.book.ink)[#title]
      ]
      #if subtitle != none {
        block(below: c.book.cover-subtitle-below)[
          #set par(leading: c.book.cover-subtitle-leading)
          #text(size: c.book.cover-subtitle-size)[#subtitle]
        ]
      }
      #line(length: 100%, stroke: c.book.cover-rule-width)
      #v(6mm)
      #if author != none {
        block(below: c.book.cover-author-below)[
          #set par(leading: 0.5em)
          #text(size: c.book.cover-author-size)[#author]
        ]
      }
      #v(1fr)
      #if note != none { block(below: c.book.cover-note-below, text(size: c.book.cover-note-size)[#note]) }
      #if date != none { move(dy: c.book.cover-date-dy, text(size: 10pt)[#date]) }
    ]
    #pagebreak(to: "odd")
    #counter(page).update(1)
    #set page(numbering: "i")
    #set page(footer: context {
      let n = counter(page).get().first()
      if n > 0 {
        let folio = text(size: c.page-footer.size, weight: c.page-footer.weight, fill: c.colors.text-main, counter(page).display())
        let positioned = move(dy: c.book.footer-dy, folio)
        if calc.rem(n, 2) == 0 { align(left, positioned) } else { align(right, positioned) }
      }
    })
    #body
  ])
}

/// Insert a styled contents page at the current location.
///
/// The outline is native Typst, so its links and page numbers update on compile.
///
/// - title (content): contents heading
/// - depth (int): heading depth to include; 1 lists chapters only
#let book-contents(title: [Contents], depth: 1) = context {
  let style = book-style.get()
  let toc = style.contents
  [
    #pagebreak()
    #v(toc.title-before)
    #block(below: toc.title-after)[
      #text(size: toc.title-size, weight: "bold", fill: style.ink)[#title]
    ]
    #set text(size: toc.entry-size)
    #set par(leading: 0.45em, spacing: 0pt)
    #show outline.entry: it => context {
      block(above: toc.entry-spacing)[
        #link(it.element.location())[
          #it.indented(it.prefix(), [#it.body() #h(1fr) #it.page()])
        ]
      ]
    }
    #show outline.entry.where(level: 1): set text(fill: style.accent)
    #outline(title: none, depth: depth)
  ]
}

/// Start numbered chapters on a recto page with Arabic folios beginning at 1.
///
/// - numbering (str, none): optional chapter numbering pattern; defaults to `"1"`
#let book-mainmatter(body, numbering: none) = context {
  let style = book-style.get()
  let number-format = if numbering == none { style.numbering } else { numbering }
  [
    #book-style.update((
      accent: style.accent,
      ink: style.ink,
      contents: style.contents,
      worked-example: style.worked-example,
      exercise: style.exercise,
      footer-dy: style.footer-dy,
      footer: style.footer,
      grid: style.grid,
      grid-width: style.grid-width,
      footer-size: style.footer-size,
      footer-weight: style.footer-weight,
      numbering: number-format,
    ))
    #set heading(numbering: number-format)
    #show heading.where(level: 2): set heading(numbering: none)
    #set page(footer: none)
    #pagebreak(to: "odd")
    #counter(page).update(1)
    #counter(heading).update(0)
    #set page(numbering: "1")
    #set page(footer: context {
      let n = counter(page).get().first()
      if n > 0 {
        let d = counter(page).display()
        let folio = text(size: style.footer-size, weight: style.footer-weight, fill: style.footer, d)
        let positioned = move(dy: style.footer-dy, folio)
        if calc.rem(n, 2) == 0 { align(left, positioned) } else { align(right, positioned) }
      }
    })
    #body
  ]
}

/// Start lettered appendices while keeping Arabic page numbers.
#let book-appendix(body) = context {
  let style = book-style.get()
  [
    #book-style.update((
      accent: style.accent,
      ink: style.ink,
      contents: style.contents,
      worked-example: style.worked-example,
      exercise: style.exercise,
      footer-dy: style.footer-dy,
      footer: style.footer,
      grid: style.grid,
      grid-width: style.grid-width,
      footer-size: style.footer-size,
      footer-weight: style.footer-weight,
      numbering: "A",
    ))
    #set heading(numbering: "A")
    #set page(numbering: "1")
    #counter(heading).update(0)
    #body
  ]
}

/// Add unnumbered back-matter chapters after appendices or solutions.
#let book-backmatter(body) = {
  [
    #set heading(numbering: none)
    #set page(numbering: "1")
    #body
  ]
}
