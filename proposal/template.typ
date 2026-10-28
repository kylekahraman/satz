#import "../class.typ": document-class
#import "../defaults.typ": defaults as root-defaults, merge
#import "defaults.typ": defaults as proposal-defaults

/// A general research or project proposal with an inline title and summary.
///
/// No funder-specific headings or page limits are imposed; write ordinary
/// markup. The running header shows the short title and current/total page
/// numbers from page 1.
///
/// ```example
/// #show: research-proposal.with(
///   title: [Example proposal],
///   applicants: [Alex Example],
///   institution: [Example University],
///   summary: [We propose a small example.],
/// )
/// = Objectives
/// #lorem(60)
/// ```
///
/// - title (content, str): proposal title; defaults to empty
/// - applicants (content, str): applicant line; defaults to empty
/// - institution (content, str): institution line; defaults to empty
/// - date (content, str, none): optional date printed verbatim
/// - summary (content, none): optional summary block
/// - short-title (content, str, none): running-header title; `none` reuses `title`
/// - language (str): `"english"` (default) or `"german"`; controls labels and
///   Typst language
/// - config (dictionary): shared Satz settings. For example,
///   `config: (typography: (font: "Libertinus Serif", size: 11pt),
///   colors: (brand-primary: blue))`. Shared defaults and all available keys
///   are in `defaults.typ`; proposal-specific defaults are in
///   `proposal/defaults.typ`.
/// - body (content): proposal sections
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

/// Alias for `research-proposal`, using the same flexible layout.
#let project-proposal = research-proposal
