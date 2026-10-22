// Report template — thin wrapper around the unified satz class.

#import "../class.typ": personal
#import "../defaults.typ": merge
#import "../themes.typ": document-themes
#import "defaults.typ": defaults as report-defaults

/// A simple report — articles, protocols, lab notes, whatever.
///
/// It wraps `personal(kind: "report")`. You get numbered headings,
/// a table of contents, and a bibliography out of the box.
/// Need binding correction for a thesis? Call `personal(kind: "thesis")` instead.
///
/// - body (content): your text
/// - config (dictionary): tweak fonts, colors, margins ...
/// - theme (str, none): named document palette; none preserves the legacy palette
///
/// ```example
/// #show: report.with(
///   config: (typography: (font: "EB Garamond"), colors: (brand-primary: blue))
/// )
/// = Introduction
/// #lorem(100)
/// ```
#let report(body, config: (:), theme: report-defaults.theme) = {
  let themed = if theme == none { (:) } else {
    let colors = document-themes.at(theme)
    (
      colors: colors,
      links: (color: colors.brand-primary, url-color: colors.brand-primary),
    )
  }
  personal(kind: "report", config: merge(themed, config), body)
}
