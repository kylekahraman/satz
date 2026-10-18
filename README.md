# satz

A Typst document class for everyday documents — letters, invoices, reports, journals, and grant proposals.

Inspired by KOMA-Script, **satz** provides a unified configuration system (`defaults.typ` + `class.typ`) with per-template wrapper functions, so all your documents share a consistent look without repeating yourself.

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
| **dfg-proposal** | `dfg-proposal(...)` | DFG form 53.01 (Sachbeihilfe) in German and English — **work in progress** |
| **legal-complaint** | `klageschrift(...)` | Formal complaint for submission to German courts (ZPO) — Rubrum, Streitwert, Anlagen |
| **gastspielvertrag** | `gastspielvertrag(...)` | Guest performance contract (§1–8, transport, buy-out, 3 doc modes) |
| **cover** | `research-cover(...)`, `minimal-cover(...)`, `cover-page(...)` | Ready-made research/minimal title pages or composable logo/body/footer slots |

Stable: letter, invoice, journal, report, cover, legal-complaint, gastspielvertrag. Experimental: dfg-proposal, article mode.

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

The local development version styles native headings directly. It removes the
extra gap inside level-one headings and provides more space below all four
configured heading levels. Native spacing above headings, page-start trimming,
and attachment to following content remain in effect. Existing `h1-below`
through `h4-below` overrides still work; `em` lengths are resolved in the native
heading's text context. These intentional default changes can alter pagination.

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
