// DFG 53.01 (Sachbeihilfe) — shared Satz class with form-specific defaults.
#import "../class.typ": personal
#import "../defaults.typ": defaults as root-defaults, merge
#import "defaults.typ": defaults as dfg-defaults

/// Start sections 4–5 on a new page, resetting the displayed page to 1.
/// Insert exactly once, immediately before the level-one section 4 heading.
/// Heading numbering continues; the header changes to an eight-page limit.
#let dfg-supplement() = {
  pagebreak()
  counter(page).update(1)
  [#metadata("supplement") <satz-dfg-supplement>]
}

/// Render section 3's bibliography at 9, 10 or 11pt (without another heading).
/// Place under the ordinary level-one publications heading.
#let dfg-publications(source, size: 9pt, style: "apa", ..args) = {
  assert(size >= 9pt, message: "DFG publications must be at least 9pt.")
  set text(size: size)
  bibliography(source, title: none, style: style, ..args)
}

/// DFG form 53.01 project description, revision 09/26, German or English.
/// Uses Arial 11pt, four numbered heading levels, and no contents/cover page.
/// `dfg-supplement()` starts the separately counted eight-page second part.
/// By default compilation fails when either part exceeds its page allowance.
/// `max-pages` preserves the legacy first-part limit parameter.
/// `check-pages: false` permits an overlength working draft.
/// Config overrides are available, but authors must retain DFG formatting.
#let dfg-proposal(
  applicant: [], project: [], language: "english", max-pages: 17,
  form-date: "09/26", check-pages: true, config: (:), doc,
) = {
  assert(language in ("english", "german"), message: "DFG language must be english or german.")
  assert(type(max-pages) == int and max-pages > 0, message: "max-pages must be a positive integer.")
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
  personal(kind: "proposal", config: c, header: furniture)[
    #set text(lang: if de { "de" } else { "en" })
    #set page(numbering: none, footer: none)
    #show link: it => text(fill: c.links.color, it.body)
    #align(left, text(weight: "bold")[
      #if de [Beschreibung des Vorhabens – Projektanträge] else [Project Description – Project Proposals]
      #parbreak()
      #applicant
      #parbreak()
      #project
      #parbreak()
      #line(length: 100%, stroke: 0.5pt)
      #parbreak()
      #if de [Beschreibung des Vorhabens] else [Project Description]
    ])
    #v(1em)
    #doc
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
