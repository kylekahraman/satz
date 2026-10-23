---
title: "API reference"
---

# API reference

This page documents every public name exported by `lib.typ`. Use the jump list below to open a function's signature, input contract, and implementation source. Parameters passed through to native Typst functions keep Typst's own accepted values.

**Version status:** this reference describes the 0.2.0 candidate, which is not the same as the published 0.1.1 package. See [development setup](/satz/guides/development/) before copying a candidate-only example.

| API | Inputs accepted | Returns |
| --- | --- | --- |
| [personal](#personal) | kind defaults to report; config dictionary, optional header/footer content, required body content. Shared configuration is listed [field by field](configuration/). | Returns document content with the requested shared page setup and document class. |
| [report](#report) | required content body, optional config dictionary, theme name or none (default neutral). | Returns report content with headings, page setup and report front matter. |
| [article](#article) | optional title, authors, affiliations, abstract and date; config/theme; required body. Authors are records with required string/content name and optional one-based affiliation indices. Affiliations are strings/content. | Returns article content with full-width metadata and a column-based body. |
| [brief](#brief) / [letter](#letter) | German and English aliases for sender, recipient, date, reference line, subject, enclosures, attachments, signature addition and postal mark. Optional `lang`/`language` is `"de"` or `"en"`. Sender/recipient are records with string address fields; optional logo is content/none. Appearance flags are booleans; see the signature and [letter defaults](configuration/#template-specific-appearance-defaults). | Returns a complete letter layout around the supplied body content. |
| [rechnung](#rechnung) / [invoice](#invoice) | German and English aliases for sender, recipient, date, invoice number, service date, subject and items. Sender/recipient follow the letter record contract. Items are records or three-value tuples: description (string/content), positive numeric quantity, nonnegative numeric unit price. Output labels are German. | Returns a complete invoice layout around the supplied body content. |
| [journal-entry](#journal-entry) | title/date/keywords strings, required body, config/theme. Date is blank or a valid YYYY-MM-DD, DD/MM/YY, or DD/MM/YYYY date, optionally prefixed with weekday. | Returns a formatted entry and registers its metadata for the index. |
| [journal-index](#journal-index) | config/theme; queries journal entries and groups blank dates under Undated. `remember` and `question` each wrap supplied content. | Returns the generated index content. |
| [cover-page](#cover-page) | config, logos/body/footer/footer-left, layout, theme and generated title fields. Layout is classic/research/minimal; theme is neutral/soft-jade/soft-slate/warm-editorial/plum/soft-rose. Classic requires custom body; generated layouts require title. | Rendered document content; use as a show rule or content block as shown in its example. |
| [book (experimental)](#book) | required body; optional title/subtitle/author/eyebrow/note/date content; accent/ink colors; theme/paper/font strings; page margins; font-size/leading/paragraph-spacing lengths; binding alignment; config dictionary. Compose with book-contents(title, depth), book-mainmatter(numbering), book-appendix(body), and book-backmatter(body). | Returns book content with cover, page setup, and book styling. Book components return content blocks. |
| [research-proposal](#research-proposal) / [project-proposal](#project-proposal) | title/applicants/institution, optional date/summary/short-title, English/German language, config, required body. proposal-budget takes item records with description, nonnegative integer-cent unit-cost, and optional positive integer quantity (default 1). | Returns proposal content; the alias has the same contract. |
| [proposal-gantt](#proposal-gantt) | nonempty rows, periods (positive integer), unit (month/quarter), optional start-year, resource labels, widths, size/color, English/German language. Task/group rows have label and inclusive spans; milestones have label and integer at-period. Work-package accepts title/objective, lead/period, arrays of tasks/deliverables/milestones, risk, language and body. | Rendered document content; use as a show rule or content block as shown in its example. |
| [dfg-proposal](#dfg-proposal) | applicant/project content, `"english"` or `"german"`, positive integer max-pages, string form-date, boolean check-pages, config dictionary and required document content. DFG config additionally accepts page.header-ascent and decorative.list-indent/list-body-indent/list-block-spacing. See [proposal coverage](/satz/guides/proposals/). | Returns formatted DFG proposal content and, when enabled, page-budget diagnostics. |
| [nwo-proposal](#nwo-proposal) | scheme/domain/stage/year profile, applicant/title content, config dictionary and required body. Only source-checked 2026 combinations are supported; see [proposal coverage](/satz/guides/proposals/). nwo-text takes a field and plain string. nwo-key-output allows up to three string/content indicators, two URL strings, and boolean/none open-access. nwo-page-budget takes a unique nonempty key and positive page limit. | Returns formatted proposal content. `nwo-profile` returns the selected profile data; `nwo-page-budget` sets a page-budget check around its body. |
| [klageschrift](#klageschrift) | string court/party/address/value fields, anlagen array of strings, optional PDF path and positive page limit, font and required body. | Rendered document content; use as a show rule or content block as shown in its example. |
| [gastspielvertrag](#gastspielvertrag) | document mode (vertrag/angebot/rechnung), fee mode (fest/prozent), string artist/event fields, nonnegative integer costs and counts, percentage 0–100, booleans for technician/photographer/small-business, nonnegative transport rate, font and required body. | Rendered document content; use as a show rule or content block as shown in its example. |
| [scientific-table / scientific-tables](#scientific-table) | positive column count, nonempty header content, config and remaining native table arguments; show-rule body, breakable boolean and config. | Return a styled native table, or apply table styling to matching table content. |
| [callout](#callout) | required body content, optional title content/config and fill/stroke color or auto. | Returns a bordered callout block. |
| [placeholder](#placeholder) | width/height lengths, label content and config; wrap in a native figure for caption and numbering. | Returns a placeholder block. |
| [satz-figure](#satz-figure) | required body content, optional full/short caption content and remaining native figure arguments. | Returns a native figure with separate long caption and short list entry. |
| [chapter-numbering](#chapter-numbering) | required body content, chapter integer, appendix boolean. | Returns content with chapter numbering state applied. |
| [unnumbered-heading](#unnumbered-heading) | required heading content, level integer from 1 to 6 (default 1), outlined boolean (default true). | Returns an unnumbered heading; it appears in the outline unless `outlined: false`. |
| [citepre](#citepre) | citation key string and optional prefix content. | Returns a citation with the supplied prefix. |
| [proposal-citations](#proposal-citations) / [proposal-publications](#proposal-publications) | BibTeX text, highlight-key array, optional CSL style and body; bibliography size and highlight limit. Highlight keys must exist in the bibliography. | Return formatted citation content and a publications list from the provided bibliography. |
| [theme-config](#theme-config) / document-themes | palette name and optional config dictionary. Available palettes are neutral, soft-jade, soft-slate, warm-editorial, plum and soft-rose. | `theme-config` returns a configuration dictionary; `document-themes` exports palette data. |
| [merge](#merge) / defaults | generic deep dictionary merge and root defaults. Unknown keys remain permitted for caller extensions and may be unused. | `merge` returns a configuration dictionary; `defaults` exports the shared default dictionary. |

Known shared configuration groups (page, typography, headings, journal, decorative, page-footer, links, tables, callouts, captions, toc/lof/lot, bibliography, and colors) validate their direct keys and require dictionary values. Page margins also accept inside/outside/x/y. DFG adds page.header-ascent and decorative.list-indent/list-body-indent/list-block-spacing; book adds headings.h1-number-size. Unknown top-level groups remain open for template-specific settings and caller extensions. This catches common misspellings such as typography.leadng without rejecting custom extension groups. Postal templates additionally validate their closed appearance groups. Satz-specific enums and record shapes are checked at public entry points, while forwarded native Typst options use Typst validation.

The staged candidate check compiles the quick-start and representative template examples against 0.2.0 source. The published-package check separately compiles stable examples against 0.1.1. The contracts above were compared with exported signatures and implementation checks.

## Browse functions

[`brief`](#brief) · [`rechnung`](#rechnung) · [`dfg-proposal`](#dfg-proposal) · [`dfg-supplement`](#dfg-supplement) · [`dfg-publications`](#dfg-publications) · [`research-proposal`](#research-proposal) · [`proposal-budget`](#proposal-budget) · [`proposal-gantt`](#proposal-gantt) · [`work-package`](#work-package) · [`proposal-citations`](#proposal-citations) · [`proposal-publications`](#proposal-publications) · [`klageschrift`](#klageschrift) · [`gastspielvertrag`](#gastspielvertrag) · [`journal-entry`](#journal-entry) · [`journal-index`](#journal-index) · [`remember`](#remember) · [`question`](#question) · [`report`](#report) · [`article`](#article) · [`book`](#book) · [`book-contents`](#book-contents) · [`book-mainmatter`](#book-mainmatter) · [`book-appendix`](#book-appendix) · [`book-backmatter`](#book-backmatter) · [`exercise`](#exercise) · [`worked-example`](#worked-example) · [`analysis-note`](#analysis-note) · [`answer-grid`](#answer-grid) · [`cover-page`](#cover-page) · [`personal`](#personal) · [`satz-figure`](#satz-figure) · [`citepre`](#citepre) · [`placeholder`](#placeholder) · [`scientific-table`](#scientific-table) · [`scientific-tables`](#scientific-tables) · [`callout`](#callout) · [`chapter-numbering`](#chapter-numbering) · [`unnumbered-heading`](#unnumbered-heading) · [`nwo-proposal`](#nwo-proposal) · [`nwo-profile`](#nwo-profile) · [`nwo-text`](#nwo-text) · [`nwo-key-output`](#nwo-key-output) · [`nwo-page-budget`](#nwo-page-budget) · [`theme-config`](#theme-config)

## Exact candidate signatures
These signatures are taken from the current source; they show every optional argument and default. The input contracts above explain Satz-specific types and value constraints. Native Typst values (such as colors, lengths, content, numbering, and function arguments forwarded with `..args`) follow Typst's own validation. Aliases share the signature of their target: `letter` is `brief`, `invoice` is `rechnung`, `project-proposal` is `research-proposal`, and `research-cover` / `minimal-cover` fix the corresponding `cover-page.layout`. `defaults`, `cover-themes`, and `document-themes` are exported dictionaries; `merge(base, overrides)` recursively merges dictionaries and otherwise replaces values.

<a id="brief"></a>
### `brief` ([`letter/template.typ`](https://github.com/kylekahraman/satz/blob/main/letter/template.typ))

```text
#let brief(
  absender: none,
  empfaenger: none,
  datum: none,
  geschaeftszeile: none,
  betreff: none,
  anlagenverzeichnis: none,
  anlagen: none,
  signatur_zusatz: none,
  signatur: true,
  postvermerk: none,
  lang: none,
  sender: none,
  recipient: none,
  date: none,
  reference-line: none,
  subject: none,
  enclosure-list: none,
  attachments: none,
  signature-addition: none,
  postal-mark: none,
  language: none,
  theme: none,
  config: (:),
  font: "Inter",
  falzmarken: true,
  adressfenster: true,
  seitenzahlen: true,
  digitaler_absender: false,
  datum_rechts: false,
  blocksatz: true,
  absender_anzeigen: true,
  empfaenger_anzeigen: true,
  datum_anzeigen: true,
  betreff_anzeigen: true,
  papier: "a4",
  seitenraender: (:),
  schriftgroesse: 11pt,
  zeilenabstand: 0.65em,
  abstaende: (:),
  betreff_groesse: 11.5pt,
  digitaler_absender_hoehe: 19mm,
  body
)
```

<a id="rechnung"></a>
### `rechnung` ([`invoice/rechnung.typ`](https://github.com/kylekahraman/satz/blob/main/invoice/rechnung.typ))

```text
#let rechnung(
  absender: none,
  empfaenger: none,
  datum: none,
  rechnungsnummer: none,
  leistungsdatum: none,
  betreff: none,
  posten: none,
  sender: none,
  recipient: none,
  date: none,
  invoice-number: none,
  service-date: none,
  subject: none,
  items: none,
  qr: true,
  qr-betrag: none,
  qr-amount: none,
  qr-verwendungszweck: none,
  qr-purpose: none,
  font: "Inter",
  kleinunternehmer: none,
  small-business: none,
  theme: none,
  config: (:),
  body
)
```

<a id="dfg-proposal"></a>
### `dfg-proposal` ([`dfg-proposal/dfg.typ`](https://github.com/kylekahraman/satz/blob/main/dfg-proposal/dfg.typ))

```text
#let dfg-proposal(
  applicant: [], project: [], language: "english", max-pages: 17,
  form-date: "09/26", check-pages: true, config: (:), doc,
)
```

<a id="dfg-supplement"></a>
### `dfg-supplement` ([`dfg-proposal/dfg.typ`](https://github.com/kylekahraman/satz/blob/main/dfg-proposal/dfg.typ))

```text
#let dfg-supplement()
```

<a id="dfg-publications"></a>
### `dfg-publications` ([`dfg-proposal/dfg.typ`](https://github.com/kylekahraman/satz/blob/main/dfg-proposal/dfg.typ))

```text
#let dfg-publications(source: none, size: 9pt, style: "apa", ..args)
```

<a id="research-proposal"></a>
### `research-proposal` ([`proposal/template.typ`](https://github.com/kylekahraman/satz/blob/main/proposal/template.typ))

```text
#let research-proposal(
  title: [], applicants: [], institution: [], date: none, summary: none,
  short-title: none, language: "english", config: (:), body,
)
```

<a id="proposal-budget"></a>
### `proposal-budget` ([`proposal/components.typ`](https://github.com/kylekahraman/satz/blob/main/proposal/components.typ))

```text
#let proposal-budget(items, language: "english", total-label: none)
```

<a id="proposal-gantt"></a>
### `proposal-gantt` ([`proposal/planning.typ`](https://github.com/kylekahraman/satz/blob/main/proposal/planning.typ))

```text
#let proposal-gantt(
  rows, periods: 24, unit: "month", start-year: none,
  resources: (), label-width: 40mm, resource-width: 10mm,
  size: 11pt, color: rgb("314158"), language: "english",
)
```

<a id="work-package"></a>
### `work-package` ([`proposal/planning.typ`](https://github.com/kylekahraman/satz/blob/main/proposal/planning.typ))

```text
#let work-package(
  title: [], objective: [], lead: none, period: none,
  tasks: (), deliverables: (), milestones: (), risk: none,
  language: "english", body: [],
)
```

<a id="proposal-citations"></a>
### `proposal-citations` ([`proposal/citations.typ`](https://github.com/kylekahraman/satz/blob/main/proposal/citations.typ))

```text
#let proposal-citations(bib, highlight: (), style: none, body)
```

<a id="proposal-publications"></a>
### `proposal-publications` ([`proposal/citations.typ`](https://github.com/kylekahraman/satz/blob/main/proposal/citations.typ))

```text
#let proposal-publications(size: 11pt, max-highlight: none)
```

<a id="klageschrift"></a>
### `klageschrift` ([`legal-complaint/template.typ`](https://github.com/kylekahraman/satz/blob/main/legal-complaint/template.typ))

```text
#let klageschrift(
  gericht: "Amtsgericht",
  gericht_ort: "",
  klagername: "",
  klagerin_str: "",
  klagerin_plz: "",
  beklagter: "",
  beklagter_str: "",
  beklagter_plz: "",
  streitwert: "",
  anlagen: (),
  anlagen_pdf_path: none,
  anlagen_max_pages: 30,
  font: "Inter",
  body,
)
```

<a id="gastspielvertrag"></a>
### `gastspielvertrag` ([`gastspielvertrag/template.typ`](https://github.com/kylekahraman/satz/blob/main/gastspielvertrag/template.typ))

```text
#let gastspielvertrag(
  // Document type
  dokument: "vertrag",

  // Artist info
  kuenstler: "Max Mustermann",
  kuenstler_vertreter: "Max Mustermann",
  kuenstler_anschrift: "Musterstraße 1, 12345 Musterstadt",

  // Event
  veranstaltung: "",
  location: "",
  datum: "",
  auftrittszeit: "",
  auftrittsdauer: "",
  einlass: "",
  curfew: "",

  // Personnel
  musiker: 4,
  techniker: true,
  fotograf: false,

  // Fee
  gage_typ: "fest",
  festgage: 0,
  prozentsatz: 80,
  mindestgage: 0,
  kleinunternehmer: true,

  // Transport
  transport_km: 0,
  transport_satz: 0.30,

  // Optional costs
  techniker_honorar: 0,
  uebernachtung: 0,
  sonstiges_text: "",
  sonstiges_betrag: 0,

  // Hospitality
  buyout_pro_person: 15,

  // Styling
  font: "Inter",

  // Extra content
  body,
)
```

<a id="journal-entry"></a>
### `journal-entry` ([`journal/template.typ`](https://github.com/kylekahraman/satz/blob/main/journal/template.typ))

```text
#let journal-entry(
  title: "",
  date: "",
  keywords: "",
  body,
  config: (:),
  theme: none,
)
```

<a id="journal-index"></a>
### `journal-index` ([`journal/template.typ`](https://github.com/kylekahraman/satz/blob/main/journal/template.typ))

```text
#let journal-index(config: (:), theme: none)
```

<a id="remember"></a>
### `remember` ([`journal/components.typ`](https://github.com/kylekahraman/satz/blob/main/journal/components.typ))

```text
#let remember(body)
```

<a id="question"></a>
### `question` ([`journal/components.typ`](https://github.com/kylekahraman/satz/blob/main/journal/components.typ))

```text
#let question(body)
```

<a id="report"></a>
### `report` ([`report/template.typ`](https://github.com/kylekahraman/satz/blob/main/report/template.typ))

```text
#let report(body, config: (:), theme: report-defaults.theme)
```

<a id="article"></a>
### `article` ([`article/template.typ`](https://github.com/kylekahraman/satz/blob/main/article/template.typ))

```text
#let article(title: none, authors: (), affiliations: (), abstract: none, date: none, config: (:), theme: none, body)
```

<a id="book"></a>
### `book` ([`book/template.typ`](https://github.com/kylekahraman/satz/blob/main/book/template.typ))

```text
#let book(
  body,
  title: none,
  subtitle: none,
  author: none,
  eyebrow: none,
  note: none,
  date: none,
  accent: none,
  ink: none,
  theme: none,
  paper: none,
  margin: none,
  math-font: none,
  font: none,
  font-size: none,
  leading: none,
  paragraph-spacing: none,
  binding: auto,
  binding-correction: none,
  config: (:),
)
```

<a id="book-contents"></a>
### `book-contents` ([`book/template.typ`](https://github.com/kylekahraman/satz/blob/main/book/template.typ))

```text
#let book-contents(title: [Contents], depth: 1)
```

<a id="book-mainmatter"></a>
### `book-mainmatter` ([`book/template.typ`](https://github.com/kylekahraman/satz/blob/main/book/template.typ))

```text
#let book-mainmatter(body, numbering: none)
```

<a id="book-appendix"></a>
### `book-appendix` ([`book/template.typ`](https://github.com/kylekahraman/satz/blob/main/book/template.typ))

```text
#let book-appendix(body)
```

<a id="book-backmatter"></a>
### `book-backmatter` ([`book/template.typ`](https://github.com/kylekahraman/satz/blob/main/book/template.typ))

```text
#let book-backmatter(body)
```

<a id="exercise"></a>
### `exercise` ([`book/components.typ`](https://github.com/kylekahraman/satz/blob/main/book/components.typ))

```text
#let exercise(body, kind: "Core", grid: none)
```

<a id="worked-example"></a>
### `worked-example` ([`book/components.typ`](https://github.com/kylekahraman/satz/blob/main/book/components.typ))

```text
#let worked-example(body, above: none, below: none, inset: none)
```

<a id="analysis-note"></a>
### `analysis-note` ([`book/components.typ`](https://github.com/kylekahraman/satz/blob/main/book/components.typ))

```text
#let analysis-note(body, title: [In your analysis])
```

<a id="answer-grid"></a>
### `answer-grid` ([`book/components.typ`](https://github.com/kylekahraman/satz/blob/main/book/components.typ))

```text
#let answer-grid(height: 25mm, cell: 5mm, color: none, width: none)
```

<a id="cover-page"></a>
### `cover-page` ([`cover.typ`](https://github.com/kylekahraman/satz/blob/main/cover.typ))

```text
#let cover-page(
  config: (:),
  logos: none,
  body: none,
  footer: none,
  footer-left: none,
  layout: "classic",
  theme: "neutral",
  title: none,
  subtitle: none,
  author: none,
  date: none,
  keywords: none,
  supervisors: none,
)
```

<a id="personal"></a>
### `personal` ([`class.typ`](https://github.com/kylekahraman/satz/blob/main/class.typ))

```text
#let personal(
  kind: "report",
  config: (:),
  header: none,
  footer: none,
  body,
)
```

<a id="satz-figure"></a>
### `satz-figure` ([`class.typ`](https://github.com/kylekahraman/satz/blob/main/class.typ))

```text
#let satz-figure(body, caption: none, short-caption: none, ..args)
```

<a id="citepre"></a>
### `citepre` ([`citation.typ`](https://github.com/kylekahraman/satz/blob/main/citation.typ))

```text
#let citepre(key, pre: none)
```

<a id="placeholder"></a>
### `placeholder` ([`figures.typ`](https://github.com/kylekahraman/satz/blob/main/figures.typ))

```text
#let placeholder(width: 100%, height: 4cm, label: [Placeholder], config: (:))
```

<a id="scientific-table"></a>
### `scientific-table` ([`tables.typ`](https://github.com/kylekahraman/satz/blob/main/tables.typ))

```text
#let scientific-table(columns: 1, header: (), config: (:), ..args)
```

<a id="scientific-tables"></a>
### `scientific-tables` ([`tables.typ`](https://github.com/kylekahraman/satz/blob/main/tables.typ))

```text
#let scientific-tables(body, breakable: false, config: (:))
```

<a id="callout"></a>
### `callout` ([`callouts.typ`](https://github.com/kylekahraman/satz/blob/main/callouts.typ))

```text
#let callout(body, title: none, config: (:), fill: auto, stroke: auto)
```

<a id="chapter-numbering"></a>
### `chapter-numbering` ([`chapter-numbering.typ`](https://github.com/kylekahraman/satz/blob/main/chapter-numbering.typ))

```text
#let chapter-numbering(body, chapter: 1, appendix: false)
```

<a id="unnumbered-heading"></a>
### `unnumbered-heading` ([`headings.typ`](https://github.com/kylekahraman/satz/blob/main/headings.typ))

```text
#let unnumbered-heading(body, level: 1, outlined: true)
```

`body` is heading content. `level` is an integer from 1 through 6. `outlined` controls whether the heading appears in the document outline and contents.

<a id="nwo-proposal"></a>
### `nwo-proposal` ([`nwo-proposal/template.typ`](https://github.com/kylekahraman/satz/blob/main/nwo-proposal/template.typ))

```text
#let nwo-proposal(
  scheme: "veni", domain: "science", stage: "pre", year: 2026,
  applicant: [], title: [], config: (:), body,
)
```

<a id="nwo-profile"></a>
### `nwo-profile` ([`nwo-proposal/profiles.typ`](https://github.com/kylekahraman/satz/blob/main/nwo-proposal/profiles.typ))

```text
#let nwo-profile(scheme: "veni", domain: "science", stage: "pre", year: 2026)
```

<a id="nwo-text"></a>
### `nwo-text` ([`nwo-proposal/components.typ`](https://github.com/kylekahraman/satz/blob/main/nwo-proposal/components.typ))

```text
#let nwo-text(field, response)
```

<a id="nwo-key-output"></a>
### `nwo-key-output` ([`nwo-proposal/components.typ`](https://github.com/kylekahraman/satz/blob/main/nwo-proposal/components.typ))

```text
#let nwo-key-output(reference: [], output-type: [], contribution: [], indicators: (), urls: (), open-access: none)
```

<a id="nwo-page-budget"></a>
### `nwo-page-budget` ([`nwo-proposal/components.typ`](https://github.com/kylekahraman/satz/blob/main/nwo-proposal/components.typ))

```text
#let nwo-page-budget(key, max-pages: 14, body)
```

<a id="theme-config"></a>
### `theme-config` ([`themes.typ`](https://github.com/kylekahraman/satz/blob/main/themes.typ))

```text
#let theme-config(name, config: (:))
```

## Other exported names

| Name | Kind | Meaning |
| --- | --- | --- |
| <span id="letter"></span>`letter` | alias | Same function as [`brief`](#brief); it accepts the same German and English argument names. |
| <span id="invoice"></span>`invoice` | alias | Same function as [`rechnung`](#rechnung); the output remains a German invoice. |
| <span id="project-proposal"></span>`project-proposal` | alias | Same function as [`research-proposal`](#research-proposal). |
| <span id="research-cover"></span><span id="minimal-cover"></span>`research-cover`, `minimal-cover` | preset aliases | `cover-page` with `layout: "research"` or `layout: "minimal"` fixed. |
| <span id="defaults"></span>`defaults` | dictionary | Shared appearance defaults; see the [configuration reference](/satz/reference/configuration/). |
| <span id="cover-themes"></span>`cover-themes`, <span id="document-themes"></span>`document-themes` | dictionaries | Palette dictionaries; use [`theme-config`](#theme-config) to apply a palette to supported templates. |
| <span id="glossarium"></span>`glossarium` | namespace | The pinned upstream glossary package is re-exported for explicit document-level setup. See the [glossary example](https://github.com/kylekahraman/satz/blob/main/examples/glossary.typ). |
