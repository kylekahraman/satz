// Typst adaptation of scrlayer-notecolumn-example.tex.
// Original Copyright (c) Markus Kohm, 2013-2017, LPPL 1.3c.
// Derived work maintained by the satz contributors, 2026, under LPPL 1.3c.
// See LPPL-1.3c.txt and README.md for original source and changes.

#import "../../lib.typ": report

#show: report.with(config: (
  page: (margin: (left: 31.5mm, right: 31.5mm, top: 45mm, bottom: 32mm)),
  typography: (font: "New Computer Modern", size: 11pt, leading: 6pt, hyphenate: true),
  headings: (h1-size: 14pt),
  toc: (depth: 0),
  colors: (bg-paper: white, text-main: black, brand-primary: black),
))

// Workarounds: report supplies a separate front-matter TOC and assumes a page
// offset. An article needs an inline TOC and page numbering starting at one.
#set text(lang: "de")
#set page(numbering: "1", footer: auto)
#set par(spacing: 0pt, first-line-indent: 1em)
#show heading: set text(font: "Libertinus Sans")

// Workaround: no public inline article title/author block yet.
#align(center)[
  #text(font: "Libertinus Sans", size: 20.7pt, weight: "bold")[Kommentar zum GüdaVaS]
  #v(2em)
  #text(size: 14.3pt)[Professor R. O. Tenase]
  #v(1.4em)
  #text(size: 14.3pt, "11. 11. 2011")
]
#v(1em)
#outline(title: [Inhaltsverzeichnis], depth: 1, indent: 0pt)
#v(0.5em)

= Vormerkung

Das GüdaVaS ist ohne jeden Zweifel das wichtigste Gesetz, das in
Spaßmaniern in den letzten eintausend Jahren verabschiedet wurde.
Die erste Lesung fand bereits am 11. 11 1111 im obersten
spaßmanischen Kongress statt, wurde aber vom damalige Spaßvesier
abgelehnt. Erst nach Umwandlung der spaßmanischen, aberwitzigen Monarchie
in eine repräsentative, witzige Monarchie durch W. Itzbold, den
urkomischen, am 9. 9. 1999 war der Weg für dieses Gesetz endlich frei.

= Analyse

// Workaround: these are two synchronized, finite rows, not floating margin
// notes. Long, colliding, or multi-page notes need a proper integration.
#grid(
  columns: (2fr, 1fr),
  column-gutter: 15pt,
  row-gutter: 1.5em,
  [
    Dies ist eine der zentralsten Aussagen des Gesetzes. Sie ist derart
    elementar, dass es durchaus angebracht ist, sich vor der Weisheit der
    Verfasser zu verbeugen.
  ],
  text(size: 9pt, fill: gray)[
    #set par(justify: false, first-line-indent: 0pt)
    #block(below: 0.7em)[*§ 1 Kein Witz ohne Publikum*]

    Ein Witz kann nur dort witzig sein, wo er auf ein Publikum trifft.
  ],
  [
    Die kulturelle Komponente eines Witzes ist tatsächlich nicht zu
    vernachlässigen. Über die politische Korrektheit der Nutzung des kulturellen
    Umfeldes kann zwar trefflich gestritten werden, nichtsdestotrotz ist die
    Treffsicherheit einer solchen Komik im entsprechenden Umfeld frappierend. Auf
    der anderen Seite kann ein vermeintlicher Witz im falschen kulturellen
    Umfeld auch zu einer echten Gefahr für den Witzeerzähler werden.
  ],
  text(size: 9pt, fill: gray)[
    #set par(justify: false, first-line-indent: 0pt, spacing: 0.5em)
    #block(below: 0.7em)[*§ 2 Komik der Kultur*]

    (1) Die Komik eines Witzes kann durch das kulturelle
    Umfeld, in dem er erzählt wird, bestimmt sein.

    (2) Die Komik eines Witzes kann durch das kulturelle
    Umfeld, in dem er spielt, bestimmt sein.
  ],
)
