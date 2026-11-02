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
/// Create a DIN 5008 letter using the English API name.
///
/// `letter` is the same function as `brief`: it accepts the same sender,
/// recipient, date, appearance, and layout arguments and produces the same
/// document. English field names are canonical; the German names remain
/// supported for existing documents.
///
/// ```typst
/// #show: letter.with(
///   sender: (name: "Example Author", street: "Example Street 1",
///     postal-code-city: "12345 Example City"),
///   recipient: (name: "Example Recipient", street: "Sample Road 2",
///     postal-code-city: "54321 Sample City"),
///   language: "en",
/// )
/// ```
///
/// See `brief` for the complete argument list, record fields, and defaults.
#let letter = brief
#import "invoice/rechnung.typ": rechnung
/// Create a German invoice using the English API name.
///
/// `invoice` is the same function as `rechnung`: it accepts the same sender,
/// recipient, payment, item, appearance, and layout arguments. English field
/// names are canonical; German names remain supported for existing documents.
/// The rendered invoice remains German.
///
/// ```typst
/// #show: invoice.with(
///   sender: (name: "Example Studio", street: "Example Street 1",
///     postal-code-city: "12345 Example City", iban: "DE00 0000 0000 0000 0000 00"),
///   recipient: (name: "Sample Client", street: "Sample Road 2",
///     postal-code-city: "54321 Sample City"),
///   items: (("Example service", 1, 500)),
/// )
/// ```
///
/// See `rechnung` for the complete argument list, record fields, and defaults.
#let invoice = rechnung
#import "dfg-proposal/dfg.typ": dfg-proposal, dfg-supplement, dfg-publications
#import "proposal/template.typ": research-proposal, project-proposal
#import "proposal/components.typ": proposal-budget
#import "proposal/planning.typ": proposal-gantt, work-package
#import "proposal/citations.typ": proposal-citations, proposal-publications
#import "legal-complaint/template.typ": klageschrift
/// Create a German statement of claim using the English API name.
///
/// `complaint` is the same function as `klageschrift` and accepts the same
/// arguments and German-formatted content. It is an API alias only; the
/// generated legal document remains German.
///
/// See `klageschrift` for the full argument list, required content, and defaults.
#let complaint = klageschrift
#import "gastspielvertrag/template.typ": gastspielvertrag
/// Create a German guest performance contract using the English API name.
///
/// `guest-contract` is the same function as `gastspielvertrag` and accepts the
/// same contract configuration and optional clauses. It is an API alias only;
/// the generated contract remains German.
///
/// See `gastspielvertrag` for the full argument list, configuration fields,
/// and defaults.
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
