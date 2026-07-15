// Report template — thin wrapper around the unified satz class.

#import "../class.typ": personal

/// A general-purpose report document class (articles, protocols, thesis).
///
/// Thin wrapper around `personal(kind: "report")`. Supports full config
/// customization via the `config` dictionary (fonts, colors, margins, etc.).
/// Includes numbered headings, auto-generated Table of Contents,
/// bibliography support, and link styling.
///
/// For thesis/dissertation, use `personal(kind: "thesis")` directly for
/// features like binding correction (BCOR) and chapter-based page numbering.
///
/// - body (content): Document body
/// - config (dictionary): Overrides for satz defaults
///
/// ```example
/// #show: report.with(
///   config: (typography: (font: "EB Garamond"), colors: (brand-primary: blue))
/// )
///
/// = Introduction
/// #lorem(100)
/// ```
#let report(body, config: (:)) = {
  personal(kind: "report", config: config, body)
}
