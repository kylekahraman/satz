#import "../class.typ": document-class
#import "../defaults.typ": defaults as root-defaults, merge
#import "defaults.typ": defaults as nwo-defaults
#import "profiles.typ": nwo-profile

/// Format the hierarchical section numbers used by supported NWO forms.
///
/// The form pattern alternates decimal and alphabetic parts: `form-number(2)`
/// returns `2`, `form-number(2, 1)` returns `2a.`,
/// `form-number(2, 1, 3)` returns `2a1.`, and a fourth part returns `2a1a.`.
/// The NWO template passes this function to `headings.numbering`; users do not
/// normally need to call it directly.
///
/// - ..parts (integers): nested section numbers; the NWO template supplies up
///   to four positive values
/// -> str: formatted NWO section number
#let form-number(..parts) = {
  let n = parts.pos()
  let result = str(n.first())
  if n.len() > 1 { result += numbering("a", n.at(1)) }
  if n.len() > 2 { result += str(n.at(2)) }
  if n.len() > 3 { result += numbering("a", n.at(3)) }
  result + if n.len() > 1 { "." } else { "" }
}

/// NWO Talent Programme application layout using an explicit checked profile.
///
/// Ordinary headings continue to work. There is no cover, contents, or page
/// counter reset. Pages have a stable current/total header from page 1. This is
/// a source-checked authoring aid, not universal submission certification.
///
/// ```example
/// #show: nwo-proposal.with(
///   scheme: "veni",
///   domain: "science",
///   stage: "pre",
///   applicant: [Alex Example],
///   title: [Example research idea],
/// )
/// = Key output
/// #nwo-text("key-output", "A short plain-text response.")
/// ```
///
/// - scheme (str): `"veni"` (default), `"vidi"`, or `"vici"`
/// - domain (str): `"science"` (default), `"ssh"`, `"aes"`, or `"zonmw"`
/// - stage (str): `"pre"` (default) or `"full"`. In 2026, only Vici full
///   proposals are represented; other full-proposal forms fail explicitly
/// - year (int): source-checked form year; must be 2026
/// - applicant (content, str): applicant block; defaults to empty
/// - title (content, str): proposal title; defaults to empty
/// - config (dictionary): nested Satz overrides merged after shared defaults, NWO defaults,
///   and selected profile typography. Explicit values win over profile values. The shared
///   schema is documented once on the exported `defaults` dictionary; hover `satz.defaults`
///   with a namespace import. Page, typography, heading, list, color, and link defaults
///   vary by supported 2026 profile. NWO also supports `page.header-ascent`; see the
///   configuration reference for profile-specific effective values and extensions.
/// - body (content): the application sections
#let nwo-proposal(
  scheme: "veni", domain: "science", stage: "pre", year: 2026,
  applicant: [], title: [], config: (:), body,
) = {
  let profile = nwo-profile(scheme: scheme, domain: domain, stage: stage, year: year)
  let sized = (
    typography: (size: profile.size), tables: (font-size: profile.size),
    captions: (size: profile.size),
    headings: (numbering: form-number, h1-size: 14pt, h2-size: 12pt, h3-size: 11pt, h4-size: profile.size),
  )
  let c = merge(merge(merge(root-defaults, nwo-defaults), sized), config)
  let furniture = context {
    text(size: 8pt, fill: black)[
      NWO · #upper(scheme) #year · #if stage == "pre" [Pre-proposal] else [Full proposal]
      #h(1fr) Page #here().page() / #counter(page).final().first()
    ]
  }
  document-class(kind: "proposal", config: c, header: furniture)[
    #set text(lang: "en")
    #set page(numbering: none, footer: none)
    #show heading: set heading(bookmarked: false)
    #state("satz-nwo-profile").update(profile)
    #counter("satz-nwo-output").update(0)
    #state("satz-nwo-page-height").update(297mm - c.page.margin.top - c.page.margin.bottom)
    #align(left)[
      #text(size: 16pt, weight: "bold", fill: c.colors.brand-primary)[NWO Talent Programme – #upper(scheme)]
      #parbreak()
      #text(weight: "bold")[Grant application #if stage == "pre" [pre-proposal] else [full proposal] form #year]
      #parbreak()
      #profile.domain-name
      #if applicant != [] { parbreak(); applicant }
      #if title != [] { parbreak(); strong(title) }
    ]
    #body
    #context {
      assert(query(<satz-nwo-key-output>).len() <= 10, message: "NWO allows at most ten key output items.")
    }
  ]
}
