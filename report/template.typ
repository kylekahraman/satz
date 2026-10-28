// Report template — thin wrapper around the unified satz class.

#import "../class.typ": document-class
#import "../defaults.typ": merge
#import "../themes.typ": theme-config
#import "defaults.typ": defaults as report-defaults

/// A simple report — protocols, lab notes, analyses, and similar documents.
///
/// You get numbered headings, a table of contents, and a pre-styled
/// bibliography. Call `#bibliography("refs.bib")` yourself where it belongs.
/// Need binding correction for a thesis? Use `custom(kind: "thesis", ...)`
/// instead.
///
/// - body (content): your text
/// - config (dictionary): shared settings, deep-merged over the defaults.
///   Common choices are `page: (paper: "a4", columns: 1)` and
///   `typography: (font: "Libertinus Serif", math-font: auto, size: 11pt)`;
///   `math-font: auto` keeps Typst's native math font selection, New Computer
///   Modern Math (embedded in the Typst CLI). You can also
///   set `headings`, `toc`, `lof`, `lot`, `bibliography`, `links`, `tables`,
///   and `colors`. Shared defaults and every key are listed in `defaults.typ`.
/// - theme (str, none): `neutral` (default), `slate`, `soft-jade`, `soft-slate`, `warm-editorial`,
///   `plum`, or `soft-rose`; `none` preserves the template palette
///
/// ```example
/// #show: report.with(
///   config: (typography: (font: "EB Garamond"), colors: (brand-primary: blue))
/// )
/// = Introduction
/// #lorem(100)
/// ```
#let report(body, config: (:), theme: report-defaults.theme) = {
  document-class(kind: "report", config: theme-config(theme, config: config), body)
}
