#import "cover.typ": cover-themes
#import "defaults.typ": merge

/// Built-in document-page palettes, keyed by palette name.
///
/// Available names are `neutral`, `slate`, `soft-jade`, `soft-slate`,
/// `warm-editorial`, `plum`, and `soft-rose`. Each value is a color dictionary
/// with `bg-paper`, `bg-subtle`, `brand-primary`, `brand-accent`, `text-main`,
/// and `text-muted`. Neutral keeps document pages white with black text;
/// `text-muted` is black there rather than gray. `slate` preserves Satz's
/// former dark blue-gray base palette. `theme-config()` also supplies links:
/// neutral uses blue, slate keeps its former burgundy/blue-gray colors, and
/// other themes use their primary color. List names with
/// `document-themes.keys()`. Use `theme-config(name)` to apply one.
#let document-themes = cover-themes.pairs().map(((name, colors)) => (
  name,
  if name == "neutral" {
    (
      bg-paper: white,
      bg-subtle: white,
      brand-primary: black,
      brand-accent: black,
      text-main: black,
      text-muted: black,
    )
  } else if name == "slate" {
    (: ..colors, bg-subtle: rgb("#f1f5f9"))
  } else {
    (: ..colors, bg-paper: white, bg-subtle: colors.brand-primary.lighten(94%))
  },
)).to-dict()

/// Select a document palette for any Satz template accepting `config`.
///
/// This returns a document palette, not a cover palette. A cover keeps its own
/// tinted paper unless its `config` explicitly overrides `colors.bg-paper`.
///
/// ```typst
/// #let config = theme-config("soft-jade", config: (typography: (size: 11pt)))
/// ```
///
/// - name (str, none): one of `neutral`, `slate`, `soft-jade`, `soft-slate`,
///   `warm-editorial`, `plum`, or `soft-rose`; `none` returns `config` unchanged
/// - config (dictionary): nested overrides applied after the palette, so they
///   win on matching keys. For example,
///   `theme-config("soft-jade", config: (typography: (font: "STIX Two Text"),
///   colors: (brand-primary: blue)))`. Theme colors replace the default
///   document colors. Non-color keys and groups in `config` pass through
///   unchanged; this function does not validate or alter them.
///
/// Neutral adds blue links (`#0563C1`); other themes match links to their
/// primary color. Unknown names fail with the list location.
///
/// Complete shared baseline config schema. The function-specific effects
/// and defaults are stated above; all shared fields are listed here for
/// reference within this function documentation.
/// **Page (`page`)**
/// - `paper` (paper name or custom size; `"a4"`): page format.
/// - `margin` (dictionary of edge lengths; 2.5cm on every edge): page margins.
///   Use `top`, `bottom`, `left`, and `right`; two-sided layouts may instead
///   derive inside/outside margins. `x` and `y` are shorthand for horizontal
///   and vertical margins.
/// - `binding` (`none`, `left`, or `right`; `none`): enables two-sided layout
///   and selects the binding edge where supported.
/// - `binding-correction` (length; `0pt`): extra space at the binding edge.
/// - `headers` (bool; `false`): enables the template's running header where
///   implemented.
/// - `columns` (positive integer; `1`): number of text columns where supported.
/// - `column-gutter` (length; `5mm`): gap between columns.
///
/// **Typography (`typography`)**
/// - `font` (font name; `"Libertinus Serif"`): body text typeface.
/// - `math-font` (font name or `auto`; `auto`): math typeface. `auto` leaves
///   math font selection to Typst.
/// - `mono-font` (font name or `auto`; `auto`): monospace typeface. `auto`
///   leaves raw text in Typst's native style.
/// - `size` (length; `11pt`): body text size.
/// - `line-spacing` (positive number or `none`; `none`): optional baseline to
///   baseline distance as a multiple of body size, for example `1.25`. Satz
///   uses the selected font's metrics to calculate leading. When set, it
///   overrides `leading`.
/// - `leading` (length; `0.65em`): Typst's gap between adjacent line boxes.
///   This is a direct length, not a baseline-distance multiplier.
/// - `list-spacing` (non-negative number; `0.5`): additional gap between list
///   items as a fraction of the calculated body baseline distance. It follows
///   `line-spacing` when set, or font metrics and `leading` otherwise; `0`
///   adds no extra gap. `theme-config` passes this setting through unchanged.
/// - `paragraph-spacing` (length; `1.2em`): vertical gap between paragraphs.
/// - `first-line-indent` (bool; `false`): whether to indent the first line of
///   every paragraph. `true` uses one em (the current body font size, so 11pt
///   at an 11pt text size), including the first paragraph in a
///   document/container and paragraphs immediately after blocks such as
///   headings; `false` uses no indent. This horizontal measure is independent
///   of vertical `line-spacing` and `paragraph-spacing` and does not change
///   either setting.
/// - `hyphenate` (bool; `false`): automatic word hyphenation in body text.
/// - `justify` (bool; `true`): justify body paragraphs where supported.
///
/// **Headings (`headings`)**
/// - `numbering` (Typst numbering pattern/function or `none`; `"1.1"`):
///   numbering for native headings.
/// - `hyphenate` (bool; `false`): allow line breaks by hyphenation in headings.
/// - `h1-pagebreak` (bool; `false`): start level-one headings on a new page
///   where supported.
/// - `spacing` (`"koma"` or `"native"`; `"koma"`): `"koma"` derives heading
///   gaps from KOMA-style baseline skips and font metrics; `"native"` keeps
///   Typst's native spacing policy.
/// - `h1-size` … `h4-size` (lengths; `14pt`, `12pt`, `11pt`, `11pt`): text size
///   for heading levels one through four.
/// - `h1-above` … `h4-above` (`auto` or length; `auto`): gap before each level.
///   `auto` follows the selected spacing policy.
/// - `h1-below` … `h4-below` (`auto` or length; `auto`): gap after each level.
///   An explicit length overrides the template's automatic value.
///
/// **Journal (`journal`)**
/// - `header-below` (length; `1.5em`): gap after the full entry heading/date
///   block and before the notes.
/// - `running-gutter` (length; `1em`): gap between columns in a running header.
/// - `running-leading` (length; `0.35em`): line gap in a multi-line running
///   header.
/// - `running-header-size` (length; `9pt`): journal running-header text size.
/// - `date-size` (length; `10pt`): journal date text size.
/// - `keywords-size` (length; `9pt`): journal keyword text size.
///
/// **Decorative text and lists (`decorative`)**
/// - `header-size` (length; `9pt`): running-header text size.
/// - `footer-size` (length; `10pt`): footer text size where implemented.
/// - `date-size` (length; `10pt`): date text size where implemented.
/// - `keywords-size` (length; `9pt`): keyword text size where implemented.
///
/// **Page number (`page-footer`)**
/// - `format` (Typst numbering pattern/function; `"1"`): page-number format.
/// - `size` (length; `10pt`): page-number text size.
/// - `weight` (Typst font weight; `"regular"`): page-number text weight.
///
/// **Line numbers (`line-numbers`)**
/// - `enabled` (bool; `false`): show line numbers in templates that support
///   draft line numbering.
/// - `format` (Typst numbering pattern; `"1"`): line-number format.
/// - `scope` (`"document"` or `"page"`; `"document"`): keep numbering
///   continuous across pages or restart on each page.
/// - `size` (length; `8pt`): line-number text size.
/// - `color` (color; `#64748B`): line-number color.
/// - `clearance` (`auto` or length; `auto`): gap between numbers and body text.
///
/// **Links (`links`)**
/// - `color` (color; `#0563C1`): color of internal references.
/// - `url-color` (color; `#0563C1`): color of external URLs.
///
/// **Tables (`tables`)**
/// - `stroke` (length; `0.5pt`): default rule thickness for shared table
///   helpers.
/// - `inset` (length or dictionary; `(x: 8pt, y: 4pt)`): cell padding. A
///   dictionary can set horizontal and vertical padding independently.
/// - `font-size` (length; `10pt`): text size in shared styled tables.
/// - `caption-position` (`top` or `bottom`; `top`): caption location in the
///   scientific-table show rule.
/// - `caption-gap` (length; `6pt`): space between a table caption and table.
///
/// **Callouts (`callouts`)**
/// - `inset` (length; `9pt`): inner padding.
/// - `radius` (length; `3pt`): corner radius.
/// - `stroke` (length; `0.8pt`): border thickness.
/// - `title-below` (length; `1em`): gap below a callout title.
/// - `paragraph-spacing` (length; `1em`): gap between callout paragraphs.
/// - `list-spacing` (length; `1.2em`): gap between callout list items.
///
/// **Captions (`captions`)**
/// - `size` (length; `10pt`): caption text size.
/// - `weight` (Typst font weight; `"regular"`): caption text weight.
/// - `alignment` (Typst alignment; `center`): caption alignment.
/// - `label-weight` (Typst font weight; `"regular"`): weight of the caption
///   label, independently of the rest of the caption.
///
/// **Contents (`toc`)**
/// - `depth` (`none` or non-negative integer; `none`): included heading depth.
///   In report/thesis documents, `0` disables the automatic contents.
/// - `title` (content or `none`; `[Table of Contents]`): title above the list;
///   `none` omits it.
/// - `indent` (`auto` or length; `auto`): indentation of nested entries.
/// - `entry-size` (length; `10pt`): entry text size.
/// - `leading` (length; `0.65em`): line gap in wrapped entries.
/// - `entry-above` (length; `0.65em`): gap between ordinary entries.
/// - `main-entry-above` (length; `1.25em`): extra gap before main-section
///   entries.
/// - `title-below` (length; `1.5em`): gap between title and first entry.
/// - `below` (length; `2em`): gap after the contents.
///
/// **List of Figures (`lof`) and List of Tables (`lot`)**
/// Both groups use the same fields and meanings as `toc`, with these defaults:
/// `depth: none` (automatic depth), `title: [List of Figures]` or
/// `[List of Tables]`, `indent: auto`, `entry-size: 10pt`, `leading: 0.65em`,
/// `entry-above: 0.85em`, `title-below: 1.5em`, and `below: 2em`.
/// - `compact` (bool; `false`): when true, show only the figure/table label
///   and page number, omitting caption text.
///
/// **Bibliography (`bibliography`)**
/// - `style` (CSL style name; `"apa"`): citation style where bibliography
///   support is enabled.
///
/// **Colors (`colors`)**
/// - `bg-paper` (color; `white`): page or paper background.
/// - `bg-subtle` (color; `white`): subtle surface/background color.
/// - `brand-primary` (color; `black`): primary brand and heading accent.
/// - `brand-accent` (color; `black`): secondary accent.
/// - `text-main` (color; `black`): primary body text.
/// - `text-muted` (color; `black`): secondary or muted text.
///
#let theme-config(name, config: (:)) = {
  if name == none { return config }
  let colors = document-themes.at(name, default: none)
  assert(colors != none, message: "Unknown document theme: " + repr(name) + ". See document-themes for available palettes.")
  let links = if name == "neutral" {
    (color: rgb("#0563C1"), url-color: rgb("#0563C1"))
  } else if name == "slate" {
    (color: rgb("#B4313F"), url-color: rgb("#45556c"))
  } else {
    (color: colors.brand-primary, url-color: colors.brand-primary)
  }
  merge((
    colors: colors,
    links: links,
  ), config)
}
