# Book API: workbook parity findings

The private RSA maths workbook is the real-document specimen for satz's
experimental `book(...)` entry point. Its LaTeX source and PDF stay outside the
package. The rebuildable Typst source and generated PDF are in the ignored
local `workbook-conversion/` directory; the placeholder example is
[`examples/book.typ`](../examples/book.typ).

## Source design measured from the PDF and preamble

| Detail | Source setting | satz control |
|---|---|---|
| Page | A4, two-sided, open-any chapters | `paper`, `binding` |
| Margins | inside 27 mm, outside 25 mm, top 25 mm, bottom 27 mm | `margin` |
| Binding | 5 mm correction at the inside edge | `binding-correction` |
| Body type | Georgia, 11 pt; STIX Two Math | `font`, `font-size`, `math-font` |
| Body rhythm | 1.16 line spacing, 6 pt plus stretch between paragraphs, no indent | `leading`, `paragraph-spacing`, shared typography config |
| Main accent and ink | teal `#23616B`, ink `#24313B` | `accent`, `config.book.ink` |
| Chapter heading | hanging teal number, 25 pt number, 18 pt ink title | shared `headings` settings and book heading rule |
| Section headings | teal 12 pt; bold subsection headings | shared `headings` settings |
| Answer area | 5 mm cells, 0.2 pt gray lines | `exercise(grid:)`, `answer-grid(...)` |

The source also uses worked examples set in a compact indented quote, an
interpretation prompt, numbered exercises, a linked solution appendix, a
notation table, a method map, and six TikZ diagrams. These became the optional
`worked-example`, `analysis-note`, and `exercise` components, Typst tables, and
local diagram images.

The specimen calibrates those TeX paragraph settings to Typst values of
`leading: 0.74em` and `paragraph-spacing: 14pt`; these values match the measured
line and paragraph baselines in this build rather than copying TeX lengths
literally. The general package default remains independently configurable.

## Measured PDF checks

Both PDFs have 79 pages. All 25 chapter openings land on the same physical
pages:

| Chapters | Source and satz PDF pages |
|---|---|
| 1–9 | 7, 9, 11, 13, 15, 17, 19, 21, 23 |
| 10–18 | 26, 29, 31, 33, 36, 38, 40, 42, 45 |
| 19–25 | 47, 49, 51, 54, 57, 59, 62 |

The cover and first chapter opening also align closely by PDF coordinates
(points from the top of the page):

- Cover eyebrow: y=149 in both PDFs.
- Main title lines: y=198 and 223 in the source; y=198 and 223 in satz.
- Subtitle lines: y=280 and 296 in both.
- Cover rule: y=368 in satz and y=368 in the source.
- Chapter 1 title: y=94 in both; the first body line begins at y=134 in both.
- The contents folio is iii; main matter starts at Arabic page 1. The worked
  solutions start at Arabic page 59, and the three final reference pages are
  71–73 in both PDFs.

The source PDF has 133 internal links, and the converted PDF has 133. They
include links from worked solutions back to their exercise anchors. The source
and converted documents also retain the blank verso after the cover and after
the contents page. The converted solution links use `#153A40`, matching the
source link color while deriving that shade from the selected teal accent.

## Remaining parity gaps

- The six source TikZ diagrams are high-resolution PNG crops in the conversion.
  Their size and placement are calibrated, but they are not vector graphics in
  the Typst PDF. Rebuilding them as native Typst drawings would improve zoom and
  print sharpness.
- Typst and LaTeX do not break every line identically. The chapter opening
  pages and overall page count match, but a few line endings and equation glyph
  shapes differ.
- The two source reference tables fit on individual pages. The current
  conversion renders them as native tables; automatic continuation of a table
  that grows across pages still needs a separate check.

## What the specimen has established for satz

The public class API can stay focused on shared page and typography behavior.
Authors need a book-level wrapper that exposes the common choices directly and
names the transitions between front matter, main matter, appendices, and back
matter. Less common cover and heading adjustments remain available through the
existing recursive `config` merge. This keeps the common writing path short
while letting the book vary from the specimen without editing satz internals.
