// Shared document class for report, article, book, journal, and proposal templates.

#import "defaults.typ": defaults, merge, validate-config
#import "heading-layout.typ": koma-headings
#import "@preview/hydra:0.6.3": hydra, selectors

/// Show a long caption under the figure, a short one in the List of Figures.
///
/// Typst doesn't do short captions — LoF always shows the full text.
/// This works around it: LoF gets the short text,
/// the long one hides as `<satz-long>` metadata.
/// `document-class` puts the long one back when it draws the figure.
/// No `short-caption`? It just acts like a normal `figure`.
///
/// - body (content): what you show (image, rect ...)
/// - caption (content): the long text under the figure
/// - short-caption (content): the short title for the LoF
/// - ..args: pass to `figure` (e.g. `placement`, `kind`)
///
/// ```example
/// #satz-figure(
///   image("plot.png"),
///   caption: [Full description spanning several lines.],
///   short-caption: [Empirical verification of Picard ICA],
/// ) <fig:results>
/// ```
#let satz-figure(body, caption: none, short-caption: none, ..args) = {
  if short-caption != none {
    figure(
      [#metadata(caption) <satz-long> #body],
      caption: short-caption,
      ..args,
    )
  } else {
    figure(body, caption: caption, ..args)
  }
}

/// The heart of satz — page, fonts, headings, the lot.
///
/// Named templates use this shared page and typography foundation.
/// Call it directly when you want to design a custom document structure.
///
/// ```example
/// #show: document-class.with(kind: "thesis", config: (page: (paper: "a5")))
/// = My Thesis
/// ```
///
/// - kind (str): document behavior — commonly "article", "book", "journal", "proposal", "report", or "thesis"
/// - config (dictionary): tweak the defaults
/// - header (none, content): your own header, if you want one
/// - footer (none, content): your own footer, if you want one
/// - body (content): your content
#let document-class(
  kind: "report",
  config: (:),
  header: none,
  footer: none,
  body,
) = {
  let config = validate-config(config)
  let c = merge(defaults, config)

  // --- Build page arguments ---
  let numbering = if kind == "report" or kind == "thesis" {
    (n) => { if n > 1 { str(n - 1) } else { none } }
  } else {
    none
  }
  let two-sided = "binding" in c.page and c.page.binding != none
  let binding-correction = c.page.at("binding-correction", default: 0pt)

  // Convert left/right to inside/outside when two-sided
  let margin = c.page.margin
  if two-sided {
    let inside-side = if c.page.binding == right { "right" } else { "left" }
    let outside-side = if inside-side == "left" { "right" } else { "left" }
    margin = (
      inside: margin.at(inside-side, default: margin.at("x", default: 2.5cm)) + binding-correction,
      outside: margin.at(outside-side, default: margin.at("x", default: 2.5cm)),
      top: margin.at("top", default: 2.5cm),
      bottom: margin.at("bottom", default: 2.5cm),
    )
  }

  let page-args = (
    paper: c.page.paper,
    margin: margin,
    fill: c.colors.bg-paper,
    header: if header != none { header } else { none },
    footer: if footer != none { footer } else { none },
    numbering: numbering,
    columns: c.page.columns,
  )
  if two-sided {
    page-args.insert("binding", c.page.binding)
  }
  set page(..page-args)
  set columns(gutter: c.page.column-gutter)

  // Two-sided: alternating page numbers (only when no custom footer provided).
  // Set rules are block-scoped in Typst, so a `set page` inside an `if` block
  // would not apply to the body — compute the footer value, then set it once.
  let page-footer = if two-sided and footer == none {
    context {
      let d = counter(page).display()
      if d != none {
        let n = counter(page).get().first()
        let displayed = text(size: c.page-footer.size, weight: c.page-footer.weight, fill: c.colors.brand-primary, d)
        if calc.rem(n, 2) == 0 {
          align(left, displayed)
        } else {
          align(right, displayed)
        }
      }
    }
  } else {
    if footer != none { footer } else { none }
  }
  set page(footer: page-footer)

  // Two-sided: chapter on even counters, section/chapter on odd counters.
  // Hydra selects the last relevant heading on the page, or the previous one.
  // Including h1 in the odd-page selector resets section context each chapter.
  // Outlined headings include unnumbered chapters but exclude outline titles.
  let page-header = if two-sided and header == none and c.page.at("headers", default: false) {
    context {
      let n = counter(page).get().first()
      let is-even = calc.rem(n, 2) == 0
      let chapters = heading.where(level: 1, outlined: true)
      // Suppress every chapter-opening page, even when styling or a float
      // moves the chapter heading below the top margin.
      let opening = query(chapters).any(h => h.location().page() == here().page())
      if not opening {
        let target = if is-even {
          selectors.custom(chapters)
        } else {
          selectors.custom(heading, filter: (_, h) => h.outlined and h.level <= 2)
        }
        align(
          if is-even { left } else { right },
          text(size: c.decorative.header-size, fill: c.colors.text-muted,
            hydra(target, skip-starting: false, use-last: true, display: (_, h) => h.body)),
        )
      }
    }
  } else {
    if header != none { header } else { none }
  }
  set page(header: page-header)

  // --- Text ---
  set text(
    font: c.typography.font,
    size: c.typography.size,
    fill: c.colors.text-main,
    hyphenate: c.typography.hyphenate,
    lang: "en",
  )

  // --- Paragraph ---
  // Omit auto to retain Typst's native mathematical typeface and local rules.
  let math-typeface = if c.typography.math-font == auto { (:) } else { (font: c.typography.math-font) }
  show math.equation: set text(..math-typeface)
  let mono-typeface = if c.typography.mono-font == auto { (:) } else { (font: c.typography.mono-font) }
  show raw: set text(..mono-typeface)

  set par(
    justify: c.typography.justify,
    leading: c.typography.leading,
    spacing: c.typography.paragraph-spacing,
    first-line-indent: c.typography.first-line-indent,
  )

  // --- List spacing ---
  // Tight lists use paragraph leading instead of the configured item spacing.
  set list(tight: c.decorative.list-tight, spacing: c.decorative.list-spacing)
  set enum(tight: c.decorative.list-tight, spacing: c.decorative.list-spacing)

  // --- Heading numbering (journal uses none) ---
  set heading(numbering: if kind == "journal" { none } else { c.headings.numbering })

  // --- Native heading styling ---
  // Style the heading's own block rather than nesting a second heading block.
  // Native above-spacing, page-start trimming, and stickiness remain intact.
  show heading: set text(hyphenate: c.headings.hyphenate)
  show heading: set par(justify: false)
  show heading.where(level: 1): set text(size: c.headings.h1-size, fill: c.colors.brand-primary, weight: "bold")
  show heading.where(level: 2): set text(size: c.headings.h2-size, fill: c.colors.brand-primary, weight: "bold")
  show heading.where(level: 3): set text(size: c.headings.h3-size, fill: c.colors.brand-primary, weight: "bold")
  show heading.where(level: 4): set text(size: c.headings.h4-size, fill: c.colors.brand-primary, weight: "bold")
  // Setting block(above: auto) replaces native per-level heading skips.
  // Omit the property entirely when callers request native spacing.
  let heading-above(value) = if value == auto { (:) } else { (above: value) }
  show heading.where(level: 1): set block(..heading-above(c.headings.h1-above))
  show heading.where(level: 2): set block(..heading-above(c.headings.h2-above))
  show heading.where(level: 3): set block(..heading-above(c.headings.h3-above))
  show heading.where(level: 4): set block(..heading-above(c.headings.h4-above))
  show heading.where(level: 1): set block(below: c.headings.h1-below)
  show heading.where(level: 2): set block(below: c.headings.h2-below)
  show heading.where(level: 3): set block(below: c.headings.h3-below)
  show heading.where(level: 4): set block(below: c.headings.h4-below)
  show heading.where(level: 1): it => if kind == "journal" {
    block(smallcaps(it.body))
  } else {
    if c.headings.h1-pagebreak { pagebreak(weak: true) }
    it
  }

  // --- Links ---
  // External URLs (string dest) get url-color + underline for all kinds.
  // Internal links, refs (@fig: / @eq:) and cites (@key) get c.links.color
  // for report/thesis; journal stays black. Outline overrides to black below.
  show link: it => {
    if type(it.dest) == str {
      text(fill: c.links.url-color, underline(it))
    } else if kind != "journal" {
      text(fill: c.links.color, it)
    } else {
      it
    }
  }
  // Every ref carries a fallback citation, including resolved figure refs.
  // A resolved element distinguishes cross-references from bibliography keys.
  show ref: it => if kind != "journal" {
    if it.element == none {
      it
    } else {
      text(fill: c.links.color, it)
    }
  } else { it }
  show cite: it => if kind != "journal" {
    // Only the year (4-digit) is colored — not "Fuster & Alexander,"
    show regex("\d{4}[a-z]?"): y => text(fill: c.links.color, y)
    it
  } else { it }

  // --- Table styling (booktabs-style) ---
  set table(
    stroke: none,
    inset: c.tables.inset,
  )

  show table: set text(size: c.tables.font-size)

  // Work-package summaries can continue across pages without clipping.
  show figure.where(kind: "work-package"): set block(breakable: true)

  // Figures with satz-figure store the long caption in <satz-long>
  // metadata, the LoF reads the short caption. Swap the long one back here.
  show figure.caption: set align(c.captions.alignment)
  show figure.caption: it => context {
    set text(size: c.captions.size, weight: c.captions.weight)
    let caploc = here()
    // Find the figure this caption belongs to — closest figure above
    // the caption on the same page.
    let owner = none
    for f in query(figure) {
      let fl = f.location()
      if fl.page() == caploc.page() and fl.position().y <= caploc.position().y {
        if owner == none or fl.position().y > owner.location().position().y {
          owner = f
        }
      }
    }
    let long-cap = none
    if owner != none {
      let top-y = owner.location().position().y
      for m in query(label("satz-long")) {
        let ml = m.location()
        // Only match metadata between this figure's top and its caption.
        if ml.page() == caploc.page() and ml.position().y >= top-y and ml.position().y <= caploc.position().y {
          long-cap = m.value
        }
      }
    }
    if c.captions.label-weight != "regular" {
      let caption-body = if long-cap != none { long-cap } else { it.body }
      if it.numbering != none {
        let separator = if it.separator == auto { [: ] } else { it.separator }
        text(weight: c.captions.label-weight)[
          #if it.supplement != none { [#it.supplement~] }#it.counter.display(it.numbering)#separator
        ]
      }
      caption-body
    } else if long-cap != none {
      // `it` holds supplement/counter/separator but its body is the short
      // text, so rebuild with the long caption.
      [#it.supplement #h(0.2em) #it.counter.display(it.numbering)#it.separator#long-cap]
    } else { it }
  }

  // --- Outline entries ---
  // Keep native numbering, hanging indents, and formatted page numbers.
  // Compact figure/table lists omit only the caption, not the native prefix.
  let lof-compact = "lof" in c and c.lof.at("compact", default: false)
  let lot-compact = "lot" in c and c.lot.at("compact", default: false)
  show outline.entry: it => context {
    let el = it.element
    if el.func() == figure and (
      (el.kind == image and lof-compact) or
      (el.kind == table and lot-compact)
    ) {
      link(el.location(), text(fill: c.colors.text-main,
        it.indented(it.prefix(), [#box(width: 1fr, it.fill) #sym.wj#it.page()])))
    } else {
      it
    }
  }

  // Outline links (ToC/LoF/Lot) — uniform black, no fancy color.
  // Body cross-refs (@fig:...) keep `c.links.color` via the global
  // `show link` above. This show must be inside `outline` scope only;
  // we use a nested show that applies only while rendering the outline.
  // (Do not move `show link` outside — it would affect body links.)
  show outline: it => context {
    show link: lnk => text(fill: c.colors.text-main, lnk)
    show ref: r => text(fill: c.colors.text-main, r)
    show cite: c => text(fill: c.colors.text-main, c)
    it
  }

  // One rhythm for the automatic contents, figure list, and table list.
  // Entry gaps must not fall below leading: paragraph spacing replaces leading
  // at block boundaries, so tiny values squash rows rather than adding air.
  let document-outline(settings, target: heading, contents: false) = {
    if settings.title != none {
      block(below: settings.title-below, sticky: true)[
        #text(size: c.headings.h1-size, fill: c.colors.brand-primary, weight: "bold", settings.title)
      ]
    }
    set text(size: settings.entry-size)
    set par(justify: false, leading: settings.leading, spacing: settings.entry-above, first-line-indent: 0pt)
    show outline.entry: set block(above: settings.entry-above, below: 0pt)
    show outline.entry.where(level: 1): set block(above: if contents { settings.main-entry-above } else { settings.entry-above })
    show outline.entry.where(level: 1): set text(weight: if contents { "bold" } else { "regular" })
    show outline.entry.where(level: 1): set outline.entry(fill: if contents { none } else { repeat(gap: 0.15em)[.] })
    outline(title: none, target: target, depth: settings.depth, indent: settings.indent)
    v(settings.below)
  }

  // --- Bibliography ---
  set bibliography(style: c.bibliography.style)

  // --- Automatic front matter (report/thesis) ---
  // Each list has its own toggle; disabling the contents must not hide tables.
  if kind == "report" or kind == "thesis" {
    context {
      let has-toc = c.toc.depth != 0
      let has-lof = c.lof.depth != 0 and query(figure.where(kind: image, outlined: true)).len() > 0
      let has-lot = c.lot.depth != 0 and query(figure.where(kind: table, outlined: true)).len() > 0
      if has-toc or has-lof or has-lot {
        {
          set page(header: none, footer: none, numbering: none, columns: 1)
          if has-toc { document-outline(c.toc, contents: true) }
          if has-lof {
            if has-toc { pagebreak() }
            document-outline(c.lof, target: figure.where(kind: image))
          }
          if has-lot {
            if has-toc or has-lof { pagebreak() }
            document-outline(c.lot, target: figure.where(kind: table))
          }
        }
        // Update before the pagebreak so the next header sees the right parity.
        // Counter 2 displays as page 1 in reports and theses.
        counter(page).update(2)
        pagebreak()
      }
    }
  }

  assert(c.headings.spacing in ("koma", "native"), message: "headings.spacing must be koma or native.")
  let styled-body = if c.headings.spacing == "koma" { koma-headings(c, kind, body) } else { body }
  let line-spacing = c.typography.line-spacing
  assert(
    line-spacing == none or
      ((type(line-spacing) == int or type(line-spacing) == float) and line-spacing > 0),
    message: "typography.line-spacing must be none or a positive number such as 1.5.",
  )
  if line-spacing == none {
    styled-body
  } else {
    context {
      let font-size = c.typography.size
      let sample = text(
        font: c.typography.font,
        size: font-size,
        top-edge: "cap-height",
        bottom-edge: "baseline",
      )[H]
      let text-height = measure(sample).height
      let target-baseline-gap = font-size * line-spacing
      let calculated-leading = target-baseline-gap - text-height
      assert(
        calculated-leading >= 0pt,
        message: "typography.line-spacing is too small for the selected font and size.",
      )
      {
        // Fix the text frame edges used in the measurement so the configured
        // multiple means the same baseline-to-baseline distance in the body.
        set text(top-edge: "cap-height", bottom-edge: "baseline")
        set par(leading: calculated-leading)
        styled-body
      }
    }
  }
}

// Compatibility alias for documents using the original public name.
#let personal = document-class
