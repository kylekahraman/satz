// Satz public API — templates, shared document layout, and authoring components.

/// Satz document toolkit for Typst.
///
/// Templates share one deep-merged configuration system. Import the template
/// you need from this entry point, for example:
///
/// ```typst
/// #import "@preview/satz:0.2.0": report
/// #show: report.with(config: (typography: (font: "EB Garamond"),))
/// = Introduction
/// ```
///
/// English argument names are canonical. German names remain available as
/// compatibility aliases on templates that historically used them. Covers are
/// optional components: pass shared `theme` and `config` explicitly when a
/// cover should match a document. Document templates default to the neutral
/// black-on-white palette; pass `theme: "slate"` to use the former blue-gray
/// shared palette, now available as a named theme.
#import "letter/template.typ": brief
/// English alias for `brief`.
#let letter = brief
#import "invoice/rechnung.typ": rechnung
/// English alias for `rechnung`.
#let invoice = rechnung
#import "dfg-proposal/dfg.typ": dfg-proposal, dfg-supplement, dfg-publications
#import "proposal/template.typ": research-proposal, project-proposal
#import "proposal/components.typ": proposal-budget
#import "proposal/planning.typ": proposal-gantt, work-package
#import "proposal/citations.typ": proposal-citations, proposal-publications
#import "legal-complaint/template.typ": klageschrift
/// English alias for `klageschrift`; output remains German.
#let complaint = klageschrift
#import "gastspielvertrag/template.typ": gastspielvertrag
/// English alias for `gastspielvertrag`; output remains German.
#let guest-contract = gastspielvertrag
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
