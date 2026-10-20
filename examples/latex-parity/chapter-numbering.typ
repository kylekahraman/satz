#import "../../lib.typ": report, chapter-numbering, placeholder
#show: report.with(config: (
  toc: (depth: 0), lof: (depth: 0), lot: (depth: 0),
  headings: (h1-pagebreak: true),
  page: (paper: "a6", margin: 12mm),
))

#chapter-numbering(chapter: 1)[
  = First chapter
  Forward references: @second, @appendix-table and @second-equation.
  #figure(placeholder(height: 12mm), caption: [First chapter figure.]) <first>
]

#chapter-numbering(chapter: 2)[
  = Second chapter
  Backward reference: @first. Forward reference: @appendix-table.
  #figure(placeholder(height: 12mm), caption: [Second chapter figure.]) <second>
  $ x = y + 1 $ <second-equation>
]

#chapter-numbering(chapter: 1, appendix: true)[
  #set heading(numbering: "A")
  #counter(heading).update(0)
  = Appendix material
  References retain their original chapters: @first, @second, @second-equation.
  #figure(table(columns: 2, [Measure], [Value]), kind: table, caption: [Appendix table.]) <appendix-table>
]
