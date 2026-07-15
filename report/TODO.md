# Report Template — TODO

## Running headers
- Show chapter/section name in page header when content spans multiple pages.
- Configurable: `header.show: true/false`, `header.text: "auto" | "chapter" | "custom string"`.
- Pattern: same as journal header (entry title + date), adapted for sections.

## Binding correction (BCOR)
- Double-sided book layout for printed theses.
- Alternating inner/outer margins: extra space on binding edge.
- Page numbers on outside edges (left on even, right on odd).
- Config: `page.binding: none | auto | length`.

## Article mode
- Config flag: `kind: "article"`.
- Article differences: no chapter numbering, author + affiliation block, abstract, optional two-column layout.
- Two-column: `columns: 1 | 2`, with figure spanning via `#colbreak()` or `#place()`.
- Don't create a separate package — extend this one.

## Future
- Abstract environment (show rule on `= Abstract` heading).
- Author/affiliation frontmatter block.
- TOC generation via `#outline()`.
- Better footnote styling.
