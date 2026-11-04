// Report template — thin wrapper around the unified satz class.

#import "../class.typ": document-class
#import "../defaults.typ": merge
#import "../themes.typ": theme-config
#import "defaults.typ": defaults as report-defaults

/// A report document class.
///
/// - body (content): your text
/// - config (dictionary): partial overrides, deep-merged over the defaults
///   below. Nested dictionaries merge and an explicit value wins. Shared known
///   groups validate their field names; value types are checked by the
///   consuming Typst setting. Extra top-level extension groups are allowed.
///   - `page.paper` (paper name/custom size; `"a4"`), `margin` (length or
///     edge-to-length dictionary; 2.5cm each; `top`, `bottom`, `left`,
///     `right`, `inside`, `outside`, `x`, `y`), `binding`
///     (`none`/`left`/`right`; `none`),
///     `binding-correction` (length; `0pt`), `headers` (bool; false),
///     `columns` (positive int; 1), `column-gutter` (length; 5mm): page layout.
///   - `typography.font` (font name; `"Libertinus Serif"`), `math-font` and
///     `mono-font` (name or `auto`; auto), `size` (length; 11pt), `line-spacing`
///     (positive baseline multiple or none; none), `leading` (length; 0.65em),
///     `paragraph-spacing` (length; 1.2em), `first-line-indent` (bool; false),
///     `hyphenate` (bool; false), `justify` (bool; true): body typography.
///     `line-spacing`, when set, determines baseline distance and overrides
///     `leading`; a true first-line indent is one em.
///   - `typography.list-spacing` (non-negative number; `0.5`): additional gap
///     between list items as a fraction of the calculated body baseline
///     distance. It follows `typography.line-spacing` when set, or font
///     metrics and `typography.leading` otherwise. Use `0` for no extra gap.
///   - `headings.numbering` (pattern/function or none; `"1.1"`), `hyphenate`
///     (bool; false), `h1-pagebreak` (bool; false), `spacing` (`"koma"` or
///     `"native"`; `"koma"`), `h1-size`–`h4-size` (lengths; 14pt, 12pt, 11pt,
///     11pt), and each level's `*-above`/`*-below` (length or auto; auto):
///     numbering, heading type, and gaps.
///   - `journal.header-below` (1.5em), `running-gutter` (1em),
///     `running-leading` (0.35em), `running-header-size` (9pt), `date-size`
///     (10pt), and `keywords-size` (9pt): journal furniture settings; report
///     does not use them.
///   - `decorative.header-size` (9pt), `footer-size` (10pt), `date-size` (10pt),
///     and `keywords-size` (9pt): shared text furniture settings.
///   - `page-footer.format` (numbering pattern/function; `"1"`), `size`
///     (length; 10pt), `weight` (font weight; `"regular"`): page number style.
///   - `line-numbers.enabled` (bool; false), `format` (pattern; `"1"`),
///     `scope` (`"document"`/`"page"`; `"document"`), `size` (8pt), `color`
///     (`#64748B`), `clearance` (length or auto; auto): optional draft line
///     numbering.
///   - `links.color` and `url-color` (colors; `#0563C1`): internal and URL links.
///   - `tables.stroke` (0.5pt), `inset` (length or x/y dictionary;
///     `(x: 8pt, y: 4pt)`), `font-size` (10pt), `caption-position` (top or
///     bottom; top), `caption-gap` (6pt): scientific table style.
///   - `callouts.inset` (9pt), `radius` (3pt), `stroke` (0.8pt),
///     `title-below` (1em), `paragraph-spacing` (1em), `list-spacing` (1.2em):
///     callout geometry and content gaps.
///   - `captions.size` (10pt), `weight` (regular), `alignment` (center),
///     `label-weight` (regular): caption appearance.
///   - `toc`, `lof`, `lot`: `depth` (none or non-negative int; none), `title`
///     (content or none; Table of Contents/List of Figures/List of Tables),
///     `indent` (length or auto; auto), `entry-size` (10pt), `leading` (0.65em),
///     `entry-above` (0.65em for toc, 0.85em for lof/lot), `title-below` (1.5em),
///     `below` (2em). TOC also has `main-entry-above` (1.25em); LoF/LoT have
///     `compact` (bool; false), which omits caption text. A depth of 0 disables
///     the report's automatic list; `none` includes all outlined levels.
///   - `bibliography.style` (CSL style; `"apa"`): bibliography formatting.
///   - `colors.bg-paper`, `bg-subtle`, `brand-primary`, `brand-accent`,
///     `text-main`, `text-muted` (colors; report neutral values are white
///     paper, black text/accent, and white subtle fill): backgrounds, text,
///     and accents.
///   Report actually consumes all page and typography fields; all heading
///   `page-footer.size` and `weight`; all line-number and link fields; table
///   `inset` and `font-size`; all caption and contents/list fields;
///   bibliography style; and `colors.bg-paper`, `brand-primary`, `text-main`,
///   and `text-muted`. It validates but does not consume `journal.*`, the
///   other decorative fields, `page-footer.format`, the other table fields,
///   `callouts.*`, or `colors.bg-subtle`/`brand-accent`; changing those in
///   `report` config alone has no effect on the report layout. Pass relevant
///   config directly to a component such as `callout` or `scientific-table`.
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
