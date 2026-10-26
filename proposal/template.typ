#import "../class.typ": document-class
#import "../defaults.typ": defaults as root-defaults, merge
#import "defaults.typ": defaults as proposal-defaults

/// A general research or project proposal, with an inline title and summary.
/// No funder-specific headings or page limits are imposed. Use ordinary markup.
/// The header shows the short title and current/total page numbers from page 1.
/// `config` accepts the shared Satz settings; `language` is `"english"` or `"german"`.
#let research-proposal(
  title: [], applicants: [], institution: [], date: none, summary: none,
  short-title: none, language: "english", config: (:), body,
) = {
  assert(language in ("english", "german"), message: "Proposal language must be english or german.")
  let de = language == "german"
  let c = merge(merge(root-defaults, proposal-defaults), config)
  let furniture = context {
    text(size: c.decorative.header-size)[
      #if short-title == none { title } else { short-title }
      #h(1fr)
      #if de [Seite] else [Page] #counter(page).display("1 / 1", both: true)
    ]
  }
  document-class(kind: "proposal", config: c, header: furniture)[
    #set text(lang: if de { "de" } else { "en" })
    #set page(numbering: none, footer: none)
    #align(left)[
      #text(size: 20pt, weight: "bold", title)
      #parbreak()
      #applicants
      #parbreak()
      #institution
      #if date != none { parbreak(); date }
    ]
    #v(1em)
    #if summary != none {
      block[
        #text(weight: "bold", if de [Zusammenfassung] else [Summary])
        #parbreak()
        #summary
      ]
    }
    #body
  ]
}

/// Alias for general project proposals using the same flexible layout.
#let project-proposal = research-proposal
