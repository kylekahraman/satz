// DFG 53.01, revision 09/26. Geometry measured from the official RTF.
#let defaults = (
  toc: (depth: 0), lof: (depth: 0), lot: (depth: 0),
  page: (paper: "a4", margin: (left: 25mm, right: 20mm, top: 25mm, bottom: 15mm)),
  // Inherit Satz leading, paragraph/list spacing and heading gaps.
  // DFG constrains font/size, not the old compressed 0.1em heading gap.
  typography: (font: "Arial", size: 11pt),
  headings: (
    numbering: "1.1.1.1",
    h1-size: 11pt,
    h2-size: 11pt,
    h3-size: 11pt,
    h4-size: 11pt,
  ),
  decorative: (header-size: 8pt),
  colors: (bg-paper: white, text-main: black, brand-primary: black),
  links: (color: black, url-color: black),
  tables: (font-size: 11pt),
  captions: (size: 11pt, alignment: left),
  bibliography: (style: "apa"),
)
