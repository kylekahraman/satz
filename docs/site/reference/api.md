---
title: "API reference"
---

This page documents every public name exported by `lib.typ`. Use the jump list below to open a function's signature, input contract, and implementation source. Parameters passed through to native Typst functions keep Typst's own accepted values.

**Version status:** this reference describes the 0.2.0 candidate, which is not the same as the published 0.1.1 package. See [development setup](/satz/guides/development/) before copying a candidate-only example.

| API | Inputs accepted | Returns |
| --- | --- | --- |
| [custom](#custom) | kind defaults to report; `theme` defaults to neutral; config dictionary, optional header/footer content, required body content. Config is deep-merged over the defaults and known groups reject misspelled keys. Passing `header` or `footer` replaces the automatic furniture. Shared configuration is listed [field by field](/satz/reference/configuration/). | Applies Satz's shared styling to a structure you write yourself. Named templates remain the usual starting point when their structure fits. |
| [report](#report) | required content body, optional config dictionary, theme name or none (default neutral). | Returns report content with headings, page setup and report front matter. |
| [article](#article) | optional title, authors, affiliations, abstract and date; config/theme; required body. `authors` accepts one record directly or an array of records; each has a required string/content name and optional one-based affiliation indices. Affiliations are strings/content. | Returns article content with full-width metadata and a column-based body. |
| [letter](#letter) / [brief](#brief) | English canonical fields: `sender`, `recipient`, `date`, `reference-line`, `subject`, `enclosure-list`, `attachments`, `signature-addition`, `postal-mark`, and appearance/layout options. `language` is `"de"` or `"en"`. German argument and record names are aliases. Omitting `date` uses the compilation date; `show-date: false` does not hide reference fields. | Returns a complete letter layout around the supplied body content. |
| [invoice](#invoice) / [rechnung](#rechnung) | English canonical fields: `sender`, `recipient`, `date`, `invoice-number`, `service-date`, `subject`, `items`, `qr`, `qr-amount`, and `qr-purpose`. Sender/recipient follow the letter record contract. Items are records or three-value tuples: description (string/content), positive numeric quantity, nonnegative numeric unit price. Output labels are German; German input names are aliases. | Returns a complete invoice layout around the supplied body content. |
| [journal-entry](#journal-entry) | title/date/keywords strings, required body, config/theme. Uses ISO B5 by default. Date is blank or a valid YYYY-MM-DD, DD/MM/YY, or DD/MM/YYYY date, optionally prefixed with weekday. | Returns a formatted entry and registers its metadata for the index. |
| [journal-index](#journal-index) | config/theme; finds entries in the document, sorts dated entries chronologically, groups them by month, and places undated entries last. `remember` and `question` each wrap supplied content. | Returns the generated index content. |
| [cover-page](#cover-page) | config, logos/body/footer/footer-left, layout, theme and generated title fields. Layout is classic/research/minimal; theme is neutral/slate/soft-jade/soft-slate/warm-editorial/plum/soft-rose. Classic requires custom body; generated layouts require title. Covers do not inherit another template's config or theme. | Rendered document content; use as a content block as shown in its example. |
| [book (experimental)](#book) | required body and `title` unless `cover-image` is supplied; optional subtitle/author/eyebrow/note/date; accent/ink; theme/paper/font; margins; font-size/leading/paragraph-spacing; binding/binding-correction; running-headers; config. Compose with book-contents(title, depth), book-mainmatter(numbering), book-appendix(body), book-backmatter(body), and book-index(body, ...). | Returns book content with cover, page setup, and book styling. Book components return content blocks. |
| [research-proposal](#research-proposal) / [project-proposal](#project-proposal) | title/applicants/institution, optional date/summary/short-title, English/German language, config, required body. proposal-budget takes item records with description, nonnegative integer-cent unit-cost, and optional positive integer quantity (default 1). | Returns proposal content; the alias has the same contract. |
| [proposal-gantt](#proposal-gantt) | nonempty rows, periods (positive integer), unit (month/quarter), optional start-year, resource labels, widths, size/color, English/German language. Task/group rows have label and inclusive spans; milestones have label and integer at-period. Work-package accepts title/objective, lead/period, arrays of tasks/deliverables/milestones, risk, language and body. | Rendered document content; use as a show rule or content block as shown in its example. |
| [dfg-proposal](#dfg-proposal) | applicant/project content, `"english"` or `"german"`, positive integer max-pages, string form-date, boolean check-pages, config dictionary and required document content. DFG config additionally accepts page.header-ascent and decorative.list-indent/list-body-indent/list-spacing/list-block-spacing. See [proposal coverage](/satz/guides/proposals/). | Returns formatted DFG proposal content and, when enabled, page-budget diagnostics. |
| [nwo-proposal](#nwo-proposal) | scheme/domain/stage/year profile, applicant/title content, config dictionary and required body. Only source-checked 2026 combinations are supported; see [proposal coverage](/satz/guides/proposals/). nwo-text takes a field and plain string. nwo-key-output allows up to three string/content indicators, two URL strings, and boolean/none open-access. nwo-page-budget takes a unique nonempty key and positive page limit. | Returns formatted proposal content. `nwo-profile` returns the selected profile data; `nwo-page-budget` sets a page-budget check around its body. |
| [complaint](#complaint) / [klageschrift](#klageschrift) | English canonical court/party/address/value fields, exhibits array of strings, optional PDF path and positive page limit, explicit date, plaintiff designation, font, and required body. German names are aliases. Output remains German. | Rendered document content; use as a show rule or content block as shown in its example. |
| [guest-contract](#guest-contract) / [gastspielvertrag](#gastspielvertrag) | document mode (vertrag/angebot/rechnung), fee mode (fest/prozent), string artist/event fields, nonnegative integer costs and counts, percentage 0–100, booleans for technician/photographer/small-business, nonnegative transport rate, font, and required body. German names are aliases. Output remains German. | Rendered document content; use as a show rule or content block as shown in its example. |
| [scientific-table / scientific-tables](#scientific-table) | positive column count or nonempty array of native column widths, nonempty header content, config and remaining native table arguments; show-rule body, breakable boolean and config. | Return a styled native table, or apply table styling to matching table content. |
| [callout](#callout) | required body content, optional title content/config and fill/stroke color or auto. | Returns a bordered callout block. |
| [placeholder](#placeholder) | width/height lengths, label content and config; wrap in a native figure for caption and numbering. | Returns a placeholder block. |
| [satz-figure](#satz-figure) | required body content, optional full/short caption content and remaining native figure arguments. | Returns a native figure with separate long caption and short list entry. |
| [chapter-numbering](#chapter-numbering) | required body content, chapter integer, appendix boolean. | Returns content with chapter numbering state applied. |
| [unnumbered-heading](#unnumbered-heading) | required heading content, level integer from 1 to 6 (default 1), outlined boolean (default true). | Returns an unnumbered heading; it appears in the outline unless `outlined: false`. |
| [citepre](#citepre) | citation key string and optional prefix content. | Returns a citation with the supplied prefix. |
| [proposal-citations](#proposal-citations) / [proposal-publications](#proposal-publications) | BibTeX text, highlight-key array, optional CSL style and body; bibliography size and highlight limit. Highlight keys must exist in the bibliography. | Return formatted citation content and a publications list from the provided bibliography. |
| [theme-config](#theme-config) / document-themes | palette name and optional config dictionary. Available palettes are neutral, slate, soft-jade, soft-slate, warm-editorial, plum and soft-rose. | `theme-config` returns a configuration dictionary; `document-themes` exports palette data. |
| <span id="merge"></span><span id="defaults"></span>[merge](#merge) / [defaults](#defaults) | generic deep dictionary merge and root defaults. Unknown keys remain permitted for caller extensions and may be unused. | `merge` returns a configuration dictionary; `defaults` exports the shared default dictionary. |

Known shared configuration groups (page, typography, headings, journal, decorative, page-footer, line-numbers, links, tables, figures, callouts, captions, toc/lof/lot, bibliography, and colors) validate their direct keys and require dictionary values. Page margins also accept inside/outside/x/y. DFG adds page.header-ascent and decorative.list-indent/list-body-indent/list-spacing/list-block-spacing; book adds headings.h1-number-size. Unknown top-level groups remain open for template-specific settings and caller extensions. This catches common misspellings such as typography.leadng without rejecting custom extension groups. Postal templates additionally validate their closed appearance groups. Satz-specific enums and record shapes are checked at public entry points, while forwarded native Typst options use Typst validation.

The staged candidate check compiles the quick-start and representative template examples against 0.2.0 source. The published-package check separately compiles stable examples against 0.1.1. The contracts above were compared with exported signatures and implementation checks.

## Browse functions

[`letter`](#letter) / [`brief`](#brief) · [`invoice`](#invoice) / [`rechnung`](#rechnung) · [`complaint`](#complaint) / [`klageschrift`](#klageschrift) · [`guest-contract`](#guest-contract) / [`gastspielvertrag`](#gastspielvertrag) · [`dfg-proposal`](#dfg-proposal) · [`dfg-supplement`](#dfg-supplement) · [`dfg-publications`](#dfg-publications) · [`research-proposal`](#research-proposal) · [`proposal-budget`](#proposal-budget) · [`proposal-gantt`](#proposal-gantt) · [`work-package`](#work-package) · [`proposal-citations`](#proposal-citations) · [`proposal-publications`](#proposal-publications) · [`journal-entry`](#journal-entry) · [`journal-index`](#journal-index) · [`remember`](#remember) · [`question`](#question) · [`report`](#report) · [`article`](#article) · [`book`](#book) · [`book-contents`](#book-contents) · [`book-mainmatter`](#book-mainmatter) · [`book-appendix`](#book-appendix) · [`book-backmatter`](#book-backmatter) · [`book-index`](#book-index) · [`exercise`](#exercise) · [`worked-example`](#worked-example) · [`analysis-note`](#analysis-note) · [`answer-grid`](#answer-grid) · [`cover-page`](#cover-page) · [`custom`](#custom) · [`satz-figure`](#satz-figure) · [`citepre`](#citepre) · [`placeholder`](#placeholder) · [`scientific-table`](#scientific-table) · [`scientific-tables`](#scientific-tables) · [`callout`](#callout) · [`chapter-numbering`](#chapter-numbering) · [`unnumbered-heading`](#unnumbered-heading) · [`nwo-proposal`](#nwo-proposal) · [`nwo-profile`](#nwo-profile) · [`nwo-text`](#nwo-text) · [`nwo-key-output`](#nwo-key-output) · [`nwo-page-budget`](#nwo-page-budget) · [`theme-config`](#theme-config)

## Exact candidate signatures
These signatures are taken from the current source; they show every optional argument and default. The input contracts above explain Satz-specific types and value constraints. Native Typst values (such as colors, lengths, content, numbering, and function arguments forwarded with `..args`) follow Typst's own validation. Aliases share the signature of their target: `letter` / `brief`, `invoice` / `rechnung`, `complaint` / `klageschrift`, and `guest-contract` / `gastspielvertrag`. `project-proposal` is `research-proposal`, and `research-cover` / `minimal-cover` fix the corresponding `cover-page.layout`. `defaults`, `cover-themes`, and `document-themes` are exported dictionaries; `merge(base, overrides)` recursively merges dictionaries and otherwise replaces values.

<a id="brief"></a><a id="letter"></a>
### `letter` / `brief` ([`letter/template.typ`](https://github.com/kylekahraman/satz/blob/main/letter/template.typ))

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
  signatur: none,
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
  signature: none,
  fold-marks: none,
  address-window: none,
  page-numbers: none,
  digital-sender: none,
  date-right: none,
  justify: none,
  show-sender: none,
  show-recipient: none,
  show-date: none,
  show-subject: none,
  paper: none,
  margins: none,
  font-size: none,
  line-spacing: none,
  block-spacing: none,
  subject-size: none,
  digital-sender-height: none,
  theme: "neutral",
  config: (:),
  font: "Inter",
  falzmarken: none,
  adressfenster: none,
  seitenzahlen: none,
  digitaler_absender: none,
  datum_rechts: none,
  blocksatz: none,
  absender_anzeigen: none,
  empfaenger_anzeigen: none,
  datum_anzeigen: none,
  betreff_anzeigen: none,
  papier: none,
  seitenraender: none,
  schriftgroesse: none,
  zeilenabstand: none,
  abstaende: none,
  betreff_groesse: none,
  digitaler_absender_hoehe: none,
  body
)
```

The German defaults shown as `none` resolve to the postal values: signature,
fold marks, address window, page numbers, sender/recipient/date/subject blocks
and justification are enabled; the digital sender and right-aligned date are
disabled. `font` is the shared direct typography option. Supplying both
spellings of one value is an error.

<a id="rechnung"></a>
<span id="invoice"></span>
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
  theme: "neutral",
  config: (:),
  body
)
```

#### Complete function documentation

<!-- Source docstring included -->



A German invoice with an optional EPC QR code for bank transfers.

English names are the canonical interface; German argument names remain as
compatibility aliases. The rendered invoice stays German.

It totals line items, prints your bank details, and optionally adds a
scannable EPC QR code. Banking apps read the IBAN, amount, and payment
reference from that code. The letter's postal address components and
reference-line layout are reused.

```example
#show: invoice.with(
  sender: (
    name: "Example Studio",
    street: "Example Street 1",
    postal-code-city: "12345 Example City",
    tax-number: "000/000/00000",
    iban: "DE00 0000 0000 0000 0000 00",
    bank: "Example Bank",
  ),
  recipient: (
    name: "Sample Client",
    street: "Sample Road 2",
    postal-code-city: "54321 Sample City",
  ),
  date: "2026-10-27",
  invoice-number: "2026-001",
  service-date: "2026-10-20",
  items: (("Example service", 1, 500)),
  qr-purpose: "Invoice 2026-001",
)
```

- sender (dictionary): billing details
  - name (str): your name or company
  - care-of (str, none): extra line such as c/o
  - street (str): street and number
  - postal-code-city (str): postal code and city
  - tax-number (str): German tax number (`steuernummer`)
  - iban (str): account IBAN
  - bic (str): BIC; optional, defaults to empty
  - bank (str): bank name
  - account-holder (str, none): account holder; defaults to `name`
- recipient (dictionary): who pays; accepts `name`, `care-of`, `street`,
  `postal-code-city`, and the optional `country`
- date (str, none): invoice date. Omitting it uses the compilation date as
  `DD.MM.YYYY`; set an explicit date for reproducible invoices
- invoice-number (str): invoice number; defaults to empty
- service-date (str): date the service was performed; defaults to empty
- subject (str): subject line; defaults to `"Rechnung"`
- items (array): tuples `(description, quantity, unit-price)` or records
  with `description`, `quantity`, and `unit-price` keys
- qr (bool): show the EPC QR code; defaults to true
- qr-amount (int, float, none): override the QR amount; `none` totals the items
- qr-purpose (str): payment reference shown in the QR code; defaults to empty
- small-business (bool): show the § 19 small-business VAT note; defaults to false
- font (str): body font family; defaults to `"Inter"`
- theme (str, none): `neutral` (default), `slate`, `soft-jade`, `soft-slate`,
  `warm-editorial`, `plum`, or `soft-rose`
- config (dictionary): appearance overrides for `page.paper`, `page.margin`,
  core `typography`, `colors`, and `links`; unknown groups or keys are rejected.
  For example, `config: (typography: (font: "STIX Two Text", size: 10pt),
  colors: (brand-primary: blue))`. Defaults are A4, Inter 11pt, and the
  neutral invoice palette. Use `typography.font` for text; math-font is not
  supported by this postal template's restricted appearance config.
- body (content): introductory invoice text before the line-item table

German aliases: `absender`, `empfaenger`, `datum`, `rechnungsnummer`,
`leistungsdatum`, `betreff`, `posten`, `qr-betrag`, `qr-verwendungszweck`,
and `kleinunternehmer`. German nested sender fields are `zusatz`, `strasse`,
`plz_ort`, `steuernummer`, and `kontoinhaber`. Supplying both spellings of
the same value produces a field-specific conflict error.

<span id="dfg-proposal"></span>
### `dfg-proposal` ([`dfg-proposal/dfg.typ`](https://github.com/kylekahraman/satz/blob/main/dfg-proposal/dfg.typ))

```text
#let dfg-proposal(
  applicant: [], project: [], language: "english", max-pages: 17,
  form-date: "09/26", check-pages: true, config: (:), doc,
)
```

#### Complete function documentation

<!-- Source docstring included -->



DFG form 53.01 project description, revision 09/26, in German or English.

Uses Arial 11pt, four numbered heading levels, and no contents or cover page.
`dfg-supplement()` starts the separately counted eight-page second part.
By default compilation fails when either part exceeds its allowance.

```example
#show: dfg-proposal.with(
  applicant: [Alex Example, Example University],
  project: [A small example project],
  doc: [
    = 1 Starting point
    ...
    #dfg-supplement()
    = 4 Project plan
  ],
)
```

- doc (content): numbered project description including headings 1–5
- applicant (content): applicant and institution block; defaults to empty
- project (content): project title block; defaults to empty
- language (str): `"english"` (default) or `"german"`
- max-pages (int): first-part page limit; defaults to 17. Sections 1–3 use
  this limit; sections 4–5 always use the eight-page supplement limit
- form-date (str): displayed DFG form date; defaults to `"09/26"`
- check-pages (bool): fail compilation on an overlength draft when true
  (default); set false for a working draft
- config (dictionary): overrides applied after the DFG form preset; explicit values win.
  The exported `defaults` dictionary documents the shared schema once. Hover
  `satz.defaults` with a namespace import for keys, accepted forms, meanings, and
  baseline values. DFG overrides A4 page geometry, Arial 11pt, four-level numbering,
  black text/links, white paper, left-aligned 11pt captions, and form-specific heading
  and list spacing. It adds `page.header-ascent` and `decorative.list-indent`,
  `list-body-indent`, `list-spacing`, and `list-block-spacing`. Preserve these form
  values for submission; see the [configuration reference](/satz/reference/configuration/)
  for effective values and DFG-specific extension fields.

<span id="dfg-supplement"></span>
### `dfg-supplement` ([`dfg-proposal/dfg.typ`](https://github.com/kylekahraman/satz/blob/main/dfg-proposal/dfg.typ))

```text
#let dfg-supplement()
```

#### Complete function documentation

<!-- Source docstring included -->



Begin the separately counted second part of a DFG project description.

Place this call exactly once inside `doc`, immediately before the level-one
heading for section 4. It inserts a page break and resets the displayed page
number to 1 for sections 4–5. Heading numbering continues from section 3;
the DFG running header and page-limit check switch to the fixed eight-page
supplement allowance. The `dfg-proposal` wrapper checks both parts when
`check-pages` is enabled.

```typst
#show: dfg-proposal.with(doc: [
  = 1 Starting point
  ...
  = 3 Project plan
  ...
  #dfg-supplement()
  = 4 Research data
  ...
  = 5 Ethics
])
```

- arguments: none
-> content: page break and metadata marker used by `dfg-proposal`

<span id="dfg-publications"></span>
### `dfg-publications` ([`dfg-proposal/dfg.typ`](https://github.com/kylekahraman/satz/blob/main/dfg-proposal/dfg.typ))

```text
#let dfg-publications(source: none, size: 9pt, style: "apa", ..args)
```

#### Complete function documentation

<!-- Source docstring included -->



Render the publications bibliography without adding another heading.

Place it under the ordinary level-one publications heading. With
`proposal-citations`, omit `source` and this delegates to
`proposal-publications()`, preserving highlighted entries.

- source (str, none): bibliography path; `none` uses `proposal-citations`
- size (length): bibliography text size, at least 9pt; defaults to 9pt
- style (str): CSL style for a direct `bibliography()` call; defaults to `"apa"`
- ..args: one positional bibliography path or native `bibliography` options

<span id="research-proposal"></span>
### `research-proposal` ([`proposal/template.typ`](https://github.com/kylekahraman/satz/blob/main/proposal/template.typ))

```text
#let research-proposal(
  title: [], applicants: [], institution: [], date: none, summary: none,
  short-title: none, language: "english", config: (:), body,
)
```

#### Complete function documentation

<!-- Source docstring included -->



A general research or project proposal with an inline title and summary.

No funder-specific headings or page limits are imposed; write ordinary
markup. The running header shows the short title and current/total page
numbers from page 1.

```example
#show: research-proposal.with(
  title: [Example proposal],
  applicants: [Alex Example],
  institution: [Example University],
  summary: [We propose a small example.],
)
= Objectives
#lorem(60)
```

- title (content, str): proposal title; defaults to empty
- applicants (content, str): applicant line; defaults to empty
- institution (content, str): institution line; defaults to empty
- date (content, str, none): optional date printed verbatim
- summary (content, none): optional summary block
- short-title (content, str, none): running-header title; `none` reuses `title`
- language (str): `"english"` (default) or `"german"`; controls labels and
  Typst language
- config (dictionary): recursively merged overrides, applied after the
  general proposal preset. Explicit values replace preset values while
  unspecified siblings retain their defaults. The proposal preset is A4,
  25mm margins, 11pt Libertinus Serif, 0.7em paragraph spacing, numbered
  `"1.1"` headings, no automatic contents/figure/table lists, black text and
  links, and a black-on-white page. The running header uses the shared
  `decorative.header-size` (9pt). Supported shared groups and fields are:
  - `page`: `paper` (paper name or custom size; `"a4"`), `margin` (edge
    dictionary; proposal default 25mm on every edge), `binding` (`none` or
    `left`/`right`; default `none`), `binding-correction` (length; `0pt`),
    `headers` (bool; `false`), `columns` (positive integer; `1`),
    `column-gutter` (length; `5mm`).
  - `typography`: `font` (name; `"Libertinus Serif"`), `math-font` and
    `mono-font` (name or `auto`; `auto`), `size` (length; `11pt`),
    `line-spacing` (positive baseline multiple or `none`; `none`),
    `leading` (length; `0.65em`), `paragraph-spacing` (length; proposal
    default `0.7em`), `first-line-indent` (bool; `false`), `hyphenate`
    (bool; `false`), `justify` (bool; `true`).
  - `typography.list-spacing` (non-negative number; `0.5`): additional gap
    between document list items as a fraction of the calculated body
    baseline distance. It follows `typography.line-spacing` when set, or
    font metrics and `typography.leading` otherwise; `0` adds no extra gap.
    Proposal templates do not use this setting for their own layout.
  - `headings`: `numbering` (pattern/function or `none`; proposal default
    `"1.1"`), `hyphenate` (`false`), `h1-pagebreak` (`false`), `spacing`
    (`"koma"` or `"native"`; `"koma"`), and `h1-size` through `h4-size`
    (14pt/12pt/11pt/11pt), `hN-above` and `hN-below` (length or `auto`;
    `auto`).
  - `journal`: `header-below` (1.5em), `running-gutter` (1em),
    `running-leading` (0.35em), `running-header-size` (9pt), `date-size`
    (10pt), and `keywords-size` (9pt); journal-only settings, unused here.
  - `decorative`: `header-size` (9pt), `footer-size` (10pt), `date-size`
    (10pt), and `keywords-size` (9pt). `header-size` styles running text.
  - `page-footer`: `format` (numbering pattern/function; `"1"`), `size`
    (10pt), `weight` (`"regular"`).
  - `line-numbers`: `enabled` (`false`), `format` (`"1"`), `scope`
    (`"document"` or `"page"`; `"document"`), `size` (8pt), `color`
    (`#64748B`), `clearance` (length or `auto`; `auto`).
  - `links`: `color` and `url-color` (colors; proposal defaults both black).
  - `tables`: `stroke` (0.5pt), `inset` ((x: 8pt, y: 4pt)), `font-size`
    (10pt), `caption-position` (`top` or `bottom`; `top`), `caption-gap`
    (6pt).
  - `callouts`: `inset` (9pt), `radius` (3pt), `stroke` (0.8pt),
    `title-below` (1em), `paragraph-spacing` (1em), `list-spacing` (1.2em).
  - `captions`: `size` (10pt), `weight` and `label-weight` (`"regular"`),
    `alignment` (`left`), `hanging` (`true`): caption styling. The proposal uses left alignment.
  - `toc`, `lof`, `lot`: `depth` (proposal default `0`), `title` (content or
    `none`), `indent` (`auto` or length; `auto`), `entry-size` (10pt),
    `leading` (0.65em), `entry-above` (0.65em for toc; 0.85em for lof/lot),
    `title-below` (1.5em), `below` (2em). `toc.main-entry-above` is 1.25em;
    `lof.compact` and `lot.compact` default to false.
  - `bibliography.style` (CSL name; `"apa"`).
  - `colors`: `bg-paper`, `bg-subtle`, `brand-primary`, `brand-accent`,
    `text-main`, `text-muted` (colors; proposal defaults white paper and
    black text/primary accent).
- body (content): proposal sections

<span id="project-proposal"></span>
### `project-proposal` ([`proposal/template.typ`](https://github.com/kylekahraman/satz/blob/main/proposal/template.typ))

```text
#let project-proposal = research-proposal
```

#### Complete function documentation

<!-- Source docstring included -->



Create a general research or project proposal with an inline title and
summary. This is the same layout as `research-proposal`, provided under a
project-oriented name.

- title (content, str): title; defaults to empty
- applicants (content, str): applicant line; defaults to empty
- institution (content, str): institution line; defaults to empty
- date (content, str, none): optional date printed verbatim
- summary (content, none): optional summary block
- short-title (content, str, none): running-header title; defaults to title
- language (str): `"english"` (default) or `"german"`; controls labels and
  Typst language
- config (dictionary): recursively merged over the proposal preset. The
  effective preset is A4, 25mm margins, 11pt Libertinus Serif, 0.7em
  paragraph spacing, `"1.1"` heading numbering, no automatic contents or
  figure/table lists, black text and links, white paper, and a 9pt running
  header. It accepts `page.paper` (paper name/custom size, `"a4"`),
  `page.margin` (edge lengths; 25mm each), `binding` (`none`, `left`,
  `right`), `binding-correction` (0pt), `headers` (false), `columns` (1),
  and `column-gutter` (5mm); `typography.font` (`"Libertinus Serif"`),
  `math-font`/`mono-font` (`auto` or font name; `auto`), `size` (11pt),
  `line-spacing` (positive baseline multiple or `none`; `none`), `leading`
  (0.65em), `list-spacing` (non-negative number; `0.5`, extra list-item gap
  as a fraction of calculated body baseline distance, following line-spacing
  or font metrics plus leading; 0 adds no extra gap), `paragraph-spacing`
  (0.7em), `first-line-indent` (false), `hyphenate` (false), and `justify`
  (true); `headings.numbering`
  (pattern/function or `none`; `"1.1"`), `hyphenate` (false),
  `h1-pagebreak` (false), `spacing` (`"koma"` or `"native"`; `"koma"`),
  and `h1`–`h4` size/above/below fields (14pt/12pt/11pt/11pt, `auto`,
  `auto`). It also accepts `journal.header-below` (1.5em),
  `running-gutter` (1em), `running-leading` (0.35em),
  `running-header-size` (9pt), `date-size` (10pt), `keywords-size` (9pt);
  `weight` (`"regular"`); `line-numbers.enabled` (false), `format` (`"1"`),
  `scope` (`"document"` or `"page"`), `size` (8pt), `color` (`#64748B`),
  `clearance` (auto or length); `links.color` and `url-color` (black in this
  template); `tables.stroke` (0.5pt), `inset` (length or dictionary;
  default `(x: 8pt, y: 4pt)`), `font-size` (10pt), `caption-position`
  (`top` or `bottom`; `top`), `caption-gap` (6pt); `callouts.inset` (9pt),
  `radius` (3pt), `stroke` (0.8pt), `title-below` (1em),
  `weight`/`label-weight` (`"regular"`), `alignment` (`left` in proposals);
  `toc`, `lof`, `lot` depth (0 in this template), title, indent (`auto`),
  entry-size (10pt), leading (0.65em), entry-above (0.65em toc, 0.85em
  figures/tables), title-below (1.5em), and below (2em); `toc` also has
  `main-entry-above` (1.25em), while `lof`/`lot` have `compact` (false);
  `bibliography.style` (`"apa"`); and colors `bg-paper`, `bg-subtle`,
  `brand-primary`, `brand-accent`, `text-main`, `text-muted` (white paper,
  black text and primary accent in this template). Unknown top-level groups
  are retained as extensions. Known shared group keys are validated.
- body (content): proposal sections
-> content: proposal title block, running header, and supplied sections

<span id="proposal-budget"></span>
### `proposal-budget` ([`proposal/components.typ`](https://github.com/kylekahraman/satz/blob/main/proposal/components.typ))

```text
#let proposal-budget(items, language: "english", total-label: none)
```

#### Complete function documentation

<!-- Source docstring included -->



Itemized budget with exact totals.

```example
#proposal-budget((
  (description: [Participant payments], unit-cost: 5000, quantity: 40),
  (description: [Travel], unit-cost: 120000),
))
```

Each row shows quantity × unit cost, subtotal, and a final grand total. All
prices are nonnegative integer cents.

- items (array): records with `description` (str or content), `unit-cost`
  (nonnegative int cents), and optional `quantity` (positive int, default 1)
- language (str): `"english"` (default) or `"german"`; controls labels and
  decimal separator
- total-label (content, str, none): final total label; `none` uses `"Total"`
  or `"Summe"`

<span id="proposal-gantt"></span>
### `proposal-gantt` ([`proposal/planning.typ`](https://github.com/kylekahraman/satz/blob/main/proposal/planning.typ))

```text
#let proposal-gantt(
  rows, periods: 24, unit: "month", start-year: none,
  resources: (), label-width: 40mm, resource-width: 10mm,
  size: 11pt, color: rgb("314158"), language: "english",
)
```

#### Complete function documentation

<!-- Source docstring included -->



A Gantt chart with inclusive, one-based month or quarter intervals.

Wrap it in an ordinary `figure` for a caption, numbering, and reference.
Intervals must not overlap and must stay within `periods`. With
`start-year`, year headings use plain years instead of `Year 1`, `Year 2`.

```example
#figure(
  proposal-gantt((
    (label: [Recruitment], spans: ((1, 6),)),
    (label: [Analysis], spans: ((7, 12),)),
  )),
  caption: [Example timeline],
)
```

- rows (array): records with `label` (str or content), `kind`
  (`"task"` default, `"group"`, or `"milestone"`), `spans` for tasks/groups,
  `at` for milestones, and optional `resources`
- periods (int): number of month or quarter columns; defaults to 24
- unit (str): `"month"` (default) or `"quarter"`
- start-year (int, none): first calendar year; `none` labels years relatively
- resources (array of str, content): optional resource headings
- label-width (length): row-label column width; defaults to 40mm
- resource-width (length): each resource column width; defaults to 10mm
- size (length): chart text size; defaults to 11pt
- color (color): bar and milestone color; defaults to `#314158`
- language (str): `"english"` (default) or `"german"`

<span id="work-package"></span>
### `work-package` ([`proposal/planning.typ`](https://github.com/kylekahraman/satz/blob/main/proposal/planning.typ))

```text
#let work-package(
  title: [], objective: [], lead: none, period: none,
  tasks: (), deliverables: (), milestones: (), risk: none,
  language: "english", body: [],
)
```

#### Complete function documentation

<!-- Source docstring included -->



A numbered, referenceable work-package summary, independent of section numbers.

```example
#work-package(
  title: [Data collection],
  objective: [Collect the pilot sample.],
  tasks: ([Recruit participants], [Acquire data]),
) <wp:data>
// Refer with @wp:data.
```

- title (content, str): work-package title; defaults to empty
- objective (content, str): objective text; defaults to empty
- lead (content, str, none): optional lead partner
- period (content, str, none): optional period text
- tasks (array of content): task list; strings are not accepted
- deliverables (array of content): deliverable list
- milestones (array of content): milestone list
- risk (content, str, none): optional risk and contingency paragraph
- language (str): `"english"` (default) or `"german"`
- body (content): additional content inside the box; defaults to empty

The `work-package` figure kind has its own WP numbering. Attach a label after
the call and reference it with `@wp:label`; no manual WP IDs are needed.

<span id="proposal-citations"></span>
### `proposal-citations` ([`proposal/citations.typ`](https://github.com/kylekahraman/satz/blob/main/proposal/citations.typ))

```text
#let proposal-citations(bib, highlight: (), style: none, body)
```

#### Complete function documentation

<!-- Source docstring included -->



Initialize citations from BibTeX text.

This is an opt-in alternative to native `bibliography()`. Selected keys are
rendered in bold by `proposal-publications()`. Ordinary `@key` citations stay
available, and the BibTeX file is never rewritten.

- bib (str): BibTeX **text**, normally `read("references.bib")`, not a path
- highlight (array of str): unique BibTeX keys to emphasize; defaults to empty
- style (str, none): CSL **XML text**, usually `read("custom.csl")`; `none`
  uses the bundled author-date style
- body (content): document body using this citation backend

Use exactly one `proposal-citations` show rule per document.

<span id="proposal-publications"></span>
### `proposal-publications` ([`proposal/citations.typ`](https://github.com/kylekahraman/satz/blob/main/proposal/citations.typ))

```text
#let proposal-publications(size: 11pt, max-highlight: none)
```

#### Complete function documentation

<!-- Source docstring included -->



Print the opt-in CSL bibliography, automatically bolding selected entries.

Preserves processor-generated bibliography labels and citation hyperlinks.
`max-highlight` is a compilation limit, not truncation: too many highlighted
entries abort compilation. A missing or duplicate `proposal-citations` setup
also fails. NWO Vici full proposals reject any highlighted own publication.
Use `citrus.nocite` to include uncited entries with the CSL backend.

- size (length): bibliography text size; defaults to 11pt
- max-highlight (none, int): maximum highlighted entries printed; `none`
  leaves the count unrestricted

<span id="complaint"></span>
<span id="klageschrift"></span>
### `complaint` / `klageschrift` ([`legal-complaint/template.typ`](https://github.com/kylekahraman/satz/blob/main/legal-complaint/template.typ))

```text
#let klageschrift(
  gericht: none,
  gericht_ort: none,
  klagername: none,
  klagerin_str: none,
  klagerin_plz: none,
  beklagter: none,
  beklagter_str: none,
  beklagter_plz: none,
  streitwert: none,
  anlagen: none,
  anlagen_pdf_path: none,
  anlagen_max_pages: none,
  datum: none,
  court: none,
  court-address: none,
  plaintiff: none,
  plaintiff-street: none,
  plaintiff-postal-code-city: none,
  defendant: none,
  defendant-street: none,
  defendant-postal-code-city: none,
  amount-in-dispute: none,
  exhibits: none,
  exhibits-pdf: none,
  exhibit-page-limit: none,
  date: none,
  plaintiff-designation: none,
  font: "Inter",
  body,
)
```

Defaults resolve to court `"Amtsgericht"`, empty party/value fields, a 30-page
exhibit limit, the compilation date, and `"Kläger/in"`. The output remains
German.

<a id="gastspielvertrag"></a><a id="guest-contract"></a>
### `guest-contract` / `gastspielvertrag` ([`gastspielvertrag/template.typ`](https://github.com/kylekahraman/satz/blob/main/gastspielvertrag/template.typ))

```text
#let gastspielvertrag(
  // Document type
  dokument: none,
  document-type: none,

  // Artist info
  kuenstler: none,
  kuenstler_vertreter: none,
  kuenstler_anschrift: none,
  artist: none,
  artist-representative: none,
  artist-address: none,

  // Event
  veranstaltung: none,
  location: none,
  datum: none,
  auftrittszeit: none,
  auftrittsdauer: none,
  einlass: none,
  curfew: "",
  event: none,
  venue: none,
  date: none,
  performance-time: none,
  performance-duration: none,
  doors: none,

  // Personnel
  musiker: none,
  techniker: none,
  fotograf: none,
  musicians: none,
  technician: none,
  photographer: none,

  // Fee
  gage_typ: none,
  festgage: none,
  prozentsatz: none,
  mindestgage: none,
  kleinunternehmer: none,
  fee-type: none,
  fixed-fee: none,
  percentage: none,
  minimum-fee: none,
  small-business: none,

  // Transport
  transport_km: none,
  transport_satz: none,
  travel-km: none,
  travel-rate: none,

  // Optional costs
  techniker_honorar: none,
  uebernachtung: none,
  sonstiges_text: none,
  sonstiges_betrag: none,
  technician-fee: none,
  accommodation: none,
  other-description: none,
  other-amount: none,

  // Hospitality
  buyout_pro_person: none,
  buyout-per-person: none,

  // Styling
  font: "Inter",

  // Extra content
  body,
)
```

Defaults resolve to `"vertrag"`, placeholder artist details, a fixed fee of 0,
80% of ticket sales when percentage mode is selected, the § 19 VAT note enabled,
30 cents per kilometre, and a 15 EUR hospitality buy-out. The output remains
German.

<a id="journal-entry"></a>
### `journal-entry` ([`journal/template.typ`](https://github.com/kylekahraman/satz/blob/main/journal/template.typ))

```text
#let journal-entry(
  title: "",
  date: "",
  keywords: "",
  body,
  config: (:),
  theme: "neutral",
)
```

#### Complete function documentation

<!-- Source docstring included -->



One journal entry: title, date, keywords, and notes.

You get a heading, date and keyword badges, and a running header that keeps
showing the title and date on later pages. Checklists work with
`- [ ] todo` and `- [x] done`. Journal entries use ISO B5 paper by default.

```example
#journal-index()
#journal-entry(
  title: [Pilot run],
  date: "2026-10-27",
  keywords: "DCM, working memory",
)[
  - [ ] Check the model comparison.
]
```

- title (str): entry title; inserted verbatim
- date (str): `YYYY-MM-DD` or `DD/MM/YY` / `DD/MM/YYYY`, optionally
  preceded by a weekday; empty is allowed for drafts
- keywords (str): comma-separated keywords, e.g. `"MEG, ICA"`; inserted
  verbatim
- body (content): your notes
- config (dictionary): partial nested overrides, deep-merged with journal and shared
  defaults. The shared schema and baseline values are documented once on the exported
  `defaults` dictionary; hover `satz.defaults` when using a namespace import. Journal
  entries use ISO B5 paper, 2cm side margins, and journal-specific metadata and heading
  defaults. See the [configuration reference](/satz/reference/configuration/) for other journal-specific defaults.
- theme (str, none): `neutral` (default), `slate`, `soft-jade`, `soft-slate`, `warm-editorial`,
  `plum`, or `soft-rose`; explicit config overrides win

<span id="journal-index"></span>
### `journal-index` ([`journal/template.typ`](https://github.com/kylekahraman/satz/blob/main/journal/template.typ))

```text
#let journal-index(config: (:), theme: "neutral")
```

#### Complete function documentation

<!-- Source docstring included -->



The index of all entries, grouped by month.

Every `journal-entry` contributes a `<journal-item>`; the index lists date,
title, and page with a dotted line and clickable link. Put the index before
your entries. Typst resolves them at compile time. The fixed heading is
English "Index"; undated entries appear under "Undated"; month headings gain
a year only when the journal spans multiple years.

- config (dictionary): partial nested overrides, deep-merged with journal and shared
  defaults. The shared schema and baseline values are documented once on the exported
  `defaults` dictionary; hover `satz.defaults` when using a namespace import. The index
  uses ISO B5 paper and 2cm side margins; see the [configuration reference](/satz/reference/configuration/) for effective
  values and journal-specific defaults.
- theme (str, none): `neutral` (default), `slate`, `soft-jade`, `soft-slate`, `warm-editorial`,
  `plum`, or `soft-rose`; explicit config overrides win

<span id="remember"></span>
### `remember` ([`journal/components.typ`](https://github.com/kylekahraman/satz/blob/main/journal/components.typ))

```text
#let remember(body)
```

#### Complete function documentation

<!-- Source docstring included -->



A blue box for things you want to keep in mind.

The label and colors are fixed for now, so the box is not theme-aware.

```example
#remember[ICA needs raw, non-interpolated data.]
```

- body (content): the note to retain

<span id="question"></span>
### `question` ([`journal/components.typ`](https://github.com/kylekahraman/satz/blob/main/journal/components.typ))

```text
#let question(body)
```

#### Complete function documentation

<!-- Source docstring included -->



An orange box for open questions.

The label and colors are fixed for now, so the box is not theme-aware. Use it
to keep unresolved questions visible during review.

```example
#question[Why did the EOG check flag component 3?]
```

- body (content): the unresolved question

<span id="report"></span>
### `report` ([`report/template.typ`](https://github.com/kylekahraman/satz/blob/main/report/template.typ))

```text
#let report(body, config: (:), theme: report-defaults.theme)
```

#### Complete function documentation

<!-- Source docstring included -->



A report document class.

- body (content): your text
- config (dictionary): partial nested overrides, deep-merged with the report defaults.
  The shared schema and baseline values are documented once on the exported
  `defaults` dictionary; hover `satz.defaults` when using a namespace import.
  Reports default `figures.placement` to `auto`; use `figures: (placement: none)`
  to keep figures in source order. The report consumes shared page, typography,
  heading, line-number, link, caption, list, and bibliography settings; table
  settings are limited to inset and font-size. It validates but ignores `journal.*`,
  `decorative.*`, `page-footer.format`, the other table fields, `callouts.*`,
  `colors.bg-subtle`, and `colors.brand-accent`. See the [configuration reference](/satz/reference/configuration/) for the full shared schema and effective defaults.
- theme (str): palette applied before `config`, so explicit `config.colors`
  values take precedence. Choices: `neutral` (default), `slate`, `soft-jade`,
  `soft-slate`, `warm-editorial`, `plum`, `soft-rose`; `none` skips the
  named palette.

```example
#show: report.with(
  theme: "neutral",
  config: (
    page: (paper: "a4", margin: (x: 2.5cm, y: 2.5cm)),
    typography: (font: "Libertinus Serif", math-font: auto, size: 11pt),
    headings: (h1-size: 14pt),
    page-footer: (weight: "regular"),
    links: (url-color: blue),
    colors: (brand-primary: navy),
  ),
)
= Introduction
#lorem(100)
```

<span id="article"></span>
### `article` ([`article/template.typ`](https://github.com/kylekahraman/satz/blob/main/article/template.typ))

```text
#let article(title: none, authors: (), affiliations: (), abstract: none, date: none, config: (:), theme: "neutral", body)
```

#### Complete function documentation

<!-- Source docstring included -->



An article with a full-width title/author/abstract block and native columns.

Defaults to two columns, ordinary page numbering, and no automatic front
matter. Set `config: (page: (columns: 1))` for a one-column assignment or
article. Figures can span both columns with `scope: "parent", placement: top`.

```example
#show: article.with(
  title: [A short article],
  authors: ((name: "Alex Example", affiliations: (1,)),),
  affiliations: ("Example Institute",),
  abstract: [We test a small example.],
)
= Introduction
#lorem(80)
```

- title (str, content, none): article title
- authors (dictionary or array): one author record may be passed directly,
  e.g. `authors: (name: "Alex Example")`; multiple authors use an array of
  records, e.g. `authors: ((name: "Alex Example"), (name: "Sam Example"))`.
  Each record has a `name` and optional `affiliations`.
- affiliations (array of str, content): displayed in order. Author records
  reference them with one-based indices, e.g. `affiliations: (1, 2)`.
- abstract (content, none): full-width abstract
- date (str, content, none): optional date beneath the authors
- config (dictionary): partial nested overrides, deep-merged with article and shared
  defaults. The shared schema and baseline values are documented once on the exported
  `defaults` dictionary; hover `satz.defaults` when using a namespace import. Article
  defaults are two columns, 10pt body text, and unnumbered headings. See the
  [configuration reference](/satz/reference/configuration/) for other article-specific defaults.
- theme (str, none): `neutral` (default), `slate`, `soft-jade`, `soft-slate`,
  `warm-editorial`, `plum`, or `soft-rose`; explicit `config.colors` wins
- body (content): the article

<span id="book"></span>
### `book` ([`book/template.typ`](https://github.com/kylekahraman/satz/blob/main/book/template.typ))

```text
#let book(
  body,
  title: none,
  cover-image: none,
  subtitle: none,
  author: none,
  eyebrow: none,
  note: none,
  date: none,
  accent: none,
  ink: none,
  theme: "neutral",
  paper: none,
  margin: none,
  math-font: none,
  font: none,
  font-size: none,
  leading: none,
  paragraph-spacing: none,
  binding: auto,
  binding-correction: none,
  running-headers: "bottom",
  config: (:),
)
```

#### Complete function documentation

<!-- Source docstring included -->



A configurable book with a title page, front matter, contents, and main matter.

Common choices are direct arguments; less common layout details stay available
through `config`. Put preliminary pages before `book-contents()`, then place
numbered chapters inside `book-mainmatter[...]`.

```example
#import "@local/satz:0.2.0": book, book-contents, book-mainmatter
#show: book.with(
  title: [The Maths Behind Your Analysis],
  author: [Your Name],
  accent: teal,
  font: "Georgia",
)

= How to use this book
...
#book-contents()
#book-mainmatter[
  = Chapter one
  ...
]
```

- title (content, none): title shown on the typographic cover; required
  unless `cover-image` supplies a complete cover
- cover-image (str, none): full-page image replacing the typographic cover
- subtitle (content, none): optional subtitle
- author (content, none): author or recipient line
- eyebrow (content, none): small line above the title
- note (content, none): small text near the bottom of the cover
- date (content, none): date near the bottom of the cover
- accent (color, none): heading and component accent; defaults to `#23616B`
- ink (color, none): cover title and chapter-heading color; defaults to `#24313B`
- theme (str, none): `neutral` (default), `slate`, `soft-jade`, `soft-slate`,
  `warm-editorial`, `plum`, or `soft-rose`; direct arguments and `config` win
- font (str, none): body family; `none` keeps `"Libertinus Serif"`
- math-font (str, none): equation family; `none` keeps `"New Computer Modern Math"`
- font-size (length, none): body size; `none` keeps 11pt
- leading (length, none): line-box gap; `none` keeps 0.74em
- paragraph-spacing (length, none): paragraph gap; `none` keeps 14pt
- paper (str, none): paper name; `none` keeps `"a4"`
- margin (dictionary, none): page margins; `none` keeps left 27mm, right
  25mm, top 25mm, bottom 27mm
- binding (auto, alignment, none): inside edge for two-sided pages. `auto`
  keeps the book's left binding; `none` disables two-sided layout
- binding-correction (length): extra room at the binding edge; defaults to 5mm
- running-headers (str): `"bottom"` (default), `"top"`, or `"none"`.
  `config.book.running-headers` takes precedence over this direct argument
- config (dictionary): partial nested overrides, deep-merged after book defaults, the
  selected palette, and direct arguments. The shared schema and baseline values are
  documented once on the exported `defaults` dictionary; hover `satz.defaults` when
  using a namespace import. See the [configuration reference](/satz/reference/configuration/) for book-specific effective
  defaults and extension fields. Explicit `config` values win over direct arguments.
- body (content): preliminary pages and book structure

<span id="book-contents"></span>
### `book-contents` ([`book/template.typ`](https://github.com/kylekahraman/satz/blob/main/book/template.typ))

```text
#let book-contents(title: [Contents], depth: 1)
```

#### Complete function documentation

<!-- Source docstring included -->



Insert a styled contents page at the current location.

This inserts a page break, prints a book-styled title, then renders Typst's
native outline. Links and page numbers update when the document is compiled.
By default only level-one chapter headings appear. Nested heading levels can
be included by increasing `depth`. The appearance follows the active book
style. Its title position and entry typography/spacing are set by
`book.contents.title-before` (24.5pt), `title-after` (26pt),
`title-size` (17pt), `entry-size` (10pt), and `entry-spacing` (11.8pt).
Each field is a length and directly controls the indicated gap or type size;
`book()` config values override these defaults.

```typst
#book-contents(title: [Contents], depth: 2)
#book-mainmatter[
  = First chapter
  == First section
]
```

- title (content, none): contents heading; defaults to `[Contents]`. `none`
  hides the words but retains the configured title spacing.
- depth (int): heading depth to include; defaults to 1 (chapters only).
  Must be a non-negative integer. `0` renders an empty outline below the
  heading; it does not suppress the contents page.
-> content: a page break, styled title, and linked outline

<span id="book-mainmatter"></span>
### `book-mainmatter` ([`book/template.typ`](https://github.com/kylekahraman/satz/blob/main/book/template.typ))

```text
#let book-mainmatter(body, numbering: none)
```

#### Complete function documentation

<!-- Source docstring included -->



Begin the book's numbered main matter on a right-hand page.

This inserts a page break to the next recto page, resets the displayed page
number to Arabic `1`, resets the heading counter, and enables the book footer.
The main matter uses `headings.numbering` (the book default is `"1"`) unless
`numbering` supplies a Typst heading-numbering pattern override. Level-two
headings remain unnumbered.
Place front matter and `book-contents()` before this call; place appendices
or back matter after the main matter.

```typst
#book-contents()
#book-mainmatter[
  = First chapter
  Main text.
]
```

- body (content): chapters in the numbered main matter
- numbering (str, none): optional Typst heading-numbering pattern; `none`
  uses the document's `headings.numbering` (the book default is `"1"`)
-> content: page and heading setup followed by `body`

<span id="book-appendix"></span>
### `book-appendix` ([`book/template.typ`](https://github.com/kylekahraman/satz/blob/main/book/template.typ))

```text
#let book-appendix(body)
```

#### Complete function documentation

<!-- Source docstring included -->



Start lettered appendices while keeping Arabic page numbers.

Resets the heading counter and switches level-one heading numbering to
uppercase letters (`A`, `B`, …). Page numbering remains Arabic and continues
from the preceding content. Figure, table, and equation counters are not
reset or lettered automatically; call `chapter-numbering(appendix: true)`
inside the appendix when those numbers should include appendix letters.
Place appendices after `book-mainmatter`; use `book-backmatter` for any later
unnumbered sections.

```typst
#book-appendix[
  = Supplementary methods
  Appendix content.
]
```

- body (content): one or more appendix chapters, beginning at heading level 1
-> content: appendix heading and page-number setup followed by `body`

<span id="book-backmatter"></span>
### `book-backmatter` ([`book/template.typ`](https://github.com/kylekahraman/satz/blob/main/book/template.typ))

```text
#let book-backmatter(body)
```

#### Complete function documentation

<!-- Source docstring included -->



Begin unnumbered back matter after appendices, solutions, or references.

Inserts a weak page break so existing page flow is preserved when possible,
disables numbering on headings that follow, and keeps Arabic page numbers
with the book footer. It does not reset the page counter or add entries to
the contents. Use this wrapper for material such as acknowledgments, notes,
or a bibliography that should follow the numbered chapters.

```typst
#book-backmatter[
  = Acknowledgments
  Thank you to everyone who helped.
]
```

- body (content): unnumbered back-matter content
-> content: page and heading setup followed by `body`

<span id="book-index"></span>
### `book-index` ([`book/template.typ`](https://github.com/kylekahraman/satz/blob/main/book/template.typ))

```text
#let book-index(
  body,
  title: [Index],
  column-count: 2,
  gutter: 18pt,
  indent: 10pt,
  spacing: 3pt,
)
```

#### Complete function documentation

<!-- Source docstring included -->



Start a fresh, two-column index with hanging entries.

Use one `book-index` call after the references and supply index entries as
paragraphs. The page counter continues from the preceding back-matter page.

- body (content): index entries as paragraphs
- title (content): index heading; defaults to `[Index]`
- column-count (int): number of index columns; defaults to 2
- gutter (length): space between columns; defaults to 18pt
- indent (length): continuation-line indent for each entry; defaults to 10pt
- spacing (length): space between index entries; also sets paragraph
  spacing inside each hanging-indent entry; defaults to 3pt

<span id="exercise"></span>
### `exercise` ([`book/components.typ`](https://github.com/kylekahraman/satz/blob/main/book/components.typ))

```text
#let exercise(body, kind: "Core", grid: none)
```

#### Complete function documentation

<!-- Source docstring included -->



A numbered exercise followed by a writing grid.

Requires the book class; use it inside `book-mainmatter[...]`. Exercise
numbers restart at each numbered level-one heading. Attach a Typst label
immediately after the call when a solution needs to link back to it.

```example
#exercise(kind: "Optional challenge")[
  Derive the standard error from the bootstrap distribution.
] <ex:bootstrap-se>
```

- body (content): the exercise prompt
- kind (str): text in parentheses after the number; defaults to `"Core"`.
  Matching is exact and case-sensitive.
- grid (length, none): answer-space height. `none` uses 20mm for the exact
  kind `"Core"` and 25mm for every other kind.

Book config controls group spacing with `book.exercise.grid-gap` (11pt),
the gap between a prompt and its answer grid, and
`book.exercise.group-gap` (20pt), the gap after each exercise. Both values
are lengths. `grid` overrides only the grid height; these config values
continue to control the surrounding spacing.

<span id="worked-example"></span>
### `worked-example` ([`book/components.typ`](https://github.com/kylekahraman/satz/blob/main/book/components.typ))

```text
#let worked-example(body, above: none, below: none, inset: none)
```

#### Complete function documentation

<!-- Source docstring included -->



A worked example with a restrained label and indented content.

Requires the book class. The right inset is fixed at 20pt and the label is
always "Worked example".

- body (content): worked steps or a short worked calculation
- above (length, none): space before the block; `none` uses
  `config.book.worked-example.above` (26pt)
- below (length, none): space after the block; `none` uses
  `config.book.worked-example.below` (27pt)
- inset (length, none): left inset; `none` uses
  `config.book.worked-example.inset` (27pt). The right inset is fixed at
  20pt.

Book config can also set `book.worked-example.label-gap` (0pt),
`label-size` (9pt), and `body-size` (9pt). These control the gap under the
fixed label and the label/body text sizes. All five values are lengths;
explicit function arguments override the corresponding above/below/inset
config values.

<span id="analysis-note"></span>
### `analysis-note` ([`book/components.typ`](https://github.com/kylekahraman/satz/blob/main/book/components.typ))

```text
#let analysis-note(body, title: [In your analysis])
```

#### Complete function documentation

<!-- Source docstring included -->



A short connection from the current topic to the reader's analysis.

```example
#analysis-note[
  Compare this interval with the bootstrap interval below.
]
```

The block is unbreakable with fixed 8pt space above and below.

- body (content): the connection or prompt
- title (content): heading text; defaults to `[In your analysis]`

<span id="answer-grid"></span>
### `answer-grid` ([`book/components.typ`](https://github.com/kylekahraman/satz/blob/main/book/components.typ))

```text
#let answer-grid(height: 25mm, cell: 5mm, color: none, width: none)
```

#### Complete function documentation

<!-- Source docstring included -->



A square writing grid whose cell size and height can be adjusted.

The grid always fills the available text width. Its lines remain vector
shapes. Despite its name, `width` controls the line thickness; there is no
separate grid-width argument.

- height (length): grid height; defaults to 25mm
- cell (length): square cell edge length; must be positive; defaults to 5mm
- color (color, none): line color; `none` uses the book's fixed grid color
  (`#D2D2D2`)
- width (length, none): line thickness; `none` uses the book's fixed
  0.2pt grid width. Neither default is configurable through `book` config.

<span id="cover-page"></span>
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

#### Complete function documentation

<!-- Source docstring included -->



Build an optional cover page, either from custom content or title fields.

This is a component, not a document template: place it before `report`, or
anywhere else a cover is wanted. It has no implicit connection to another
template's `config` or `theme`; pass those values explicitly when the cover
should share the document appearance.

Appearance precedence is cover defaults, then the selected cover `theme`,
then `config`. `config` may contain normal shared Satz settings, but the
cover consumes only `page.paper`, `page.margin`, `typography.font`,
`typography.size`, and `colors.bg-paper`, `brand-primary`, `brand-accent`,
`text-main`, and `text-muted`. Other valid shared settings are accepted and
ignored. Known config groups are validated for misspelled keys.

The default `classic` layout preserves the slot-based cover. Set `layout` to
`"research"` or `"minimal"` and provide `title` to use a ready-made title page.
The generated title sizes are intentionally part of each preset.

```typst
#let theme = "soft-jade"
#let shared = (typography: (font: "EB Garamond"),)
#cover-page(layout: "research", title: [Field notes], theme: theme, config: shared)
#show: report.with(theme: theme, config: shared)
= Introduction
```

- config (dictionary): partial nested overrides merged after cover defaults and
  selected theme colors. The exported `defaults` dictionary documents the shared
  schema and baseline values. Covers use `page.paper`, `page.margin`,
  `typography.font`, `typography.size`, and `colors.bg-paper`, `brand-primary`,
  `brand-accent`, `text-main`, and `text-muted`; other shared keys are accepted
  and ignored. See the [configuration reference](/satz/reference/configuration/)
  for effective cover values and layout-specific behavior.

<span id="custom"></span>
### `custom` ([`class.typ`](https://github.com/kylekahraman/satz/blob/main/class.typ))

```text
#let custom(
  kind: "report",
  theme: "neutral",
  config: (:),
  header: none,
  footer: none,
  body,
)
```

#### Complete function documentation

<!-- Source docstring included -->



Apply Satz's shared document styling to a document structure you write.

Prefer a named template when its structure fits: `report`, `article`,
`book`, or the journal and proposal templates. Use `custom` when you want
to write the structure yourself while reusing Satz's page, typography,
heading, link, and outline settings.

```example
#show: custom.with(
  kind: "thesis",
  config: (
    typography: (font: "STIX Two Text", math-font: "STIX Two Math", size: 11pt),
    page: (paper: "a5"),
  ),
)
= My document
I choose the structure and content.
```

- kind (str): behavior preset. `"report"` and `"thesis"` add front-matter
  page numbering and automatic contents/LoF/LoT; `"thesis"` is currently
  otherwise identical to `"report"`. `"journal"` disables heading numbering
  and colored internal links. `"article"`, `"book"`, and `"proposal"` add no
  front matter. Defaults to `"report"`.
- config (dictionary): partial nested overrides, deep-merged with the shared defaults.
  The shared schema and baseline values are documented once on the exported `defaults`
  dictionary; hover `satz.defaults` when using a namespace import. The selected `kind`
  changes front matter, numbering, and other behavior; see the [configuration reference](/satz/reference/configuration/)
  for kind-specific defaults.
- theme (str, none): `neutral` (default), `slate`, `soft-jade`, `soft-slate`,
  `warm-editorial`, `plum`, or `soft-rose`. Explicit `config.colors` and
  `config.links` values override the selected palette.
- header (none, content): replaces Satz's automatic running header
- footer (none, content): replaces Satz's automatic alternating page footer
- body (content): your document structure

<span id="satz-figure"></span>
### `satz-figure` ([`class.typ`](https://github.com/kylekahraman/satz/blob/main/class.typ))

```text
#let satz-figure(body, caption: none, short-caption: none, ..args)
```

#### Complete function documentation

<!-- Source docstring included -->



Show a long caption under the figure, a short one in the List of Figures.

Typst's List of Figures normally repeats the full caption. This component
stores the long text as `<satz-long>` metadata and gives the figure the short
caption, so the list stays compact. Satz's document class restores the long
caption when it draws the figure. Without `short-caption`, it behaves like a
normal `figure`.

- body (content): visible figure content
- caption (content, none): long caption shown below the figure
- short-caption (content, none): compact title for the List of Figures
- ..args: native `figure` arguments, including `placement` and `kind`. Pass
  `kind: table` when the body is a table so it enters the List of Tables.

```example
#satz-figure(
  rect(width: 8cm, height: 4cm, fill: luma(230)),
  caption: [Full description spanning several lines.],
  short-caption: [Empirical verification of Picard ICA],
) <fig:results>
```

<span id="citepre"></span>
### `citepre` ([`citation.typ`](https://github.com/kylekahraman/satz/blob/main/citation.typ))

```text
#let citepre(key, pre: none)
```

#### Complete function documentation

<!-- Source docstring included -->



Cite without brackets — `Author Year`, not `(Author, Year)`.

`@key` produces the bracketed form. `citepre` uses only the author and year
parts, optionally preceded by custom content. A `bibliography()` must exist in
the document for the citation to resolve.

```example
#citepre(<smith2020>, pre: [see ])
```

- key (label, str): bibliography key, e.g. `<smith2020>` or `"smith2020"`
- pre (none, content): optional content before the citation, e.g. `[see ]`

<span id="placeholder"></span>
### `placeholder` ([`figures.typ`](https://github.com/kylekahraman/satz/blob/main/figures.typ))

```text
#let placeholder(width: 100%, height: 4cm, label: [Placeholder], config: (:))
```

#### Complete function documentation

<!-- Source docstring included -->



An empty labeled box for a figure that has not been drawn yet.

Use inside `figure` or `satz-figure` for a caption, numbering, and references.
The box itself does not create a figure or a List of Figures entry.

- width (relative, length): box width; defaults to 100%
- height (length): box height; defaults to 4cm
- label (content, str): centered text; defaults to "Placeholder"
- config (dictionary): nested style overrides. The box reads
  `colors.bg-subtle` (white), `colors.text-muted` (black),
  `colors.brand-primary` (black), and `captions.size` (10pt). For example,
  use `config: (colors: (brand-primary: blue), captions: (size: 9pt))`.
  Other valid shared and extension fields are accepted by the merge but do
  not affect the placeholder. The inner inset is fixed at 8pt.

```example
#figure(
  placeholder(width: 80%, height: 4cm, label: [Planned result plot]),
  caption: [Results will be inserted here.],
) <fig:planned>
```

The shared schema and baseline values are documented on the exported `defaults` dictionary. This helper uses only the four fields listed above.

<span id="scientific-table"></span>
### `scientific-table` ([`tables.typ`](https://github.com/kylekahraman/satz/blob/main/tables.typ))

```text
#let scientific-table(columns: 1, header: (), config: (:), ..args)
```

#### Complete function documentation

<!-- Source docstring included -->



Scientific table with repeated column headings and booktabs-style rules.

```example
#scientific-table(
  columns: 2,
  header: ([Method], [Score]),
  [Baseline], [0.71],
  [Proposed], [0.84],
)
```

- columns (positive int or non-empty array): column count or native Typst column widths, such as `(1fr, auto)`; defaults to 1
- header (array): non-empty array of header cells, one per column
- config (dictionary): partial overrides merged over the shared defaults.
  Hover the exported `defaults` dictionary for shared keys, types, meanings, and
  baseline values. This helper reads `tables.stroke`, `tables.inset`, and
  `tables.font-size`; other accepted values do not affect it. The merge helper
  does not validate unknown values.
- ..args: body cells positionally, plus native `table` arguments. Use
  `table.hline()` among the cells for deliberate group separators.

Inside a multi-page figure, also make the enclosing figure block breakable.

<span id="scientific-tables"></span>
### `scientific-tables` ([`tables.typ`](https://github.com/kylekahraman/satz/blob/main/tables.typ))

```text
#let scientific-tables(body, breakable: false, config: (:))
```

#### Complete function documentation

<!-- Source docstring included -->



Apply scientific table-figure layout with a document-level show rule.

Native figures and their labels retain numbering, references, and outlines.

```example
#show: scientific-tables.with(breakable: true)
#figure(table(...), caption: [Long table]) <tab:long>
```

- body (content): the document section whose table figures should be styled
- breakable (bool): allow table figures to continue across pages; defaults
  to false
- config (dictionary): partial overrides merged over the shared defaults.
  Hover the exported `defaults` dictionary for the shared schema. This rule reads
  `tables.caption-gap`, `tables.caption-position`, and `captions.size`; `breakable`
  independently controls whether matching table figures may span pages. Other
  accepted values do not affect this rule. The merge helper does not validate them.

<span id="callout"></span>
### `callout` ([`callouts.typ`](https://github.com/kylekahraman/satz/blob/main/callouts.typ))

```text
#let callout(body, title: none, config: (:), fill: auto, stroke: auto)
```

#### Complete function documentation

<!-- Source docstring included -->



Breakable explanatory box that retains the surrounding body line rhythm.

```example
#callout(title: [Note])[
  This paragraph keeps the document's baseline rhythm.
]
```

- body (content): box content
- title (content, none): optional bold heading inside the box
- config (dictionary): partial overrides merged over the shared defaults.
  Hover the exported `defaults` dictionary for shared keys, types, meanings, and
  baseline values. This helper reads `colors.bg-subtle`, `colors.brand-primary`,
  and `callouts.*`; other accepted values do not affect the callout. The merge
  helper does not validate unknown values.
- fill (color, auto): box fill. `auto` uses `config.colors.bg-subtle`.
- stroke (color, dictionary, none, auto): border. `auto` uses
  `config.colors.brand-primary` with the configured `callouts.stroke`;
  `none` removes the border; a color or stroke dictionary sets it directly.

<span id="chapter-numbering"></span>
### `chapter-numbering` ([`chapter-numbering.typ`](https://github.com/kylekahraman/satz/blob/main/chapter-numbering.typ))

```text
#let chapter-numbering(body, chapter: 1, appendix: false)
```

#### Complete function documentation

<!-- Source docstring included -->



Scope figure, table, and equation numbers to a chapter or appendix.

The chapter number is captured in each element's numbering function, so a
reference from another chapter keeps the target's prefix. Put a chapter's
headings and content inside the scope. `chapter` is manual: nothing reads
the visible heading counter, so pass the chapter number yourself. Heading
numbering and chapter page breaks remain the document class's responsibility.

```example
#chapter-numbering(chapter: 1)[
  = Methods
  #figure(rect(), caption: [First figure]) <fig:methods>
]
#chapter-numbering(chapter: 2)[
  = Results
  See @fig:methods.
]
```

- body (content): headings and content belonging to this chapter
- chapter (int): positive chapter number used in prefixes; defaults to 1
- appendix (bool): use `"A.N"` figure/table prefixes and `"(A.N)"`
  equations, regardless of `chapter`; defaults to false

Only image figures, table figures, and equations are reset. Headings are not
renumbered by this component.

<span id="unnumbered-heading"></span>
### `unnumbered-heading` ([`headings.typ`](https://github.com/kylekahraman/satz/blob/main/headings.typ))

```text
#let unnumbered-heading(body, level: 1, outlined: true)
```

#### Complete function documentation

<!-- Source docstring included -->



Create an unnumbered heading while keeping Satz's normal heading style.

The heading remains in the outline by default, so it appears in the table
of contents. Pass `outlined: false` to keep it out of the outline.

```example
#unnumbered-heading(level: 1)[Acknowledgements]
```

- body (content): the heading text
- level (int): heading level from 1 to 6; defaults to 1
- outlined (bool): include the heading in outlines; defaults to true

<span id="nwo-proposal"></span>
### `nwo-proposal` ([`nwo-proposal/template.typ`](https://github.com/kylekahraman/satz/blob/main/nwo-proposal/template.typ))

```text
#let nwo-proposal(
  scheme: "veni", domain: "science", stage: "pre", year: 2026,
  applicant: [], title: [], config: (:), body,
)
```

#### Complete function documentation

<!-- Source docstring included -->



NWO Talent Programme application layout using an explicit checked profile.

Ordinary headings continue to work. There is no cover, contents, or page
counter reset. Pages have a stable current/total header from page 1. This is
a source-checked authoring aid, not universal submission certification.

```example
#show: nwo-proposal.with(
  scheme: "veni",
  domain: "science",
  stage: "pre",
  applicant: [Alex Example],
  title: [Example research idea],
)
= Key output
#nwo-text("key-output", "A short plain-text response.")
```

- scheme (str): `"veni"` (default), `"vidi"`, or `"vici"`
- domain (str): `"science"` (default), `"ssh"`, `"aes"`, or `"zonmw"`
- stage (str): `"pre"` (default) or `"full"`. In 2026, only Vici full
  proposals are represented; other full-proposal forms fail explicitly
- year (int): source-checked form year; must be 2026
- applicant (content, str): applicant block; defaults to empty
- title (content, str): proposal title; defaults to empty
- config (dictionary): nested Satz overrides merged after shared defaults, NWO defaults,
  and selected profile typography. Explicit values win over profile values. The shared
  schema is documented once on the exported `defaults` dictionary; hover `satz.defaults`
  with a namespace import. Page, typography, heading, list, color, and link defaults vary
  by supported 2026 profile. NWO also supports `page.header-ascent`; see the
  [configuration reference](/satz/reference/configuration/) for effective values.
- body (content): the application sections

<span id="nwo-profile"></span>
### `nwo-profile` ([`nwo-proposal/profiles.typ`](https://github.com/kylekahraman/satz/blob/main/nwo-proposal/profiles.typ))

```text
#let nwo-profile(scheme: "veni", domain: "science", stage: "pre", year: 2026)
```

#### Complete function documentation

<!-- Source docstring included -->



Return the source and constraints for a supported NWO form.

Published 2026 pre-proposals and Vici full proposals are represented.
Unavailable combinations fail explicitly instead of inventing rules.

- scheme (str): `"veni"` (default), `"vidi"`, or `"vici"`
- domain (str): `"science"` (default), `"ssh"`, `"aes"`, or `"zonmw"`
- stage (str): `"pre"` (default) or `"full"`
- year (int): source-checked year; must be 2026
-> dictionary: `scheme`, `domain`, `domain-name`, `stage`, `year`, `source`,
  `size`, and `limits`. `limits` maps each word-limited field to `(min:, max:)`.

<span id="nwo-text"></span>
### `nwo-text` ([`nwo-proposal/components.typ`](https://github.com/kylekahraman/satz/blob/main/nwo-proposal/components.typ))

```text
#let nwo-text(field, response)
```

#### Complete function documentation

<!-- Source docstring included -->



Check a plain-text response against the chosen form's word limits.

Counts whitespace-separated words, then prints the response and its count.
For rich content with figures or citations, use ordinary markup and verify
the full official word count, including all counted material, externally.
Must be called inside `nwo-proposal`.

- field (str): a limit key from the active profile. Pre-proposals use
  `academic-profile`, `key-output`, `research-culture`, `research-idea`, or
  `special-circumstances`; Vici full proposals use `scientific-summary`,
  `public-summary-nl`, or `public-summary-en`
- response (str): plain-text response; rich content is rejected

<span id="nwo-key-output"></span>
### `nwo-key-output` ([`nwo-proposal/components.typ`](https://github.com/kylekahraman/satz/blob/main/nwo-proposal/components.typ))

```text
#let nwo-key-output(reference: [], output-type: [], contribution: [], indicators: (), urls: (), open-access: none)
```

#### Complete function documentation

<!-- Source docstring included -->



A narrative-CV key output with explicit contribution.

Bibliographic reference, URL, type, and indicators are separated from the
narrative so authors can apply the form's exclusions when counting key-output
words. Must be used inside `nwo-proposal`; at most ten key outputs per document.

```example
#nwo-key-output(
  reference: [Example et al. (2026). Example paper.],
  output-type: [Journal article],
  contribution: [Designed the study and analysed the data.],
  urls: ("https://example.org/paper",),
)
```

- reference (content, str): bibliographic reference; defaults to empty
- output-type (content, str): output type; defaults to empty
- contribution (content, str): explicit contribution; defaults to empty
- indicators (array of content, str): up to three indicators
- urls (array of str): up to two URLs (output and open-access copy)
- open-access (bool, none): open-access status; `none` prints "Yes / No"

<span id="nwo-page-budget"></span>
### `nwo-page-budget` ([`nwo-proposal/components.typ`](https://github.com/kylekahraman/satz/blob/main/nwo-proposal/components.typ))

```text
#let nwo-page-budget(key, max-pages: 14, body)
```

#### Complete function documentation

<!-- Source docstring included -->



Check a bounded section's vertical extent, including its own headings.

Use a unique key and include every figure or table inside the scope.
Page-wide floats or placed content escaping the scope need separate visual
review. Fractional limits (e.g. Vici impact 2.5 pages) use the configured
text height. Must be called inside `nwo-proposal`.

- key (str): unique, non-empty section key used for the internal labels
- max-pages (int, float): allowed extent; defaults to 14
- body (content): the bounded section, including headings

### `research-cover` ([`cover.typ`](https://github.com/kylekahraman/satz/blob/main/cover.typ))

```text
#let research-cover = cover-page.with(layout: "research")
```

#### Complete function documentation

<!-- Source docstring included -->



Create a research notebook cover with a neural-connectivity motif.

Render a research title page with a neural-connectivity illustration. The
illustration uses the chosen primary, accent, and paper colors. A following
document does not inherit this cover's theme or config; pass matching values
to both calls if they should share an appearance.

```typst
#research-cover(
  title: [Field notes],
  author: [Alex Example],
  date: "2026",
  theme: "soft-jade",
)
```

- title (content, str): required title; use `box(...)` to keep a word
  together
- subtitle (content, str, none): optional line beneath the title
- author (content, str, none): optional author line
- date (content, str, none): optional date in the title block
- keywords (content, str, none): optional keywords in the title block
- supervisors (array of str, none): optional bottom-left names
- logos (content, none): optional content at the top left
- body (content, none): optional custom cover body; replaces generated fields
- footer (content, none): optional bottom-center content
- footer-left (content, none): optional bottom-left content; replaces
  `supervisors`
- theme (str): `neutral` (default), `slate`, `soft-jade`, `soft-slate`,
  `warm-editorial`, `plum`, or `soft-rose`
- config (dictionary): partial nested overrides merged after cover defaults and
  selected theme colors. The exported `defaults` dictionary documents the shared
  schema and baseline values. Covers use `page.paper`, `page.margin`,
  `typography.font`, `typography.size`, and `colors.bg-paper`, `brand-primary`,
  `brand-accent`, `text-main`, and `text-muted`; other shared keys are accepted
  and ignored. See the [configuration reference](/satz/reference/configuration/)
  for effective cover values and layout-specific behavior.

### `minimal-cover` ([`cover.typ`](https://github.com/kylekahraman/satz/blob/main/cover.typ))

```text
#let minimal-cover = cover-page.with(layout: "minimal")
```

#### Complete function documentation

<!-- Source docstring included -->



Create a spare, centered title page for reports, notes, and short documents.

Render a minimal centered title page. The required title is centered;
optional subtitle and author appear below it. The date is placed at the
bottom unless a custom `footer` replaces it. A following document does not
inherit this cover's theme or config; pass matching values to both calls if
they should share an appearance.

```typst
#minimal-cover(
  title: [Project notes],
  subtitle: [A short working document],
  date: "2026",
)
```

- title (content, str): required cover title
- subtitle, author (content, str, none): optional lines beneath the title
- date (content, str, none): optional bottom date unless `footer` is supplied
- logos (content, none): optional content at top left
- body (content, none): optional custom body; replaces generated fields
- footer (content, none): optional bottom-center content; replaces the date
- footer-left (content, none): optional bottom-left content
- supervisors (array of str, none): optional names at bottom left; replaced
  by `footer-left` when that is supplied
- keywords (content, str, none): accepted but not displayed by this layout
- theme (str): `neutral` (default), `slate`, `soft-jade`, `soft-slate`,
  `warm-editorial`, `plum`, or `soft-rose`
- config (dictionary): partial nested overrides merged after cover defaults and
  selected theme colors. The exported `defaults` dictionary documents the shared
  schema and baseline values. Covers use `page.paper`, `page.margin`,
  `typography.font`, `typography.size`, and `colors.bg-paper`, `brand-primary`,
  `brand-accent`, `text-main`, and `text-muted`; other shared keys are accepted
  and ignored. See the [configuration reference](/satz/reference/configuration/)
  for effective cover values and layout-specific behavior.

<span id="theme-config"></span>
### `theme-config` ([`themes.typ`](https://github.com/kylekahraman/satz/blob/main/themes.typ))

```text
#let theme-config(name, config: (:))
```

#### Complete function documentation

<!-- Source docstring included -->



Select a document palette for any Satz template accepting `config`.

This returns a document palette, not a cover palette. A cover keeps its own
tinted paper unless its `config` explicitly overrides `colors.bg-paper`.

```typst
#let config = theme-config("soft-jade", config: (typography: (size: 11pt)))
```

- name (str, none): one of `neutral`, `slate`, `soft-jade`, `soft-slate`,
  `warm-editorial`, `plum`, or `soft-rose`; `none` returns `config` unchanged
- config (dictionary): nested overrides applied after the palette, so they
  win on matching keys. For example,
  `theme-config("soft-jade", config: (typography: (font: "STIX Two Text"),
  colors: (brand-primary: blue)))`. Theme colors replace the default
  document colors. Non-color keys and groups in `config` pass through
  unchanged; this function does not validate or alter them.

Neutral adds blue links (`#0563C1`); other themes match links to their
primary color. Unknown names fail with the list location.

The shared schema and baseline values are documented once on the exported `defaults` dictionary. This helper passes non-color config fields through unchanged.
