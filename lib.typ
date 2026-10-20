#import "letter/template.typ": brief
#let letter = brief
#import "invoice/rechnung.typ": rechnung
#let invoice = rechnung
#import "dfg-proposal/dfg.typ": dfg-proposal
#import "legal-complaint/template.typ": klageschrift
#import "gastspielvertrag/template.typ": gastspielvertrag
#import "journal/template.typ": journal-entry, journal-index, remember, question
#import "defaults.typ": defaults, merge
#import "report/template.typ": report
#import "article/template.typ": article
#import "book/template.typ": book, book-contents, book-mainmatter, book-appendix, book-backmatter
#import "book/components.typ": exercise, worked-example, analysis-note, answer-grid
#import "cover.typ": cover-page, cover-themes, research-cover, minimal-cover
#import "class.typ": personal, satz-figure
#import "citation.typ": citepre
#import "figures.typ": placeholder
// Optional author-facing glossary API; setup stays explicit in the document.
#import "@preview/glossarium:0.5.10"
#import "tables.typ": scientific-table
