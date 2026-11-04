// Book entry point — a KOMA-inspired authoring path over satz's shared class.

#import "../class.typ": document-class
#import "../defaults.typ": defaults, merge
#import "../themes.typ": theme-config
#import "components.typ": book-style

#let book-running-heading = state("satz-book-running-heading", (
  number: none,
  chapter: [],
))

/// A configurable book with a title page, front matter, contents, and main matter.
///
/// Common choices are direct arguments; less common layout details stay available
/// through `config`. Put preliminary pages before `book-contents()`, then place
/// numbered chapters inside `book-mainmatter[...]`.
///
/// ```example
/// #import "@local/satz:0.2.0": book, book-contents, book-mainmatter
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
/// - title (content, none): title shown on the typographic cover; required
///   unless `cover-image` supplies a complete cover
/// - cover-image (str, none): full-page image replacing the typographic cover
/// - subtitle (content, none): optional subtitle
/// - author (content, none): author or recipient line
/// - eyebrow (content, none): small line above the title
/// - note (content, none): small text near the bottom of the cover
/// - date (content, none): date near the bottom of the cover
/// - accent (color, none): heading and component accent; defaults to `#23616B`
/// - ink (color, none): cover title and chapter-heading color; defaults to `#24313B`
/// - theme (str, none): `neutral` (default), `slate`, `soft-jade`, `soft-slate`,
///   `warm-editorial`, `plum`, or `soft-rose`; direct arguments and `config` win
/// - font (str, none): body family; `none` keeps `"Libertinus Serif"`
/// - math-font (str, none): equation family; `none` keeps `"New Computer Modern Math"`
/// - font-size (length, none): body size; `none` keeps 11pt
/// - leading (length, none): line-box gap; `none` keeps 0.74em
/// - paragraph-spacing (length, none): paragraph gap; `none` keeps 14pt
/// - paper (str, none): paper name; `none` keeps `"a4"`
/// - margin (dictionary, none): page margins; `none` keeps left 27mm, right
///   25mm, top 25mm, bottom 27mm
/// - binding (auto, alignment, none): inside edge for two-sided pages. `auto`
///   keeps the book's left binding; `none` disables two-sided layout
/// - binding-correction (length): extra room at the binding edge; defaults to 5mm
/// - running-headers (str): `"bottom"` (default), `"top"`, or `"none"`.
///   `config.book.running-headers` takes precedence over this direct argument
/// - config (dictionary): nested overrides, deep-merged after the book
///   defaults, selected palette, and direct arguments. Explicit config values
///   win. Known shared groups validate their keys; custom top-level extension
///   groups are retained. The book accepts these shared fields:
///   - `page.paper` (paper name/custom size; `"a4"`), `margin` (edge lengths;
///     book default left 27mm, right 25mm, top 25mm, bottom 27mm), `binding`
///     (`left` by default, or `right`/`none`), `binding-correction` (5mm),
///     `headers` (`false`), `columns` (1), `column-gutter` (5mm).
///   - `typography.font` (`"Libertinus Serif"`), `math-font`
///     (`"New Computer Modern Math"`), `mono-font` (`auto`), `size` (11pt),
///     `line-spacing` (`none`), `leading` (0.74em), `paragraph-spacing` (14pt),
///     `first-line-indent` (`false`), `hyphenate` (`true`), `justify` (`true`).
///     Font names, sizes, lengths, and boolean values are passed to Typst.
///   - `typography.list-spacing` (non-negative number; `0.5`): additional gap
///     between list items as a fraction of the calculated body baseline
///     distance. It follows `typography.line-spacing` when set, or font
///     metrics and `typography.leading` otherwise. Use `0` for no extra gap.
///   - `headings.numbering` (`"1"`), `hyphenate` (`false`), `h1-pagebreak`
///     (`false`), `spacing` (`"koma"` or `"native"`; `"koma"`), and levels
///     1–4 `hN-size`, `hN-above`, `hN-below` (defaults 18pt/12pt/11pt/11pt,
///     `auto` above, and book-specific 33pt/auto/auto/auto below), plus
///     `h1-number-size` (25pt).
///   - `journal`: `header-below` (1.5em), `running-gutter` (1em),
///     `running-leading` (0.35em), `running-header-size` (9pt), `date-size`
///     (10pt), and `keywords-size` (9pt); journal-only fields, unused by book.
///   - `decorative`: `header-size` (9pt), `footer-size` (10pt), `date-size`
///     (10pt), and `keywords-size` (9pt).
///   - `page-footer`: `format` (`"1"`), `size` (10pt), `weight` (`"regular"`).
///   - `line-numbers`: `enabled` (`false`), `format` (`"1"`),
///     `scope` (`"document"` or `"page"`; `"document"`), `size` (8pt),
///     `color` (`#64748B`), `clearance` (`auto` or length; `auto`).
///   - `links.color`, `links.url-color` (colors; book defaults both to a mix of
///     the accent and black).
///   - `tables`: `stroke` (0.5pt), `inset` ((x: 8pt, y: 4pt)), `font-size`
///     (10pt), `caption-position` (`top` or `bottom`; `top`), `caption-gap` (6pt).
///   - `callouts`: `inset` (9pt), `radius` (3pt), `stroke` (0.8pt),
///     `title-below` (1em), `paragraph-spacing` (1em), `list-spacing` (1.2em).
///   - `captions`: `size` (10pt), `weight` (`"regular"`), `alignment` (`center`),
///     `label-weight` (`"regular"`).
///   - `toc`, `lof`, `lot`: `depth` (book toc defaults to 0; other depths
///     `none`), `title` (default English title), `indent` (`auto`),
///     `entry-size` (10pt), `leading` (0.65em), `entry-above` (0.65em for toc;
///     0.85em for lof/lot), `title-below` (1.5em), `below` (2em). `toc` also
///     has `main-entry-above` (1.25em); `lof` and `lot` have `compact` (`false`).
///   - `bibliography.style` (CSL name; `"apa"`).
///   - `colors.bg-paper`, `bg-subtle`, `brand-primary`, `brand-accent`,
///     `text-main`, `text-muted` (colors; book defaults white paper, teal
///     `#23616B` accent, `#24313B` ink, and muted `luma(110)`).
///   Book-specific `book.*` fields are independently configurable:
///   `ink` (`#24313B`), `running-headers` (`"bottom"`; also `"top"` or
///   `"none"`), `footer-dy` (5pt), `cover-top` (28mm), `cover-eyebrow-size`
///   (14.3pt), `cover-eyebrow-below` (14mm), `cover-title-size` (25pt),
///   `cover-title-leading` (8pt), `cover-title-below` (13.5mm),
///   `cover-subtitle-size` (14.3pt), `cover-subtitle-leading` (6.5pt),
///   `cover-subtitle-below` (21.6mm), `cover-rule-width` (0.8pt),
///   `cover-author-size` (12pt), `cover-author-below` (3pt), `cover-note-size`
///   (10pt), `cover-note-below` (11.2mm), and `cover-date-dy` (6.5pt).
///   `book.contents` fields are `title-before` (24.5pt), `title-after` (26pt),
///   `title-size` (17pt), `entry-size` (10pt), `entry-spacing` (11.8pt).
///   `book.worked-example` fields are `inset` (27pt), `above` (26pt),
///   `below` (27pt), `label-gap` (0pt), `label-size` (9pt), `body-size` (9pt).
///   `book.exercise.grid-gap` (11pt) and `group-gap` (20pt) control exercise
///   layout. These values affect the book cover, running matter, contents,
///   worked examples, and exercises respectively.
/// - body (content): preliminary pages and book structure
#let book(
  body,
  title: none,
  cover-image: none,
  subtitle: none,
  author: none,
  eyebrow: none,
  note: none,
  date: none,
  accent: none,
  ink: none,
  theme: "neutral",
  paper: none,
  margin: none,
  math-font: none,
  font: none,
  font-size: none,
  leading: none,
  paragraph-spacing: none,
  binding: auto,
  binding-correction: none,
  running-headers: "bottom",
  config: (:),
) = {
  assert(title != none or cover-image != none,
    message: "Book requires either `title` or `cover-image`.")
  assert(cover-image == none or type(cover-image) == str,
    message: "Book `cover-image` must be a file path string or none.")
  let default-accent = rgb("#23616B")
  let default-link = color.mix((default-accent, 60%), (black, 40%), space: rgb)
  let book-defaults = merge(defaults, (
    page: (
      paper: "a4",
      margin: (left: 27mm, right: 25mm, top: 25mm, bottom: 27mm),
      binding: left,
      binding-correction: 5mm,
      headers: false,
    ),
    typography: (
      font: "Libertinus Serif",
      math-font: "New Computer Modern Math",
      size: 11pt,
      leading: 0.74em,
      paragraph-spacing: 14pt,
      first-line-indent: false,
      hyphenate: true,
      justify: true,
    ),
    page-footer: (weight: "regular"),
    headings: (
      numbering: "1",
      h1-size: 18pt,
      h1-number-size: 25pt,
      h1-below: 33pt,
      h2-size: 12pt,
      h3-size: 11pt,
    ),
    colors: (
      bg-paper: white,
      brand-primary: default-accent,
      brand-accent: default-accent,
      text-main: black,
      text-muted: luma(110),
    ),
    links: (color: default-link, url-color: default-link),
    book: (
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
      running-headers: running-headers,
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
  let themed-defaults = merge(book-defaults, theme-config(theme))
  let themed-defaults = merge(themed-defaults, (book: (ink: themed-defaults.colors.text-main)))
  let accent-link = if accent != none { color.mix((accent, 60%), (black, 40%), space: rgb) } else { none }
  let direct-config = (
    page: (:
      ..(if paper != none { (paper: paper) } else { (:) }),
      ..(if margin != none { (margin: margin) } else { (:) }),
      ..(if binding != auto { (binding: binding) } else { (:) }),
      ..(if binding-correction != none { (binding-correction: binding-correction) } else { (:) }),
    ),
    typography: (:
      ..(if font != none { (font: font) } else { (:) }),
      ..(if font-size != none { (size: font-size) } else { (:) }),
      ..(if leading != none { (leading: leading) } else { (:) }),
      ..(if paragraph-spacing != none { (paragraph-spacing: paragraph-spacing) } else { (:) }),
      ..(if math-font != none { (math-font: math-font) } else { (:) }),
    ),
    colors: (:
      ..(if accent != none { (brand-primary: accent, brand-accent: accent) } else { (:) }),
    ),
    links: (:
      ..(if accent-link != none { (color: accent-link, url-color: accent-link) } else { (:) }),
    ),
    book: (:
      ..(if ink != none { (ink: ink) } else { (:) }),
    ),
  )
  let c = merge(merge(themed-defaults, direct-config), config)
  assert(
    c.book.running-headers in ("bottom", "top", "none"),
    message: "book running-headers must be \"bottom\", \"top\", or \"none\".",
  )
  let class-config = merge(c, (page: (headers: c.book.running-headers == "top")))

  document-class(kind: "book", config: class-config, [
    #book-style.update((
      accent: c.colors.brand-primary,
      ink: c.book.ink,
      contents: c.book.contents,
      worked-example: c.book.worked-example,
      exercise: c.book.exercise,
      running-headers: c.book.running-headers,
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
    #show math.equation: set text(font: c.typography.math-font)
    #show heading.where(level: 1): it => context {
      let style = book-style.get()
      let number = if it.numbering == none { none } else { counter(heading).display(it.numbering) }
      book-running-heading.update((number: number, chapter: it.body))
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
    // Subsection gaps come from the shared KOMA spacing policy. Keep the
    // chapter opener custom, but don't give level two a competing block rule.
    #show heading.where(level: 2): set text(size: c.headings.h2-size, fill: c.colors.brand-primary, weight: "bold")
    #show heading.where(level: 2): set heading(numbering: none)
    #show heading.where(level: 3): set text(size: c.headings.h3-size, fill: c.colors.text-main, weight: "bold")
    #show heading.where(level: 4): set text(size: c.headings.h4-size, fill: c.colors.text-main, weight: "bold")
    #if cover-image != none {
      {
        set page(margin: 0pt, footer: none)
        image(cover-image, width: 100%, height: 100%, fit: "cover")
      }
    } else {
      set page(footer: none)
      block(width: 100%, height: 100%)[
        #v(c.book.cover-top)
        #if eyebrow != none { block(below: c.book.cover-eyebrow-below, text(size: c.book.cover-eyebrow-size, fill: c.colors.brand-primary)[#eyebrow]) }
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
    }
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

// Shared footer for Arabic main matter, appendices, and back matter.
/// Draw the running footer used on book main-matter, appendix, and back-matter pages.
///
/// The footer accepts the resolved internal style record created by `book()`.
/// It prints an Arabic page number on chapter-opening pages. Other pages show
/// the configured running chapter label and page number when
/// `book.running-headers` is `"bottom"`, or only the page number for `"top"`
/// and `"none"`. Even and odd pages place these items on opposite outer edges.
///
/// - style (dictionary): resolved book style with `footer-size`,
///   `footer-weight`, `footer` color, `footer-dy`, `running-headers`, and the
///   current chapter/number state. This is an internal helper; configure these
///   values through `book()` rather than calling this function directly.
/// -> content: positioned running footer or page number
#let book-page-footer(style) = context {
  let n = counter(page).get().first()
  if n > 0 {
    let d = counter(page).display()
    let folio = text(size: style.footer-size, weight: style.footer-weight, fill: style.footer, d)
    let opening = query(heading.where(level: 1)).any(h => h.location().page() == here().page())
    if style.running-headers == "bottom" and not opening {
      let is-even = calc.rem(n, 2) == 0
      let current = book-running-heading.get()
      let title = if is-even {
        if current.number == none { smallcaps(current.chapter) } else { [CHAPTER #current.number] }
      } else {
        smallcaps(current.chapter)
      }
      let running-line = if is-even {
        grid(columns: (1fr, 1fr),
          align(left)[#text(size: 8pt, fill: rgb("#666666"))[#d #h(0.8em) #title]],
          [],
        )
      } else {
        grid(columns: (1fr, 1fr),
          [],
          align(right)[#text(size: 8pt, fill: rgb("#666666"))[#title #h(0.8em) #d]],
        )
      }
      move(dy: style.footer-dy, running-line)
    } else {
      let positioned = move(dy: style.footer-dy, folio)
      if calc.rem(n, 2) == 0 { align(left, positioned) } else { align(right, positioned) }
    }
  }
}

/// Insert a styled contents page at the current location.
///
/// This inserts a page break, prints a book-styled title, then renders Typst's
/// native outline. Links and page numbers update when the document is compiled.
/// By default only level-one chapter headings appear. Nested heading levels can
/// be included by increasing `depth`. The appearance follows the active book
/// style. Its title position and entry typography/spacing are set by
/// `book.contents.title-before` (24.5pt), `title-after` (26pt),
/// `title-size` (17pt), `entry-size` (10pt), and `entry-spacing` (11.8pt).
/// Each field is a length and directly controls the indicated gap or type size;
/// `book()` config values override these defaults.
///
/// ```typst
/// #book-contents(title: [Contents], depth: 2)
/// #book-mainmatter[
///   = First chapter
///   == First section
/// ]
/// ```
///
/// - title (content, none): contents heading; defaults to `[Contents]`. `none`
///   hides the words but retains the configured title spacing.
/// - depth (int): heading depth to include; defaults to 1 (chapters only).
///   Must be a non-negative integer. `0` renders an empty outline below the
///   heading; it does not suppress the contents page.
/// -> content: a page break, styled title, and linked outline
#let book-contents(title: [Contents], depth: 1) = context {
  assert(type(depth) == int and depth >= 0, message: "book-contents depth must be a nonnegative integer.")
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

/// Begin the book's numbered main matter on a right-hand page.
///
/// This inserts a page break to the next recto page, resets the displayed page
/// number to Arabic `1`, resets the heading counter, and enables the book footer.
/// The main matter uses `headings.numbering` (the book default is `"1"`) unless
/// `numbering` supplies a Typst heading-numbering pattern override. Level-two
/// headings remain unnumbered.
/// Place front matter and `book-contents()` before this call; place appendices
/// or back matter after the main matter.
///
/// ```typst
/// #book-contents()
/// #book-mainmatter[
///   = First chapter
///   Main text.
/// ]
/// ```
///
/// - body (content): chapters in the numbered main matter
/// - numbering (str, none): optional Typst heading-numbering pattern; `none`
///   uses the document's `headings.numbering` (the book default is `"1"`)
/// -> content: page and heading setup followed by `body`
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
      running-headers: style.running-headers,
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
    #set page(footer: book-page-footer(style))
    #body
  ]
}

/// Start lettered appendices while keeping Arabic page numbers.
///
/// Resets the heading counter and switches level-one heading numbering to
/// uppercase letters (`A`, `B`, …). Page numbering remains Arabic and continues
/// from the preceding content. Figure, table, and equation counters are not
/// reset or lettered automatically; call `chapter-numbering(appendix: true)`
/// inside the appendix when those numbers should include appendix letters.
/// Place appendices after `book-mainmatter`; use `book-backmatter` for any later
/// unnumbered sections.
///
/// ```typst
/// #book-appendix[
///   = Supplementary methods
///   Appendix content.
/// ]
/// ```
///
/// - body (content): one or more appendix chapters, beginning at heading level 1
/// -> content: appendix heading and page-number setup followed by `body`
#let book-appendix(body) = context {
  let style = book-style.get()
  [
    #book-style.update((
      accent: style.accent,
      ink: style.ink,
      contents: style.contents,
      worked-example: style.worked-example,
      exercise: style.exercise,
      running-headers: style.running-headers,
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
    #set page(footer: book-page-footer(style))
    #counter(heading).update(0)
    #body
  ]
}

/// Begin unnumbered back matter after appendices, solutions, or references.
///
/// Inserts a weak page break so existing page flow is preserved when possible,
/// disables numbering on headings that follow, and keeps Arabic page numbers
/// with the book footer. It does not reset the page counter or add entries to
/// the contents. Use this wrapper for material such as acknowledgments, notes,
/// or a bibliography that should follow the numbered chapters.
///
/// ```typst
/// #book-backmatter[
///   = Acknowledgments
///   Thank you to everyone who helped.
/// ]
/// ```
///
/// - body (content): unnumbered back-matter content
/// -> content: page and heading setup followed by `body`
#let book-backmatter(body) = context {
  let style = book-style.get()
  [
    #pagebreak(weak: true)
    #set heading(numbering: none)
    #set page(numbering: "1")
    #set page(footer: book-page-footer(style))
    #body
  ]
}

/// Start a fresh, two-column index with hanging entries.
///
/// Use one `book-index` call after the references and supply index entries as
/// paragraphs. The page counter continues from the preceding back-matter page.
///
/// - body (content): index entries as paragraphs
/// - title (content): index heading; defaults to `[Index]`
/// - column-count (int): number of index columns; defaults to 2
/// - gutter (length): space between columns; defaults to 18pt
/// - indent (length): continuation-line indent for each entry; defaults to 10pt
/// - spacing (length): space between index entries; also sets paragraph
///   spacing inside each hanging-indent entry; defaults to 3pt
#let book-index(
  body,
  title: [Index],
  column-count: 2,
  gutter: 18pt,
  indent: 10pt,
  spacing: 3pt,
) = context {
  assert(type(column-count) == int and column-count >= 1, message: "book-index column-count must be a positive integer.")
  assert(indent >= 0pt, message: "book-index indent must be nonnegative.")
  assert(spacing >= 0pt, message: "book-index spacing must be nonnegative.")
  [
    #set page(numbering: "1")
    #set page(columns: column-count)
    #set columns(gutter: gutter)
    #set heading(numbering: none)
    #set page(footer: book-page-footer(book-style.get()))
    #pagebreak(weak: true)
    #heading(level: 1, numbering: none)[#title]
    #block(inset: (left: indent))[
      #set par(first-line-indent: -indent, spacing: spacing)
      #body
    ]
  ]
}
