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
/// - columns (int): number of columns; must match the supplied cells
/// - header (array): non-empty array of header cells, one per column
/// - config (dictionary): `tables.*` overrides. Defaults are 0.5pt rules,
///   `(x: 8pt, y: 4pt)` cell inset, and 10pt text; for example,
///   `config: (tables: (font-size: 9pt, inset: (x: 5pt, y: 3pt)))`.
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
/// - config (dictionary): `tables.*` and `captions.*` overrides. For example,
///   `config: (tables: (caption-gap: 8pt), captions: (size: 9pt))`.
///   See `defaults.typ` for all shared table and caption defaults.
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
