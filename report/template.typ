// Report template — thin wrapper around the unified satz class.

#import "../class.typ": document-class
#import "../defaults.typ": merge
#import "../themes.typ": theme-config
#import "defaults.typ": defaults as report-defaults

/// A simple report — articles, protocols, lab notes, whatever.
///
/// It wraps `document-class(kind: "report")`. You get numbered headings,
/// a table of contents, and a bibliography out of the box.
/// Need binding correction for a thesis? Call `document-class(kind: "thesis")` instead.
///
/// - body (content): your text
/// - config (dictionary): tweak fonts, colors, margins ...
/// - theme (str, none): `neutral`, `soft-jade`, `soft-slate`, `warm-editorial`,
///   `plum`, or `soft-rose`; `none` preserves the legacy palette
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
