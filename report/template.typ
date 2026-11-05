// Report template — thin wrapper around the unified satz class.

#import "../class.typ": document-class
#import "../defaults.typ": merge
#import "../themes.typ": theme-config
#import "defaults.typ": defaults as report-defaults

/// A report document class.
///
/// - body (content): your text
/// - config (dictionary): partial nested appearance overrides, deep-merged with this
///   template’s defaults. The exported `defaults` dictionary documents every shared
///   key, its baseline value, accepted form, and meaning. Import the package as a
///   namespace (`#import "@preview/satz:0.2.0" as satz`) and hover `satz.defaults`
///   to inspect that shared config without copying it into every template docstring.
///   `report` overrides `figures.placement` to `auto` (set it to `none` to keep
///   figures in source order). Its consumed and validation-only fields are in the
///   [configuration reference](/satz/reference/configuration/).
/// - theme (str): palette applied before `config`, so explicit `config.colors`
///   values take precedence. Choices: `neutral` (default), `slate`, `soft-jade`,
///   `soft-slate`, `warm-editorial`, `plum`, `soft-rose`; `none` skips the
///   named palette.
///
/// ```example
/// #show: report.with(
///   theme: "neutral",
///   config: (
///     page: (paper: "a4", margin: (x: 2.5cm, y: 2.5cm)),
///     typography: (font: "Libertinus Serif", math-font: auto, size: 11pt),
///     headings: (h1-size: 14pt),
///     page-footer: (weight: "regular"),
///     links: (url-color: blue),
///     colors: (brand-primary: navy),
///   ),
/// )
/// = Introduction
/// #lorem(100)
/// ```
#let report(body, config: (:), theme: report-defaults.theme) = {
  let config = merge(report-defaults, config)
  document-class(kind: "report", config: theme-config(theme, config: config), body)
}
