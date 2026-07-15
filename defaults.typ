// Unified defaults for the personal document class.
// All config keys with their default values.
// Copy sections you want to change into your project's config.typ.

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

// Shallow merge: user overrides win
#let merge(base, overrides) = {
  let result = base
  for (k, v) in overrides {
    result.insert(k, v)
  }
  result
}
