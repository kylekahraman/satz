// Unified document class — kind: "journal" | "report" | "thesis" | "letter"

#import "defaults.typ": defaults, merge
#import "@preview/hydra:0.6.3": hydra, selectors

/// Show a long caption under the figure, a short one in the List of Figures.
///
/// Typst doesn't do short captions — LoF always shows the full text.
/// This works around it: LoF gets the short text,
/// the long one hides as `<satz-long>` metadata.
/// `personal` puts the long one back when it draws the figure.
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
/// Every template calls this. You can also call it yourself
/// if you need a custom doc type.
///
/// ```example
/// #show: personal.with(kind: "thesis", config: (page: (paper: "a5")))
/// = My Thesis
/// ```
///
/// - kind (str): what you build — "journal", "report", "thesis", or "letter"
/// - config (dictionary): tweak the defaults
/// - header (none, content): your own header, if you want one
/// - footer (none, content): your own footer, if you want one
/// - body (content): your content
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
  set par(
    justify: c.typography.justify,
    leading: c.typography.leading,
    spacing: c.typography.paragraph-spacing,
    first-line-indent: c.typography.first-line-indent,
  )

  // --- List spacing ---
  // "Abstand vor/nach Listenpunkt" — extra air between items for readability
  set list(spacing: c.decorative.list-spacing)
  set enum(spacing: c.decorative.list-spacing)

  // --- Heading numbering (journal uses none) ---
  set heading(numbering: if kind == "journal" { none } else { c.headings.numbering })

  // --- Native heading styling ---
  // Style the heading's own block rather than nesting a second heading block.
  // Native above-spacing, page-start trimming, and stickiness remain intact.
  show heading.where(level: 1): set text(size: c.headings.h1-size, fill: c.colors.brand-primary, weight: "bold")
  show heading.where(level: 2): set text(size: c.headings.h2-size, fill: c.colors.brand-primary, weight: "bold")
  show heading.where(level: 3): set text(size: c.headings.h3-size, fill: c.colors.brand-primary, weight: "bold")
  show heading.where(level: 4): set text(size: c.headings.h4-size, fill: c.colors.brand-primary, weight: "bold")
  show heading.where(level: 1): set block(below: c.headings.h1-below)
  show heading.where(level: 2): set block(below: c.headings.h2-below)
  show heading.where(level: 3): set block(below: c.headings.h3-below)
  show heading.where(level: 4): set block(below: c.headings.h4-below)
  show heading.where(level: 1): it => if kind == "journal" {
    block(smallcaps(it.body))
  } else { it }

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
  // NOTE: in Typst a `cite` element is also a `ref`, so `show ref` matches
  // citations too. To color only the year of a citation (handled by `show
  // cite` below), `show ref` must pass citations through untouched; otherwise
  // it would wrap the whole "(Author, Year)" in c.links.color.
  show ref: it => if kind != "journal" {
    // Citations (@key) are also `ref` elements in Typst (they carry a
    // `citation` field). Their year-only coloring is handled by `show cite`
    // below, so pass them through untouched here; only real cross-references
    // (no `citation` field, e.g. @fig: / @eq:) get the full link color.
    if it.has("citation") {
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

  // Figures with satz-figure store the long caption in <satz-long>
  // metadata, the LoF reads the short caption. Swap the long one back here.
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
    if long-cap != none {
      // `it` holds supplement/counter/separator but its body is the short
      // text, so rebuild with the long caption.
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
    show ref: r => text(fill: c.colors.text-main, r)
    show cite: c => text(fill: c.colors.text-main, c)
    it
  }

  // --- Bibliography ---
  set bibliography(style: c.bibliography.style)

  // --- Table of Contents (report/thesis) ---
  if kind != "journal" and c.toc.depth != 0 {
    {
      set page(header: none, footer: none, numbering: none, columns: 1)
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
            set page(header: none, footer: none, numbering: none, columns: 1)
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
            set page(header: none, footer: none, numbering: none, columns: 1)
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
    // Header runs at page start, footer at page end — so update
    // the counter before the pagebreak. Counter 2 displays as 1.
    counter(page).update(2)
    pagebreak()
  }

  body
}
