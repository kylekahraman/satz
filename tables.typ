#import "defaults.typ": defaults, merge

/// Scientific table with repeated column headings and booktabs-style rules.
///
/// ```example
/// #scientific-table(
///   columns: 2,
///   header: ([Method], [Score]),
///   [Baseline], [0.71],
///   [Proposed], [0.84],
/// )
/// ```
///
/// - columns (positive int): number of columns; must match the supplied cells
/// - header (array): non-empty array of header cells, one per column
/// - config (dictionary): nested overrides merged over Satz's shared defaults.
///   Omitted values retain the defaults listed here. `merge` does not validate
///   keys or values; unknown entries are retained but ignored by this helper.
///   Full shared schema (keys are nested in their named group):
///   - `page`: `paper` (paper name/custom size; `"a4"`), `margin` (length or
///     edge dictionary; 2.5cm; edges `top`/`bottom`/`left`/`right` plus
///     `inside`/`outside`/`x`/`y`), `binding` (none/left/right; none),
///     `binding-correction` (length; 0pt), `headers` (bool; false), `columns`
///     (positive int; 1), `column-gutter` (length; 5mm). DFG-only
///     `header-ascent` is a length; its DFG default is 24.442pt.
///   - `typography`: `font` (name; Libertinus Serif), `math-font`/`mono-font`
///     (name or auto; auto), `size` (11pt), `line-spacing` (positive baseline
///     multiple or none; none), `leading` (0.65em), `paragraph-spacing` (1.2em),
///     `first-line-indent` (bool; false), `hyphenate` (bool; false), `justify`
///     (bool; true). A set line-spacing overrides leading; indentation uses one
///     em when enabled.
///   - `typography.list-spacing` (non-negative number; `0.5`): additional gap
///     between document list items as a fraction of calculated body baseline
///     distance. It follows `typography.line-spacing` when set, or font
///     metrics and `typography.leading` otherwise; `0` adds no extra gap.
///     Table helpers do not render document lists, so this field has no effect
///     on them.
///   - `headings`: `numbering` (pattern/function/none; `"1.1"`), `hyphenate`
///     (bool; false), `h1-pagebreak` (bool; false), `spacing` (koma/native;
///     koma), `h1-size`–`h4-size` (14pt/12pt/11pt/11pt), per-level `*-above`/
///     `*-below` (length/auto; auto). Book-only `h1-number-size` is a length
///     with a 25pt book default.
///   - `journal`: `header-below` (1.5em), `running-gutter` (1em),
///     `running-leading` (0.35em), all lengths.
///   - `decorative`: `header-size` (9pt), `footer-size` (10pt), `date-size` (10pt),
///     `keywords-size` (9pt), plus DFG-only `list-indent` (17.9669pt),
///     `list-body-indent` (5.475 × 72 ÷ 72.27pt), and `list-block-spacing`
///     (measured baseline + paragraph skip - cap height + 3 × 72 ÷ 72.27pt).
///     `list-body-indent` (5.475 × 72 ÷ 72.27pt), and `list-block-spacing`
///     (measured baseline + paragraph skip - cap height + 3 × 72 ÷ 72.27pt)
///     are lengths.
///   - `page-footer`: `format` (numbering pattern/function; `"1"`), `size`
///     (10pt), `weight` (regular font weight).
///   - `line-numbers`: `enabled` (bool; false), `format` (pattern; `"1"`),
///     `scope` (document/page; document), `size` (8pt), `color` (`#64748B`),
///     `clearance` (length/auto; auto).
///   - `links`: `color` and `url-color` (colors; `#0563C1`).
///   - `tables`: `stroke` (0.5pt), `inset` (length or x/y dictionary;
///     `(x: 8pt, y: 4pt)`), `font-size` (10pt), `caption-position` (top/bottom;
///     top), `caption-gap` (6pt).
///   - `callouts`: `inset` (9pt), `radius` (3pt), `stroke` (0.8pt),
///     `title-below` (1em), `paragraph-spacing` (1em), `list-spacing` (1.2em).
///   - `captions`: `size` (10pt), `weight`/`label-weight` (regular),
///     `alignment` (left), `hanging` (true).
///   - `toc`, `lof`, `lot`: `depth` (none/non-negative int; none), `title`
///     (content/none; `[Table of Contents]`, `[List of Figures]`, or
///     `[List of Tables]`), `indent` (length/auto; auto),
///     `entry-size` (10pt), `leading` (0.65em), `entry-above` (0.65em for toc,
///     0.85em for lof/lot), `title-below` (1.5em), `below` (2em). TOC also has
///     `main-entry-above` (1.25em); LoF/LoT have `compact` (bool; false).
///   - `bibliography.style` (CSL style name; `"apa"`).
///   - `colors`: `bg-paper`, `bg-subtle`, `brand-primary`, `brand-accent`,
///     `text-main`, `text-muted` (colors; shared defaults white, white, black,
///     black, black, black).
///   Only `tables.stroke` (outer rules are 1.6 times this width, inner rule
///   uses it), `tables.inset` (cell padding), and `tables.font-size` (cell text)
///   affect this helper. DFG/book extension keys and other top-level extension
///   groups are also accepted by this unvalidated merge but ignored.
///   Example: `config: (tables: (stroke: 0.7pt, font-size: 9pt, inset: (x: 5pt, y: 3pt)))`.
/// - ..args: body cells positionally, plus native `table` arguments. Use
///   `table.hline()` among the cells for deliberate group separators.
///
/// Inside a multi-page figure, also make the enclosing figure block breakable.
#let scientific-table(columns: 1, header: (), config: (:), ..args) = {
  assert(type(columns) == int and columns > 0,
    message: "scientific-table columns must be a positive integer")
  assert(type(header) == array and header.len() > 0,
    message: "scientific-table needs header cells")
  let c = merge(defaults, config)
  set par(justify: false)
  set text(hyphenate: false)
  show table: set text(size: c.tables.font-size)
  show table.cell.where(y: 0): strong
  let options = (stroke: none, inset: c.tables.inset, align: left) + args.named()
  table(
    columns: columns,
    ..options,
    table.header(
      table.hline(stroke: 1.6 * c.tables.stroke),
      ..header,
      table.hline(stroke: c.tables.stroke),
    ),
    ..args.pos(),
    table.footer(table.hline(stroke: 1.6 * c.tables.stroke)),
  )
}

/// Apply scientific table-figure layout with a document-level show rule.
///
/// Native figures and their labels retain numbering, references, and outlines.
///
/// ```example
/// #show: scientific-tables.with(breakable: true)
/// #figure(table(...), caption: [Long table]) <tab:long>
/// ```
///
/// - body (content): the document section whose table figures should be styled
/// - breakable (bool): allow table figures to continue across pages; defaults
///   to false
/// - config (dictionary): nested overrides merged over Satz's shared defaults.
///   Omitted values retain the defaults listed here. `merge` does not validate
///   keys or values; unknown entries are retained but ignored by this rule.
///   Full shared schema (keys are nested in their named group):
///   - `page`: `paper` (paper name/custom size; `"a4"`), `margin` (length or
///     edge dictionary; 2.5cm; edges `top`/`bottom`/`left`/`right` plus
///     `inside`/`outside`/`x`/`y`), `binding` (none/left/right; none),
///     `binding-correction` (length; 0pt), `headers` (bool; false), `columns`
///     (positive int; 1), `column-gutter` (length; 5mm). DFG-only
///     `header-ascent` is a length; its DFG default is 24.442pt.
///   - `typography`: `font` (name; Libertinus Serif), `math-font`/`mono-font`
///     (name or auto; auto), `size` (11pt), `line-spacing` (positive baseline
///     multiple or none; none), `leading` (0.65em), `paragraph-spacing` (1.2em),
///     `first-line-indent` (bool; false), `hyphenate` (bool; false), `justify`
///     (bool; true). A set line-spacing overrides leading; indentation uses one
///     em when enabled.
///   - `typography.list-spacing` (non-negative number; `0.5`): additional gap
///     between list items as a fraction of the calculated body baseline
///     distance. It follows `typography.line-spacing` when set, or font
///     metrics and `typography.leading` otherwise. Use `0` for no extra gap.
///   - `headings`: `numbering` (pattern/function/none; `"1.1"`), `hyphenate`
///     (bool; false), `h1-pagebreak` (bool; false), `spacing` (koma/native;
///     koma), `h1-size`–`h4-size` (14pt/12pt/11pt/11pt), per-level `*-above`/
///     `*-below` (length/auto; auto). Book-only `h1-number-size` is a length
///     with a 25pt book default.
///   - `journal`: `header-below` (1.5em), `running-gutter` (1em),
///     `running-leading` (0.35em), all lengths.
///   - `decorative`: `header-size` (9pt), `footer-size` (10pt), `date-size`
///     `list-body-indent` (5.475 × 72 ÷ 72.27pt), and `list-block-spacing`
///     (measured baseline + paragraph skip - cap height + 3 × 72 ÷ 72.27pt)
///     are lengths.
///   - `page-footer`: `format` (numbering pattern/function; `"1"`), `size`
///     (10pt), `weight` (regular font weight).
///   - `line-numbers`: `enabled` (bool; false), `format` (pattern; `"1"`),
///     `scope` (document/page; document), `size` (8pt), `color` (`#64748B`),
///     `clearance` (length/auto; auto).
///   - `links`: `color` and `url-color` (colors; `#0563C1`).
///   - `tables`: `stroke` (0.5pt), `inset` (length or x/y dictionary;
///     `(x: 8pt, y: 4pt)`), `font-size` (10pt), `caption-position` (top/bottom;
///     top), `caption-gap` (6pt).
///   - `callouts`: `inset` (9pt), `radius` (3pt), `stroke` (0.8pt),
///     `title-below` (1em), `paragraph-spacing` (1em), `list-spacing` (1.2em).
///   - `captions`: `size` (10pt), `weight`/`label-weight` (regular),
///     `alignment` (left), `hanging` (true).
///   - `toc`, `lof`, `lot`: `depth` (none/non-negative int; none), `title`
///     (content/none; `[Table of Contents]`, `[List of Figures]`, or
///     `[List of Tables]`), `indent` (length/auto; auto),
///     `entry-size` (10pt), `leading` (0.65em), `entry-above` (0.65em for toc,
///     0.85em for lof/lot), `title-below` (1.5em), `below` (2em). TOC also has
///     `main-entry-above` (1.25em); LoF/LoT have `compact` (bool; false).
///   - `bibliography.style` (CSL style name; `"apa"`).
///   - `colors`: `bg-paper`, `bg-subtle`, `brand-primary`, `brand-accent`,
///     `text-main`, `text-muted` (colors; shared defaults white, white, black,
///     black, black, black).
///   This rule consumes `tables.caption-gap` (6pt) for table-caption spacing,
///   `tables.caption-position` (top) for placement, and `captions.size` (10pt)
///   for caption text size. Other listed fields, DFG/book extension keys, and
///   other top-level extension groups are accepted by this unvalidated merge
///   but ignored.
///   `breakable` independently allows matching table figures to span pages.
///   Example: `config: (tables: (caption-gap: 8pt, caption-position: bottom), captions: (size: 9pt))`.
#let scientific-tables(body, breakable: false, config: (:)) = {
  let c = merge(defaults, config)
  // Setting block(width: 100%) here would leak into cell blocks and make
  // auto columns consume the available width before fr columns are sized.
  show figure.where(kind: table): set block(breakable: breakable)
  show figure.where(kind: table): set figure(gap: c.tables.caption-gap)
  show figure.where(kind: table): set figure.caption(position: c.tables.caption-position)
  show figure.caption.where(kind: table): set align(left)
  show figure.caption.where(kind: table): set par(justify: false)
  show figure.caption.where(kind: table): set text(size: c.captions.size)
  body
}
