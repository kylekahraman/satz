// DFG 53.01 (Sachbeihilfe) — shared Satz class with form-specific defaults.
#import "../class.typ": document-class
#import "../defaults.typ": defaults as root-defaults, merge
#import "defaults.typ": defaults as dfg-defaults
#import "../proposal/citations.typ": proposal-publications
#import "layout.typ": proposal-headings, proposal-title

/// Begin the separately counted second part of a DFG project description.
///
/// Place this call exactly once inside `doc`, immediately before the level-one
/// heading for section 4. It inserts a page break and resets the displayed page
/// number to 1 for sections 4–5. Heading numbering continues from section 3;
/// the DFG running header and page-limit check switch to the fixed eight-page
/// supplement allowance. The `dfg-proposal` wrapper checks both parts when
/// `check-pages` is enabled.
///
/// ```typst
/// #show: dfg-proposal.with(doc: [
///   = 1 Starting point
///   ...
///   = 3 Project plan
///   ...
///   #dfg-supplement()
///   = 4 Research data
///   ...
///   = 5 Ethics
/// ])
/// ```
///
/// - arguments: none
/// -> content: page break and metadata marker used by `dfg-proposal`
#let dfg-supplement() = {
  pagebreak()
  counter(page).update(1)
  [#metadata("supplement") <satz-dfg-supplement>]
}

/// Render the publications bibliography without adding another heading.
///
/// Place it under the ordinary level-one publications heading. With
/// `proposal-citations`, omit `source` and this delegates to
/// `proposal-publications()`, preserving highlighted entries.
///
/// - source (str, none): bibliography path; `none` uses `proposal-citations`
/// - size (length): bibliography text size, at least 9pt; defaults to 9pt
/// - style (str): CSL style for a direct `bibliography()` call; defaults to `"apa"`
/// - ..args: one positional bibliography path or native `bibliography` options
#let dfg-publications(source: none, size: 9pt, style: "apa", ..args) = {
  assert(size >= 9pt, message: "DFG publications must be at least 9pt.")
  set text(size: size)
  let positional = args.pos()
  assert(positional.len() <= 1, message: "Provide one bibliography source.")
  let chosen = if positional.len() == 1 { positional.first() } else { source }
  if chosen == none {
    assert(args.named().len() == 0, message: "Set CSL options on proposal-citations, not dfg-publications.")
    proposal-publications(size: size, max-highlight: 10)
  } else {
    bibliography(chosen, title: none, style: style, ..args.named())
  }
}

/// DFG form 53.01 project description, revision 09/26, in German or English.
///
/// Uses Arial 11pt, four numbered heading levels, and no contents or cover page.
/// `dfg-supplement()` starts the separately counted eight-page second part.
/// By default compilation fails when either part exceeds its allowance.
///
/// ```example
/// #show: dfg-proposal.with(
///   applicant: [Alex Example, Example University],
///   project: [A small example project],
///   doc: [
///     = 1 Starting point
///     ...
///     #dfg-supplement()
///     = 4 Project plan
///   ],
/// )
/// ```
///
/// - doc (content): numbered project description including headings 1–5
/// - applicant (content): applicant and institution block; defaults to empty
/// - project (content): project title block; defaults to empty
/// - language (str): `"english"` (default) or `"german"`
/// - max-pages (int): first-part page limit; defaults to 17. Sections 1–3 use
///   this limit; sections 4–5 always use the eight-page supplement limit
/// - form-date (str): displayed DFG form date; defaults to `"09/26"`
/// - check-pages (bool): fail compilation on an overlength draft when true
///   (default); set false for a working draft
/// - config (dictionary): overrides applied after the DFG form preset; explicit values win.
///   The exported `defaults` dictionary documents the shared schema once. Use a namespace
///   import and hover `satz.defaults` for keys, accepted forms, meanings, and baseline
///   values. DFG overrides A4 page geometry, Arial 11pt, four-level numbering, black
///   text/links, white paper, left-aligned 11pt captions, and form-specific heading/list
///   spacing. It also adds `page.header-ascent` and `decorative.list-indent`,
///   `list-body-indent`, `list-spacing`, and `list-block-spacing`. Preserve these form
///   values when preparing a submission; see the configuration reference for their
///   effective values and the DFG-specific extension fields.
#let dfg-proposal(
  applicant: [], project: [], language: "english", max-pages: 17,
  form-date: "09/26", check-pages: true, config: (:), doc,
) = {
  assert(language in ("english", "german"), message: "DFG language must be english or german.")
  assert(type(max-pages) == int and max-pages > 0, message: "max-pages must be a positive integer.")
  assert(type(form-date) == str, message: "DFG form-date must be a string such as `09/26`.")
  assert(type(check-pages) == bool, message: "DFG check-pages must be true or false.")
  let de = language == "german"
  let c = merge(merge(root-defaults, dfg-defaults), config)
  let furniture = context {
    let parts = query(<satz-dfg-supplement>)
    let supplementary = parts.len() > 0 and here().page() >= parts.first().location().page()
    let limit = if supplementary { 8 } else { max-pages }
    // Headers are placed before counter updates in the body. Compute the part
    // page from physical locations so the reset page itself cannot show "2".
    let part-page = if supplementary { here().page() - parts.first().location().page() + 1 } else { here().page() }
    text(size: c.decorative.header-size, weight: "regular")[#if de [DFG-Vordruck] else [DFG form] 53.01 – #form-date #h(1fr) #if de [Seite] else [page] #part-page #if de [von max.] else [of max.] #limit]
  }
  document-class(kind: "proposal", config: c, header: furniture)[
    #set text(lang: if de { "de" } else { "en" }, top-edge: 1467 / 2048 * 1em, bottom-edge: 0pt)
    #set page(numbering: none, footer: none, header-ascent: c.page.header-ascent)
    #set list(indent: c.decorative.list-indent, body-indent: c.decorative.list-body-indent, spacing: c.decorative.list-spacing)
    #set enum(indent: c.decorative.list-indent, body-indent: c.decorative.list-body-indent, spacing: c.decorative.list-spacing)
    #show list: set block(above: c.decorative.list-block-spacing, below: c.decorative.list-block-spacing)
    #show enum: set block(above: c.decorative.list-block-spacing, below: c.decorative.list-block-spacing)
    #show link: it => text(fill: c.links.color, it)
    #v(11 * 72 / 72.27 * 1pt - 1467 / 2048 * 11pt)
    #proposal-title(c,
      if de [Beschreibung des Vorhabens – Projektanträge] else [Project Description – Project Proposals],
      applicant, project,
      if de [Beschreibung des Vorhabens] else [Project Description],
    )
    #proposal-headings(c, doc)
    #metadata("end") <satz-dfg-end>
    #context {
      let parts = query(<satz-dfg-supplement>)
      assert(parts.len() <= 1, message: "Use dfg-supplement() only once.")
      let last = query(<satz-dfg-end>).first().location().page()
      let first-pages = if parts.len() == 0 { last } else { parts.first().location().page() - 1 }
      let extra-pages = last - first-pages
      if check-pages {
        let sections = query(heading.where(level: 1)).filter(h => h.numbering != none)
        if sections.len() >= 4 {
          assert(parts.len() == 1, message: "Insert dfg-supplement() immediately before section 4.")
          let boundary = parts.first().location().position()
          let section-four = sections.at(3).location().position()
          assert(boundary.page == section-four.page and boundary.y <= section-four.y,
            message: "Insert dfg-supplement() immediately before section 4.")
        }
        assert(first-pages <= max-pages, message: "DFG sections 1–3 exceed " + str(max-pages) + " pages (" + str(first-pages) + ").")
        assert(extra-pages <= 8, message: "DFG sections 4–5 exceed 8 pages (" + str(extra-pages) + ").")
      }
    }
  ]
}
