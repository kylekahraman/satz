#import "../../lib.typ": report, placeholder, satz-figure, scientific-tables
#show: report.with(config: (
  toc: (depth: 0), lof: (compact: false), lot: (depth: 0),
  page: (paper: "a6", margin: 12mm),
  captions: (alignment: left, label-weight: "bold"),
))
#show: scientific-tables

= Caption styles
#figure(placeholder(height: 18mm), caption: [An ordinary caption whose text is left aligned, with a bold label.]) <ordinary>
#satz-figure(placeholder(height: 18mm), caption: [The long caption printed with the figure, including details omitted from the list.], short-caption: [Short list entry.]) <short>
#figure(table(columns: (1fr, auto), [Measure], [Value]), kind: table, caption: [A top table caption.]) <table>
#figure(placeholder(height: 8mm), numbering: none, caption: [An unnumbered caption.])
References remain native: @ordinary, @short and @table.
