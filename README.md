# satz

A Typst document class for everyday documents — letters, invoices, reports, journals, and grant proposals.

Inspired by KOMA-Script, **satz** provides a unified configuration system (`defaults.typ` + `class.typ`) with per-template wrapper functions, so all your documents share a consistent look without repeating yourself.

## Quick start: a report

Create `main.typ`, import Satz, and start writing. You do not need to copy a
template file or create a separate configuration file:

```typst
#import "@preview/satz:0.1.1": report
#show: report.with()

= Introduction

Write your report here.

== Background

Continue with ordinary Typst markup.
```

Compile with `typst compile main.typ`, or paste this into a Typst web-app
project for live preview. The report adds numbered headings and contents while
your content remains ordinary Typst. Add configuration only when you need to
change a default.

See the [full report quick start](docs/site/getting-started/report.md) or browse
the [Satz documentation](https://kylekahraman.github.io/satz/) for journal,
letter, figure, table, and layout guides. The site source is in `docs/site/`.

## Quick Usage

### Write a letter in one file

This is a complete `main.typ`; no copied template file or separate `config.typ`
is required. The example uses the local development version, including the
unpublished improvements described below:

```typst
#import "@local/satz:0.1.1": letter
#show: letter.with(
  absender: (name: "Example Author", strasse: "Example Street 1", plz_ort: "12345 Example City"),
  empfaenger: (name: "Example Recipient", strasse: "Sample Road 2", plz_ort: "54321 Sample City"),
  betreff: "Appointment request",
  lang: "en",
)

Dear Example Recipient,

Could we arrange an appointment next week?

Kind regards,
```

`letter` is an alias for `brief`; both currently use German parameter names.
The package supplies the page layout, sender/recipient blocks, date, subject,
and signature line. Write the salutation and closing in the body. For a digital
letter, see the options below; a concise digital preset is still a usability gap.

### Reports and journals

```typst
#import "@preview/satz:0.1.1": report
#show: report.with(config: (
  typography: (font: "Libertinus Serif"),
  lof: (compact: true), // List of Figures shows only "Figure 1 .... 5"
))

= My Report
...
```

```typst
#import "@preview/satz:0.1.1": journal-entry
#show: journal-entry.with(
  title: "Experiment 42",
  date: "2025-03-15",
  keywords: "synthesis, characterization",
)

...
```

## Templates

| Template | Function | Description |
|---|---|---|
| **letter** | `brief(absender, empfaenger, datum, betreff, lang:, body)` | DIN 5008-style postal letter with fold/punch marks; envelope geometry still needs verification. Supports `lang: "de"` / `"en"` for localized labels. Structured recipient fields: `name`, `zusatz`, `strasse`, `plz_ort`, `land`. |
| **invoice** | `rechnung(absender, empfaenger, datum, posten, qr:, qr-betrag:, qr-verwendungszweck:, body)` | German invoice adapted from the letter template. Optional EPC QR code (GiroCode) — banking apps auto-fill transfer details. |
| **journal** | `journal-entry(..)`, `journal-index(..)` | Research diary with entries, keywords, and auto-generated monthly index |
| **report** | `report(body, config: (:))` | Scientific articles, protocols, thesis — numbered headings, auto TOC/LoF/LoT, two-sided layout, bibliography |
| **book (experimental)** | `book(...)`, `book-contents()`, `book-mainmatter[...]`, `book-appendix[...]`, `book-backmatter[...]` | KOMA-Script-inspired book layout with adjustable cover, page furniture, appendices, and optional exercise components |
| **dfg-proposal** | `dfg-proposal(...)`, `dfg-supplement()`, `dfg-publications(...)` | DFG 53.01 (09/26), complete German/English starters, separate page limits and counters (unreleased) |
| **research/project proposal** | `research-proposal(...)` / `project-proposal(...)`, `proposal-budget(...)` | Flexible proposal with inline title/summary, current/total page headers and exact budget totals (unreleased) |
| **legal-complaint** | `klageschrift(...)` | Formal complaint for submission to German courts (ZPO) — Rubrum, Streitwert, Anlagen |
| **gastspielvertrag** | `gastspielvertrag(...)` | Guest performance contract (§1–8, transport, buy-out, 3 doc modes) |
| **cover** | `research-cover(...)`, `minimal-cover(...)`, `cover-page(...)` | Ready-made research/minimal title pages or composable logo/body/footer slots |

Stable: letter, invoice, journal, report, cover, legal-complaint, gastspielvertrag. Experimental: dfg-proposal, article mode, book.

### Letter — Internationalization and PDF applications

The `brief()` function accepts `lang: "de"` (default) or `"en"`:
- Labels for phone, email, date, attachments, page numbers switch language
- Text language is set accordingly for hyphenation rules

The postal layout remains the default. For an application sent as a PDF, the
same `brief()` template can hide envelope-specific components:

```typst
#import "@local/satz:0.1.1": brief

#show: brief.with(
  absender: (name: "Your Name", email: "you@example.org", website: "example.org"),
  empfaenger: (name: "Recipient", zusatz: "University"),
  betreff: "Application for a PhD position",
  lang: "en",
  falzmarken: false,
  adressfenster: false,
  seitenzahlen: false,
  digitaler_absender: true,
  datum_rechts: true,
  blocksatz: false,
  abstaende: (absender_empfaenger: 0.65em),
  signatur: false,
)

Dear Recipient,

Your letter text.
```

`postvermerk: ""` already hides the postal note. `signatur: false` omits the
printed signature line; include a closing in the body when using it. The new
options default to the previous postal behaviour, so existing letters render
as before. The digital options are currently in the local development version;
switch back to `@preview` after publishing a new package version.

The page format, margins, and body text size are configurable with `papier`,
`seitenraender`, and `schriftgroesse`. `zeilenabstand` controls body leading and
the default gaps. `abstaende` accepts partial overrides for
`absender_empfaenger`, `empfaenger_datum`, `datum_betreff`, `betreff_text`,
`datum_text`, and the corresponding `absender_*` / `empfaenger_*` gaps when
earlier blocks are hidden, plus `signatur`. Set
`absender_anzeigen`, `empfaenger_anzeigen`, `datum_anzeigen`, or
`betreff_anzeigen` to `false` to omit those blocks; `betreff_groesse` and
`digitaler_absender_hoehe` adjust the subject size and digital header height.

Use `anlagenverzeichnis: ("Protocol copy", "Schedule copy")` to print an
enclosure list without embedding files. If `anlagen` also contains file paths,
the named list supplies their display labels; without it, the existing path
labels remain the fallback.

### Invoice — EPC QR Code

Set `qr: true` (default) to embed a scannable GiroCode:
- Encodes IBAN, BIC, amount (auto-calculated from line items or overridden via `qr-betrag`), and purpose (`qr-verwendungszweck`)
- Banking apps (e.g. N26, Sparkasse) auto-fill transfer details when scanned

### Cover pages — ready-made layouts or full control

For a research notebook, pass the usual title details directly. No separate
`config.typ` is needed. These helpers are planned for v0.2.0. The import below
uses a local development install; after release, use `@preview/satz:0.2.0`:

```typst
#import "@local/satz:0.1.1": research-cover

#research-cover(
  title: [MEG Connectivity Analysis in #box[Non-Conscious] Working Memory],
  subtitle: "Research Notebook",
  author: "Your Name",
  date: "October 2026",
  supervisors: ("Supervisor One", "Supervisor Two"),
  theme: "soft-jade",
  config: (page: (paper: "iso-b5")),
)
```

Use `minimal-cover` for a centered title page, or `cover-page(layout: "classic", body: [...])`
to keep composing the original logo/body/footer slots. Built-in themes are
`neutral`, `soft-jade`, `soft-slate`, `warm-editorial`, `plum`, and
`soft-rose`. You can still override individual colors with
`config: (colors: (brand-primary: ...))`.

## Structure

satz is built around the shared document class `class.typ:personal()`. It reads defaults from `defaults.typ` and accepts per-document overrides through a `config` dictionary (deep merge — nested dicts are merged, not overwritten).

```
lib.typ              ← public API
defaults.typ         ← unified defaults + merge()
class.typ            ← personal() + satz-figure
citation.typ         ← citepre() — author-year cite without parens
cover.typ            ← cover-page() — logos/body/footer slots
letter/              ← brief() — DIN 5008 letter, i18n (de/en)
invoice/             ← rechnung() — German invoice, EPC QR code
journal/             ← journal-entry / journal-index + remember/question
report/              ← report() — thin wrapper around personal(kind: "report")
dfg-proposal/        ← dfg-proposal — 53.01 (WIP)
legal-complaint/     ← klageschrift — ZPO
gastspielvertrag/    ← gastspielvertrag — guest performance contract
```

## Configuration

Override only what you need — everything else keeps its default:

Pass small overrides directly in the show rule. A reusable `config.typ` is
optional and useful when several documents should share settings. Letters and
invoices currently take direct named options; reports and journals take the
nested `config` dictionary shown here.

```typst
#show: report.with(config: (
  typography: (font: "EB Garamond"),
  colors: (brand-primary: blue),
  lof: (compact: true), // hide caption text in List of Figures
))
```

Available sections (see `defaults.typ` for every key): `page`, `typography`, `headings`, `decorative`, `page-footer`, `links`, `tables`, `captions`, `toc`, `lof`, `lot`, `bibliography`, `colors`.

### Heading and paragraph rhythm

The local development version defaults to shared KOMA-Script heading spacing.
It translates baseline skips using the actual font metrics, including stacked
and wrapped headings. Explicit per-level gaps remain available; set
`headings.spacing: "native"` to opt out. See the
[shared spacing guide](docs/heading-spacing.md). Existing documents can reflow.

Paragraphs default to `paragraph-spacing: 1.2em` and `first-line-indent: 0pt`.
For indented prose with the same line rhythm between paragraphs:

```typst
#show: report.with(config: (typography: (
  leading: 0.65em,
  paragraph-spacing: 0.65em,
  first-line-indent: 1em,
)))
```

Typst's paragraph spacing measures the gap between text edges, so matching it
to `leading` gives continuous line spacing between paragraphs. The first
paragraph after a heading stays unindented. The same config works in journal
entries. See the [native/KOMA typography comparison](examples/latex-parity/README.md)
for the specimen and checks. This change is not yet published.

### Running headers

In the local development version, two-sided reports and theses use
[`hydra:0.6.3`](https://typst.app/universe/package/hydra/) for heading selection:

```typst
#import "@local/satz:0.1.1": report
#show: report.with(config: (page: (binding: left, headers: true)))
```

Even page counters show the chapter at the left; odd counters show the current
section, falling back to the chapter, at the right. Headers use the last relevant
heading on the page, including a section introduced on that page. Chapter-opening
pages have no running header. Unnumbered, outlined chapters participate;
headings with `outlined: false` do not. Headers remain disabled by default.
Custom `personal(header: ...)` content takes precedence.

The existing report page-number offset and counter-based alignment are retained.
See the [paired KOMA-Script comparison](examples/latex-parity/README.md) for
reproducible checks. Hydra also imports `oxifmt:1.0.0`; Typst downloads missing
packages on the first compilation. This integration is not yet published.

### Glossaries and abbreviations

The local development version exports the pinned
[`glossarium:0.5.10`](https://typst.app/universe/package/glossarium/) namespace.
Keep one list of term definitions and install its show rule before the report:

```typst
#import "@local/satz:0.1.1": report, glossarium
#show: glossarium.make-glossary
#show: report

#let terms = (
  (key: "api", short: "API", long: "application programming interface"),
)
#glossarium.register-glossary(terms)

= Introduction
An @api connects programs. The @api is used again here.

= List of abbreviations
#glossarium.print-glossary(terms, disable-back-references: true)
```

First use expands the term; later uses show the abbreviation. Unused terms are
hidden by default; pass `show-all: true` to print them too. Glossarium setup is
optional and its upstream API remains available under the namespace. Importing
satz downloads the package if it is missing; ordinary documents need no glossary
configuration. This integration is not yet published. See
[the complete example](examples/glossary.typ), including ordinary figures,
tables, and short/long captions. Avoid broad `show figure` transformations when
using Glossarium: it uses a special figure kind internally.

For long captions use `satz-figure` — long text under the figure, short title in the List of Figures (or `short-caption: []` for compact):

```typst
#import "@preview/satz:0.1.1": satz-figure
#satz-figure(image("plot.png"), caption: [Very long ...], short-caption: [Short title])
```

### Books and workbooks

The local development version has an experimental `book` entry point for
KOMA-Script-like book authoring: set the title, typeface, and accent once, then
write with ordinary headings. `book-contents`, `book-mainmatter`,
`book-appendix`, and `book-backmatter` mark the document parts. Optional
components add worked examples, analysis prompts, and exercises with answer
grids. See [the complete example](examples/book.typ) and
[the API and layout guide](docs/book-api.md). Its source-PDF measurements and
remaining parity gaps are in [the workbook comparison](docs/book-workbook-parity.md).
The RSA workbook specimen and rebuild instructions are saved in the ignored local
`workbook-conversion/` directory; its source PDF and personal details are not
included in the package.

### Placeholder figures

Draft a report before the illustrations are ready with `placeholder`, available
in the local development version. It draws a labeled empty box using native
Typst, with no additional dependency:

```typst
#import "@local/satz:0.1.1": placeholder

#figure(
  placeholder(width: 80%, height: 4cm, label: [Planned result plot]),
  caption: [Results will be inserted here.],
) <fig:planned>

See @fig:planned.
```

`placeholder()` defaults to the available width, 4cm height, and the label
“Placeholder”. It also works inside `satz-figure` for short/long captions. The
box itself adds no caption, numbering, or outline entry; the surrounding figure
provides those. An optional `config` supplies satz color/caption-style overrides.
See [the complete report example](examples/placeholders.typ).

## License

MIT


### Scientific tables and callouts (unreleased)

The development version exports `scientific-table` and `callout`. A scientific
table has explicit column headings, stronger top/bottom rules and a thinner
header rule. Headings and boundary rules repeat across page breaks. Native
cells, alignment and group separators remain available:

```typst
#import "@local/satz:0.1.1": scientific-table, callout

#scientific-table(
  columns: (1fr, auto),
  align: (left, right),
  header: ([Condition], [Mean]),
  [Baseline], [0.12],
  [Treatment], [0.38],
)

#callout[
  *Main finding*

  Explain the finding here. The box can continue onto the next page.
]
```

Wrap the table in `figure(..., kind: table, caption: [...])` for captions and
references. For a multi-page table figure, also add
`#show figure.where(kind: table): set block(breakable: true)` in its surrounding
scope; ordinary figures are kept together by default. Pass `config:` explicitly
to either helper to share a document palette or override component settings.
The table helper uses `tables.font-size`, `tables.inset` and `tables.stroke`
(the thin rule; boundary rules are 1.6 times thicker). Native table arguments
such as `inset:` can override the helper's padding locally.

See the [complete table example](examples/scientific-table.typ),
[heading and paragraph guide](docs/typography.md), and
[research report parity audit](docs/report-parity-audit.md).
`headings.h1-above` through `h4-below` accept explicit block gaps;
`auto` selects the measured KOMA default. The audit lists remaining differences:
Satz does **not** yet claim complete LaTeX/KOMA parity.
[Unreleased changes](CHANGELOG.md) are being prepared toward 0.2.0;
the manifest remains 0.1.1 and no release has been made.

### Report numbering, captions and fonts (unreleased)

Use `#show: scientific-tables` for scientific table figures with top captions;
pass `breakable: true` only when the enclosing figure should split across pages.
Related native tables can share one figure and caption. See the
[table guide](docs/scientific-tables.md).

Use `chapter-numbering(chapter: 2)[...]` around a chapter to reset figure,
table and equation counters while retaining correct prefixes in references
from other chapters. `appendix: true` selects letter prefixes. This leaves
heading numbering and page breaks to the document; see the
[numbering guide](docs/chapter-numbering.md).

Configuration adds `typography.math-font` and `typography.mono-font`
(both default to `auto`), `captions.alignment`, `captions.label-weight`,
and opt-in `headings.h1-pagebreak`. Callouts accept an attached `title:`.
The [research report audit](docs/report-parity-audit.md) records what was
visually verified and what still differs from LaTeX. These APIs are unreleased.

### Research and grant proposals (unreleased)

Start from the complete [English DFG form](dfg-proposal/example.typ) or
[German DFG form](dfg-proposal/example-de.typ). The 09/26 layout uses Arial,
four numbered heading levels, and separately checked 17/8-page parts. Insert
`dfg-supplement()` before section 4 to restart the header at page 1 of max. 8.
For a proposal with your own structure, use `research-proposal` (also
`project-proposal`); see [the example](proposal/example.typ). Both can use
`proposal-budget` for exact euro-cent calculations. Add `proposal-gantt` for
monthly/quarterly schedules and `work-package` for numbered summaries with
references. See the [planning guide](docs/proposal-planning.md) and
[complete example](examples/proposal-planning.typ).

The [proposal guide](docs/proposals.md) covers imports, bibliography sizing,
budgets, verification and scope. DFG support here covers form 53.01 project
descriptions; other DFG forms are future work. NWO Veni, Vidi and Vici now
have 2026 profiles and starters; see the [NWO guide](docs/nwo-proposals.md)
for the 15 represented scheme/domain/stage combinations and remaining gaps.

### Journal setup and appearance (unreleased)

The [journal starter guide](docs/journal-starter.md) covers a ready-to-edit
project for VS Code and Tinymist on Windows, macOS and Linux. The optional
standalone `journal` command creates entries and opens your editor; users need
no Python, Node, Go, Bash or Make. Cover identity, layout, paper and palette live in one config.

Use `theme:` on journal entries and indexes, or the reusable `theme-config`
helper for other templates. The [journal theme guide](docs/journal-themes.md)
explains the six palettes and keeping config as minimal overrides so updated
Satz defaults can take effect.
