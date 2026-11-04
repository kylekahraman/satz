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
/// - config (dictionary): nested Satz overrides, recursively merged last over
///   the shared defaults, the NWO defaults, and profile-specific typography.
///   Explicit values therefore win over the profile's type size and the NWO
///   black palette. Unknown top-level groups are retained as extensions;
///   known shared groups must be dictionaries and known keys are validated.
///   The effective page, type, heading, list, color, and link defaults depend
///   on the selected 2026 profile. All supported shared fields are listed here:
///   - `page.paper` (paper name; `"a4"`), `page.margin` (edge dictionary;
///     2.5cm on all sides), `page.binding` (`none`),
///     `page.binding-correction` (`0pt`), `page.headers` (`false`),
///     `page.columns` (1), `page.column-gutter` (5mm), and NWO-specific
///     `page.header-ascent` (length; template default).
///   - `typography.font` (font name; `"Libertinus Serif"`), `math-font` and
///     `mono-font` (font name or `auto`; `auto`), `size` (11pt shared baseline;
///     profile default is 9.5pt for pre-proposals and 10pt for Vici full),
///     `line-spacing` (positive baseline multiple or `none`),
///     `leading` (0.65em), `paragraph-spacing` (1.2em),
///     `first-line-indent` (`false`), `hyphenate` (`false`), and `justify`
///     (`true`).
///   - `headings.numbering` (pattern/function or `none`; `"1.1"`, profile
///     override), `hyphenate` (`false`), `h1-pagebreak` (`false`),
///     `spacing` (`"koma"` or `"native"`; `"koma"`), and for levels 1–4
///     `hN-size` (14pt/12pt/11pt/profile size), `hN-above` (`auto`), and
///     `hN-below` (`auto`). NWO sets a form-numbering function and the listed
///     heading sizes. NWO also sets table and caption text size to the profile
///     size.
///   - `journal.header-below` (1.5em), `running-gutter` (1em),
///     `running-leading` (0.35em), `running-header-size` (9pt), `date-size`
///     (10pt), `keywords-size` (9pt), `list-tight` (false), and
///     `list-spacing` (0.9em); these are accepted shared fields but do not
///     affect this proposal layout.
///   - `decorative.header-size` (9pt), `footer-size` (10pt), `date-size`
///     (10pt), `keywords-size` (9pt), `list-tight` (`false`), and
///     `list-spacing` (0.9em).
///   - `page-footer.format` (numbering pattern; `"1"`), `size` (10pt), and
///     `weight` (`"regular"`).
///   - `line-numbers.enabled` (`false`), `format` (`"1"`),
///     `scope` (`"document"` or `"page"`; `"document"`), `size` (8pt),
///     `color` (`#64748B`), and `clearance` (`auto` or length; `auto`).
///   - `links.color` and `url-color` (colors; `#0563C1` baseline; NWO defaults
///     both to black).
///   - `tables.stroke` (0.5pt), `inset` ((x: 8pt, y: 4pt)), `font-size` (10pt,
///     profile override), `caption-position` (`top` or `bottom`; `top`), and
///     `caption-gap` (6pt).
///   - `callouts.inset` (9pt), `radius` (3pt), `stroke` (0.8pt),
///     `title-below` (1em), `paragraph-spacing` (1em), `list-spacing` (1.2em).
///   - `captions.size` (10pt, profile override), `weight` (`"regular"`),
///     `alignment` (`center`; NWO defaults to `left`), and
///     `label-weight` (`"regular"`).
///   - `toc`, `lof`, and `lot` each accept `depth` (none), `title` (their
///     English default title), `indent` (`auto`), `entry-size` (10pt),
///     `leading` (0.65em), `entry-above` (0.65em for toc, 0.85em for lof/lot),
///     `title-below` (1.5em), and `below` (2em). `toc.main-entry-above` is
///     1.25em; `lof.compact` and `lot.compact` are `false`.
///   - `bibliography.style` (CSL name; `"apa"`).
///   - `colors.bg-paper`, `bg-subtle`, `brand-primary`, `brand-accent`,
///     `text-main`, `text-muted` (colors; white/black shared baseline; NWO
///     sets paper, text, and primary accent to white/black/black).
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
