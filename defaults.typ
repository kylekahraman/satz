// Unified defaults for the satz document class.
// All config keys with their default values.
// Copy sections you want to change into your project's config.typ.

/// Default configuration dictionary for the satz document class.
///
/// Override individual keys by passing a partial dictionary to any template function.
/// Keys use deep merge — nested dictionaries are merged recursively.
///
/// Sections:
/// - page (dictionary): paper size, margins, binding correction
/// - typography (dictionary): font, size, leading, hyphenation, justification
/// - headings (dictionary): numbering scheme, sizes, spacing per level
/// - decorative (dictionary): sizes for headers, footers, dates, keywords, lists
/// - page-footer (dictionary): page number format, size, weight
/// - links (dictionary): link color
/// - toc (dictionary): table of contents configuration
/// - bibliography (dictionary): citation style
/// - colors (dictionary): color palette (bg-paper, brand-primary, text-main, etc.)
#let defaults = (
  page: (
    paper: "a4",
    margin: (top: 2.5cm, bottom: 2.5cm, left: 2.5cm, right: 2.5cm),
    // TODO: binding correction (BCOR) for double-sided book layout
    // binding: none,  // future: auto | length
  ),
  typography: (
    font: "Libertinus Serif",
    size: 11pt,
    leading: 0.65em,
    hyphenate: false,
    justify: true,
  ),
  headings: (
    numbering: "1.1",
    h1-size: 14pt,  h1-below: 0.65em,
    h2-size: 12pt,  h2-below: 0.65em,
    h3-size: 11pt,  h3-below: 0.65em,
    h4-size: 11pt,  h4-below: 0.4em,
  ),
  decorative: (
    header-size: 9pt,
    footer-size: 10pt,
    date-size: 10pt,
    keywords-size: 9pt,
    list-spacing: 0.65em,
  ),
  page-footer: (
    format: "1",
    size: 10pt,
    weight: "bold",
  ),
  links: (
    color: rgb("#B4313F"),
  ),
  tables: (
    stroke: 0.5pt,
    inset: (x: 8pt, y: 4pt),
    font-size: 10pt,
  ),
  toc: (
    // Set depth: 0 to disable. none = auto (uses heading numbering depth).
    depth: none,
    // Title shown above the table of contents. Set to none to omit.
    title: [Table of Contents],
    // Indent per heading level (e.g. 1em for sub-sections)
    indent: 1em,
    // Spacing below the ToC before body content begins
    below: 2em,
  ),
  bibliography: (
    style: "apa",
  ),
  colors: (
    bg-paper: rgb("#fafafa"),
    bg-subtle: rgb("#f5f5f5"),
    brand-primary: rgb("#14151a"),
    brand-accent: rgb("#2a2b30"),
    text-main: rgb("#1e1f24"),
    text-muted: rgb("#5e5e5a"),
  ),
)

/// Deep merge: user overrides win, nested dictionaries are merged recursively.
///
/// Unlike shallow merge, this preserves unmentioned keys in nested dicts.
/// Example: `config: (colors: (brand-primary: blue))` only changes that one color;
/// all other colors (bg-paper, text-main, etc.) keep their defaults.
///
/// - base (dictionary): The full defaults dictionary
/// - overrides (dictionary): User-provided partial overrides
/// -> dictionary
#let merge(base, overrides) = {
  let result = (:)
  for (k, v) in base {
    result.insert(k, v)
  }
  for (k, v) in overrides {
    if type(v) == dictionary and k in result and type(result.at(k)) == dictionary {
      result.insert(k, merge(result.at(k), v))
    } else {
      result.insert(k, v)
    }
  }
  result
}
