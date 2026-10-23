#import "letter/template.typ": brief
#let letter = brief
#import "invoice/rechnung.typ": rechnung
#let invoice = rechnung
#import "dfg-proposal/dfg.typ": dfg-proposal, dfg-supplement, dfg-publications
#import "proposal/template.typ": research-proposal, project-proposal
#import "proposal/components.typ": proposal-budget
#import "proposal/planning.typ": proposal-gantt, work-package
#import "proposal/citations.typ": proposal-citations, proposal-publications
#import "legal-complaint/template.typ": klageschrift
#import "gastspielvertrag/template.typ": gastspielvertrag
#import "journal/template.typ": journal-entry, journal-index, remember, question
#import "defaults.typ": defaults, merge
#import "report/template.typ": report
#import "article/template.typ": article
#import "book/template.typ": book, book-contents, book-mainmatter, book-appendix, book-backmatter, book-index
#import "book/components.typ": exercise, worked-example, analysis-note, answer-grid
#import "cover.typ": cover-page, cover-themes, research-cover, minimal-cover
#import "themes.typ": document-themes, theme-config
#import "class.typ": custom, satz-figure
#import "citation.typ": citepre
#import "figures.typ": placeholder
// Optional author-facing glossary API; setup stays explicit in the document.
#import "@preview/glossarium:0.5.10"
#import "tables.typ": scientific-table, scientific-tables
#import "callouts.typ": callout
#import "chapter-numbering.typ": chapter-numbering
#import "headings.typ": unnumbered-heading

#import "nwo-proposal/template.typ": nwo-proposal
#import "nwo-proposal/profiles.typ": nwo-profile
#import "nwo-proposal/components.typ": nwo-text, nwo-key-output, nwo-page-budget
