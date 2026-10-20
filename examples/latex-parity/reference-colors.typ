#import "../../lib.typ": report, placeholder
#show: report.with(config: (
  toc: (depth: 0), lof: (depth: 0), lot: (depth: 0),
  links: (color: blue),
  page: (paper: "a5", margin: 15mm),
))

= Cross-references <section>
Internal references use the configured color: @section and @result.
Bibliographic citations retain their separate year styling: @thery2018.

#figure(placeholder(height: 20mm), caption: [A referenced figure.]) <result>

#bibliography("../../report/refs.bib")
