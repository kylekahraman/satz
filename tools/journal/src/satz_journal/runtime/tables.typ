#import "defaults.typ": defaults, merge

/// Scientific table with repeated column headings and booktabs-style rules.
/// Pass header cells as an array; all remaining arguments go to native table.
/// Add table.hline() among body cells for deliberate group separators.
/// Inside a multi-page figure, also make the enclosing figure block breakable.
#let scientific-table(columns: 1, header: (), config: (:), ..args) = {
  assert(header.len() > 0, message: "scientific-table needs header cells")
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
/// Native figures and their labels retain numbering, references and outlines.
/// Set breakable: true only when table figures should continue across pages.
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
