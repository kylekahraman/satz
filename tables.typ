#import "defaults.typ": defaults, merge

/// Scientific table with repeated column headings and booktabs-style rules.
/// Pass header cells as an array; all remaining arguments go to native table.
/// Add table.hline() among body cells for deliberate group separators.
/// Inside a multi-page figure, also make the enclosing figure block breakable.
#let scientific-table(columns: 1, header: (), config: (:), ..args) = {
  assert(header.len() > 0, message: "scientific-table needs header cells")
  let c = merge(defaults, config)
  show table: set text(size: c.tables.font-size)
  show table.cell.where(y: 0): strong
  let options = (stroke: none, inset: c.tables.inset) + args.named()
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
