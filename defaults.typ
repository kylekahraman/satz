// Unified defaults for the satz document class.
// All config keys with their default values.
// Copy sections you want to change into your project's config.typ.

/// All the knobs for your document.
///
/// Pass only what you want to change — the rest stays.
/// Nested dicts merge deep, so `config: (colors: (brand-primary: blue))` just changes that one color.
///
/// Common defaults are A4 paper with 2.5cm margins; Libertinus Serif at 11pt;
/// `math-font: auto` and `mono-font: auto`; justified paragraphs; 1.2em between
/// paragraphs; numbered headings; and the neutral black-on-white palette.
/// With `math-font: auto`, Satz leaves
/// equations to Typst, whose default math font is New Computer Modern Math.
/// The Typst CLI embeds that font, so users do not need to install it.
/// Templates can override these defaults.
/// For example, an article can select STIX fonts and a smaller page setup with:
///
/// ```typst
/// #show: article.with(config: (
///   typography: (font: "STIX Two Text", math-font: "STIX Two Math", size: 9.6pt),
///   page: (paper: "a4", margin: (top: 2cm, bottom: 2cm, x: 2.3cm)),
/// ))
/// ```
///
/// - page: `paper`, `margin`, `binding`, `binding-correction`, `headers`,
///   `columns`, `column-gutter`
/// - typography: `font`, `math-font`, `mono-font`, `size`, `line-spacing`,
///   `leading`, `paragraph-spacing`, `first-line-indent`, `hyphenate`, `justify`
/// - headings: `numbering`, `hyphenate`, `h1-pagebreak`, `spacing`, and
///   `h1`–`h4` size/above/below values
/// - journal: `header-below`, `running-gutter`, `running-leading`
/// - decorative: header/footer/date/keyword sizes, `list-tight`, `list-spacing`
/// - page-footer: `format`, `size`, `weight`; links: `color`, `url-color`
/// - tables: `stroke`, `inset`, `font-size`, `caption-position`, `caption-gap`
/// - callouts: `inset`, `radius`, `stroke`, `title-below`, paragraph/list spacing
/// - captions: `size`, `weight`, `alignment`, `label-weight`
/// - toc / lof / lot: `depth`, `title`, `indent`, entry size/leading/spacing,
///   title/bottom spacing; LoF and LoT also accept `compact`
/// - bibliography: `style`; colors: `bg-paper`, `bg-subtle`, `brand-primary`,
///   `brand-accent`, `text-main`, `text-muted`
#let defaults = (
  page: (
    paper: "a4",
    margin: (top: 2.5cm, bottom: 2.5cm, left: 2.5cm, right: 2.5cm),
    binding: none,
    binding-correction: 0pt,
    headers: false,
    columns: 1,
    column-gutter: 5mm,
  ),
  typography: (
    font: "Libertinus Serif",
    math-font: auto,
    mono-font: auto,
    size: 11pt,
    // Optional baseline-to-baseline multiple of the body font size.
    // When set, this is translated to Typst leading using the selected font's metrics.
    line-spacing: none,
    // Backward-compatible Typst gap between adjacent line boxes.
    leading: 0.65em,
    paragraph-spacing: 1.2em,
    first-line-indent: 0pt,
    hyphenate: false,
    justify: true,
  ),
  headings: (
    numbering: "1.1",
    hyphenate: false,
    h1-pagebreak: false,
    // auto translates KOMA baseline skips using the actual body/heading fonts.
    // Explicit lengths remain Typst block gaps. "native" opts out of translation.
    spacing: "koma",
    h1-size: 14pt, h1-above: auto, h1-below: auto,
    h2-size: 12pt, h2-above: auto, h2-below: auto,
    h3-size: 11pt, h3-above: auto, h3-below: auto,
    h4-size: 11pt, h4-above: auto, h4-below: auto,
  ),
  journal: (
    // One gap between the complete entry heading/date block and the notes.
    header-below: 1.5em,
    running-gutter: 1em,
    running-leading: 0.35em,
  ),
  decorative: (
    header-size: 9pt,
    footer-size: 10pt,
    date-size: 10pt,
    keywords-size: 9pt,
    list-tight: false,
    list-spacing: 0.9em,
  ),
  page-footer: (
    format: "1",
    size: 10pt,
    weight: "regular",
  ),
  links: (
    color: rgb("#0563C1"),
    url-color: rgb("#0563C1"),
  ),
  tables: (
    stroke: 0.5pt,
    inset: (x: 8pt, y: 4pt),
    font-size: 10pt,
    caption-position: top,
    caption-gap: 6pt,
  ),
  callouts: (
    inset: 9pt,
    radius: 3pt,
    stroke: 0.8pt,
    title-below: 1em,
    paragraph-spacing: 1em,
    list-spacing: 1.2em,
  ),
  captions: (
    size: 10pt,
    weight: "regular",
    alignment: center,
    label-weight: "regular",
  ),
  toc: (
    // Set depth: 0 to disable. none includes all outlined heading levels.
    depth: none,
    // Title shown above the table of contents. Set to none to omit.
    title: [Table of Contents],
    // Indent per heading level (e.g. 1em for sub-sections)
    indent: auto,
    // Entry text size, spacing between rows, and extra space before each main section
    entry-size: 10pt,
    leading: 0.65em,
    entry-above: 0.65em,
    main-entry-above: 1.25em,
    // Space between the title and first entry; space after the ToC before body content
    title-below: 1.5em,
    below: 2em,
  ),
  lof: (
    // Set depth: 0 to disable. none = auto.
    depth: none,
    // Title shown above the list of figures. Set to none to omit.
    title: [List of Figures],
    // Indent per level
    indent: auto,
    entry-size: 10pt,
    leading: 0.65em,
    entry-above: 0.85em,
    title-below: 1.5em,
    // Spacing below the list
    below: 2em,
    // When true, LoF shows only "Figure N .... page", no caption text.
    // Set to true for long captions where the full text clutters the list.
    compact: false,
  ),
  lot: (
    depth: none,
    title: [List of Tables],
    indent: auto,
    entry-size: 10pt,
    leading: 0.65em,
    entry-above: 0.85em,
    title-below: 1.5em,
    below: 2em,
    // Same as lof.compact, but for tables.
    compact: false,
  ),
  bibliography: (
    style: "apa",
  ),
  colors: (
    bg-paper: white,
    bg-subtle: white,
    brand-primary: black,
    brand-accent: black,
    text-main: black,
    text-muted: black,
  ),
)

// Validate known shared namespaces while leaving template-specific and caller
// extension groups open. This catches common misspellings without making the
// generic merge helper or custom config metadata closed-world.
#let validate-config(config) = {
  assert(type(config) == dictionary, message: "Satz config must be a dictionary.")
  for (group, values) in config {
    if group in defaults {
      assert(type(values) == dictionary,
        message: "Satz config group `" + group + "` must be a dictionary.")
      let allowed = if group == "page" {
        (..defaults.page.keys(), "header-ascent")
      } else if group == "headings" {
        (..defaults.headings.keys(), "h1-number-size")
      } else if group == "decorative" {
        (..defaults.decorative.keys(), "list-indent", "list-body-indent", "list-block-spacing")
      } else {
        defaults.at(group).keys()
      }
      if group == "page" {
        allowed += ("inside", "outside", "x", "y")
      }
      for key in values.keys() {
        assert(key in allowed,
          message: "Unknown Satz config key `" + group + "." + key + "`. Check the configuration reference for supported keys.")
      }
    }
  }
  config
}

/// Merge two dicts — your overrides win.
///
/// It runs deep: nested dicts keep keys you didn't touch.
/// So `config: (colors: (brand-primary: blue))` only swaps that color.
///
/// - base (dictionary): the full defaults
/// - overrides (dictionary): what you pass in
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
