#import "../../tables.typ": scientific-table, scientific-tables
#set page(paper: "a6", margin: 12mm, numbering: "1")
#set text(font: "Libertinus Serif", size: 11pt)
#show: scientific-tables.with(breakable: true)

#figure([
  #scientific-table(columns: (1fr, auto), header: ([Measure], [Estimate]),
    [Baseline], [0.12], [Treatment], [0.38])
  #scientific-table(columns: (1fr, auto), header: ([Measure], [SEM]),
    [Baseline], [0.03], [Treatment], [0.05])
], kind: table, caption: [Two related tables with one caption and reference.]) <group>

#figure(
  scientific-table(columns: (1fr, auto), header: ([Observation], [Value]),
    ..range(40).map(i => ([Observation #i], [#i.25])).flatten()),
  kind: table,
  caption: [A long table with repeated headings and boundary rules.],
) <long>

See @group and @long.
#context assert(query(figure.where(kind: table)).len() == 2)
