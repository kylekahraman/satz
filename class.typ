// Unified document class — kind: "journal" | "report" | "thesis" | "letter"

#import "defaults.typ": defaults, merge

/// A figure with a decoupled List-of-Figures caption.
///
/// Typst has no built-in short caption, so `outline` always pulls the full
/// `figure.caption` verbatim into the List of Figures. This helper lets you
/// show a long caption under the figure while the LoF shows a short title.
///
/// How it works: the figure's `caption` is set to `short-caption` (so the LoF
/// reads the short text automatically), and the long `caption` is stored as
/// invisible `<satz-long>` metadata inside the figure body. A `show
/// figure.caption` rule in `personal` swaps the displayed caption back to the
/// long text when that metadata is present.
///
/// If `short-caption` is omitted, the figure behaves exactly like a plain
/// `figure` (long caption is used for both display and the LoF).
///
/// - body (content): The figure body (image, rect, etc.)
/// - caption (content): Long caption shown under the figure
/// - short-caption (content): Short title shown in the List of Figures
/// - ..args: Passed through to `figure` (e.g. `placement`, `kind`)
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

  // --- Running header state (same pattern as journal/template.typ) ---
  // State updated by heading show rules, read by the page header.
  let chapter-state = state("satz-chapter", none)
  let section-state = state("satz-section", none)

  // --- Build page arguments ---
  let numbering = if kind == "report" or kind == "thesis" {
    (n) => { if n > 1 { str(n - 1) } else { none } }
  } else {
    none
  }
  let two-sided = "binding" in c.page and c.page.binding != none

  // Convert left/right to inside/outside when two-sided
  let margin = c.page.margin
  if two-sided {
    margin = (
      inside: margin.at("left", default: margin.at("x", default: 2.5cm)),
      outside: margin.at("right", default: margin.at("x", default: 2.5cm)),
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
  )
  if two-sided {
    page-args.insert("binding", c.page.binding)
  }
  set page(..page-args)

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

  // Two-sided: textbook-style running headers.
  // Uses state variables (same pattern as journal) instead of query().
  // Even pages (left) show the chapter (h1), odd pages (right) show the
  // section (h2) with fallback to h1. No running header on pages before
  // any heading has been encountered (chapter opening pages, textbook convention).
  let page-header = if two-sided and header == none and c.page.at("headers", default: false) {
    context {
      let n = counter(page).get().first()
      let is-even = calc.rem(n, 2) == 0
      if is-even {
        let ch = chapter-state.get()
        if ch != none {
          align(left, text(size: c.decorative.header-size, fill: c.colors.text-muted, ch.body))
        }
      } else {
        let sec = section-state.get()
        if sec == none {
          sec = chapter-state.get()
        }
        if sec != none {
          align(right, text(size: c.decorative.header-size, fill: c.colors.text-muted, sec.body))
        }
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
  set par(
    justify: c.typography.justify,
    leading: c.typography.leading,
  )

  // --- List spacing ---
  // "Abstand vor/nach Listenpunkt" — extra air between items for readability
  set list(spacing: c.decorative.list-spacing)
  set enum(spacing: c.decorative.list-spacing)

  // --- Heading numbering (journal uses none) ---
  set heading(numbering: if kind == "journal" { none } else { c.headings.numbering })

  // --- Heading show rules ---
  show heading.where(level: 1): it => {
    // Exclude the auto-generated TOC/LOF/LOT title headings from running header state
    if it.body != c.toc.title and it.body != c.lof.title and it.body != c.lot.title {
      context { chapter-state.update((body: it.body, page: counter(page).get().first())) }
    }
    block(width: 100%, below: c.headings.h1-below)[
      #set text(fill: c.colors.brand-primary, weight: "bold", size: c.headings.h1-size)
      #v(0.5em)
      #if kind == "journal" {
        smallcaps(it.body)
      } else {
        it
      }
    ]
  }
  show heading.where(level: 2): it => {
    context { section-state.update((body: it.body, page: counter(page).get().first())) }
    block(below: c.headings.h2-below)[
      #set text(fill: c.colors.brand-primary, weight: "bold", size: c.headings.h2-size)
      #it
    ]
  }
  show heading.where(level: 3): it => block(below: c.headings.h3-below)[
    #set text(fill: c.colors.brand-primary, weight: "bold", size: c.headings.h3-size)
    #it
  ]
  show heading.where(level: 4): it => block(below: c.headings.h4-below)[
    #set text(fill: c.colors.brand-primary, weight: "bold", size: c.headings.h4-size)
    #it
  ]

  // --- Links ---
  // External URLs (string dest) get url-color + underline for all document kinds.
  // Internal links (cross-refs, TOC) get color only for report/thesis.
  show link: it => {
    if type(it.dest) == str {
      text(fill: c.links.url-color, underline(it))
    } else if kind != "journal" {
      text(fill: c.links.color, it)
    } else {
      it
    }
  }

  // --- Table styling (booktabs-style) ---
  set table(
    stroke: none,
    inset: (x: 8pt, y: 4pt),
  )

  // --- Figure/table caption styling ---
  // Captions are styled here. Figures built with `satz-figure` may carry a
  // long caption for display (stored as invisible `<satz-long>` metadata inside
  // the figure body) while the figure's `caption` holds the short LoF text.
  // When that metadata is present, the long caption is shown below the figure;
  // the List of Figures still reads the short `caption` from the figure element.
  show figure.caption: it => context {
    set text(size: c.captions.size, weight: c.captions.weight)
    let caploc = here()
    // Locate the figure that owns this caption (closest figure start at/above
    // the caption on the same page). This prevents a figure from inheriting
    // another figure's stored long caption.
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
        // The metadata sits at the figure body's start, between the figure
        // top and its caption — restrict the match to this figure's span.
        if ml.page() == caploc.page() and ml.position().y >= top-y and ml.position().y <= caploc.position().y {
          long-cap = m.value
        }
      }
    }
    if long-cap != none {
      // Rebuild "Figure 1: <long caption>" — `it` holds supplement/counter/separator
      // but its body is the short LoF text, so we swap in long-cap.
      [#it.supplement #h(0.2em) #it.counter.display(it.numbering)#it.separator#long-cap]
    } else { it }
  }

  // --- Compact LoF/Lot (global, no per-figure changes) ---
  // When `lof.compact` / `lot.compact` is true, the outline shows only
  // "Figure 1 .... 5" / "Table 1 .... 5" without caption text.
  // Show rule must be unconditional — `show` inside `if` is dead code
  // in Typst (see AGENTS.md: "set/show rules inside if blocks are dead code").
  let lof-compact = "lof" in c and c.lof.at("compact", default: false)
  let lot-compact = "lot" in c and c.lot.at("compact", default: false)
  show outline.entry: it => context {
    if lof-compact or lot-compact {
      let el = it.element
      if el.func() == figure {
        let is-lof = el.kind == image and lof-compact
        let is-lot = el.kind == table and lot-compact
        if is-lof or is-lot {
          let loc = el.location()
          let fig-num = if el.kind == image {
            counter(figure.where(kind: image)).at(loc).first()
          } else {
            counter(figure.where(kind: table)).at(loc).first()
          }
          // Force black for LoF/Lot entries — no fancy link color
          let body = link(loc, text(fill: c.colors.text-main, [#el.supplement #fig-num]))
          // Page number respecting report/thesis offset (display = raw-1)
          let raw-pg = counter(page).at(loc).first()
          let pg-str = if kind == "report" or kind == "thesis" {
            if raw-pg > 1 { str(raw-pg - 1) } else { none }
          } else {
            str(raw-pg)
          }
          block(width: 100%, inset: (y: 2pt), [#body #box(width: 1fr, it.fill) #text(fill: c.colors.text-main, pg-str)])
        } else {
          it
        }
      } else {
        it
      }
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
    it
  }

  // --- Bibliography ---
  set bibliography(style: c.bibliography.style)

  // --- Table of Contents (report/thesis) ---
  if kind != "journal" and c.toc.depth != 0 {
    {
      set page(header: none, footer: none, numbering: none)
      outline(
        title: c.toc.title,
        depth: c.toc.depth,
        indent: c.toc.indent,
      )
      v(c.toc.below)
    }
    // --- List of Figures (report/thesis) ---
    // Auto-hide when no figures exist: the pagebreak and title are guarded by a
    // query() so an empty document yields no LoF page at all.
    if "lof" in c and c.lof.depth != 0 {
      context {
        if query(figure.where(kind: image)).len() > 0 {
          pagebreak()
          {
            set page(header: none, footer: none, numbering: none)
            outline(
              title: c.lof.title,
              target: figure.where(kind: image),
              depth: c.lof.depth,
              indent: c.lof.indent,
            )
            v(c.lof.below)
          }
        }
      }
    }
    // --- List of Tables (report/thesis) ---
    // Auto-hide when no tables exist: same guard as the LoF above.
    if "lot" in c and c.lot.depth != 0 {
      context {
        if query(figure.where(kind: table)).len() > 0 {
          pagebreak()
          {
            set page(header: none, footer: none, numbering: none)
            outline(
              title: c.lot.title,
              target: figure.where(kind: table),
              depth: c.lot.depth,
              indent: c.lot.indent,
            )
            v(c.lot.below)
          }
        }
      }
    }
    // Start content on fresh page, numbering at 1.
    // The template's numbering function is (n) => if n > 1 { str(n-1) },
    // so counter=2 displays "1" on the first content page.
    // Counter=2 is even → left page → running header shows h1 (chapter name).
    //
    // Set the counter BEFORE the pagebreak: update(2) makes the first content
    // page read counter=2 → displays "1" on the left (verso) page. The header
    // is evaluated at page start (unlike the footer at page end), so updating
    // after the pagebreak would leave the header on the first content page
    // seeing the natural counter (higher when LOF/LOT are enabled) → wrong
    // page number and parity.
    counter(page).update(2)
    pagebreak()
  }

  body
}
