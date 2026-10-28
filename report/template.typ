// Report template — thin wrapper around the unified satz class.

#import "../class.typ": document-class
#import "../defaults.typ": merge
#import "../themes.typ": theme-config
#import "defaults.typ": defaults as report-defaults

/// A report document class.
///
/// - body (content): your text
/// - config (dictionary): partial overrides, deep-merged over the shared
///   defaults. The report defaults to A4, 2.5cm margins, Libertinus Serif at
///   11pt, automatic Typst math and monospace fonts, numbered headings, and a
///   black-on-white palette. Set `typography.math-font` to a font name to
///   override Typst's default math font.
///
///   Supported shared settings:
///   - `page`: `paper`, `margin` (`top`, `bottom`, `left`, `right`, or `x`/`y`),
///     `binding`, `binding-correction`, `headers`, `columns`, `column-gutter`.
///   - `typography`: `font`, `math-font`, `mono-font`, `size`, `line-spacing`,
///     `leading`, `paragraph-spacing`, `first-line-indent`, `hyphenate`, `justify`.
///   - `headings`: `numbering`, `hyphenate`, `h1-pagebreak`, `spacing`, and
///     `h1-size`/`h1-above`/`h1-below` through the corresponding `h4` settings.
///   - `decorative`: `header-size`, `footer-size`, `date-size`, `keywords-size`,
///     `list-tight`, `list-spacing`.
///   - `page-footer`: `format`, `size`, `weight`.
///   - `line-numbers`: `enabled`, `format`, `scope`, `size`, `color`, `clearance`.
///   - `links`: `color`, `url-color`.
///   - `tables`: `stroke`, `inset`, `font-size`, `caption-position`, `caption-gap`.
///   - `callouts`: `inset`, `radius`, `stroke`, `title-below`,
///     `paragraph-spacing`, `list-spacing`.
///   - `captions`: `size`, `weight`, `alignment`, `label-weight`.
///   - `toc`, `lof`, `lot`: `depth`, `title`, `indent`, `entry-size`, `leading`,
///     `entry-above`, `title-below`, `below`; `toc` also has `main-entry-above`,
///     and `lof`/`lot` also have `compact`.
///   - `bibliography`: `style`.
///   - `colors`: `bg-paper`, `bg-subtle`, `brand-primary`, `brand-accent`,
///     `text-main`, `text-muted`.
///
///   `journal` (`header-below`, `running-gutter`, `running-leading`) is accepted
///   by the shared config but only affects journal templates. Other templates
///   can add their own config groups.
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
  document-class(kind: "report", config: theme-config(theme, config: config), body)
}
