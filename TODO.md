# satz — Roadmap & TODO

## ✅ v0.1.0 — Done

- [x] **Letter** — DIN 5008, i18n (de/en), structured recipient, fold/punch marks, Postvermerk, configurable font
- [x] **Invoice** — EPC QR code (GiroCode), line-item table, kleinunternehmer toggle, configurable font
- [x] **Journal** — entries with keywords, running headers, monthly index, checklist (cheq)
- [x] **Report** — numbered headings, bibliography, link styling, auto-generated Table of Contents
- [x] **Cover page** — logos, footer, centered layout
- [x] **Config system** — deep merge, type-safe defaults, per-template defaults
- [x] **Docs** — `///` doc comments on all public functions, MIT license, README
- [x] **Bug fixes** — Typst 0.15 scoping (set/show in if blocks), merge reference mutation, DIN date format
- [x] **Security** — all examples use placeholder text, no PII in repo

## ✅ v0.1.1 — Done (2026-09-01)

- [x] **Letter/invoice unification** — invoice imports absender_block, empfaenger_block, geschaeftszeile_block from letter. Rechnung.typ reduced 254→145 lines.
- [x] **Invoice components extracted** — `invoice/components.typ` (absender_block, posten_table, bank_qr_block, kleinunternehmer_notice, build_epc_string)
- [x] **Shared absender_block** — supports zusatz (c/o), logo (two-column grid), height constraint for window envelopes
- [x] **Structured empfaenger** for invoice — dict with name, zusatz, strasse, plz_ort, land
- [x] **Return address fix** — zusatz included in window-envelope return line (letter + invoice)
- [x] **Font parameter** — letter + invoice: `font: "Inter"` configurable
- [x] **English aliases** — `letter` and `invoice` in lib.typ (alongside `brief` and `rechnung`)
- [x] **kontoinhaber** — separate from absender.name for bank account holder
- [x] **BIC removed** from visible document (SEPA doesn't require it; still in QR code data)
- [x] **Zahlungsziel** merged into bank transfer text
- [x] **Invoice Geschäftszeile** — matches letter's DIN 5008 `stack(spacing: 1fr)` layout
- [x] **Postvermerk alignment** — left-aligned in address field (not right)
- [x] **Kleinunternehmer toggle** — `kleinunternehmer: true/false` shows/hides § 19 UStG
- [x] **8 public exports** in lib.typ: brief/letter, rechnung/invoice, dfg-proposal, klageschrift, gastspielvertrag, journal-entry, journal-index, report, cover-page
- [x] **satz-figure + LoF/Lot compact** — `satz-figure(caption:, short-caption:)` decouples display vs outline via `<satz-long>` metadata; `lof.compact`/`lot.compact` global flag shows only `Figure 1 .... 5`; outline links uniform black
- [x] **Link/outline polish** — ToC/LoF/Lot text `c.colors.text-main` (no fancy red in outlines), body links keep `c.links.color`
- [x] **List spacing** — `decorative.list-spacing` (`list` + `enum` unified, Word-like "Abstand nach Absatz")

## 🚧 v0.2.0 — Planned

### Next priorities

1. **Report as the shared foundation** — keep improving typography and general document behavior for theses, assignments, and ordinary reports. The first native-heading/paragraph-spacing pass is complete; extend automatic-pagination and bibliography coverage next.
2. **Simple document/article entry points** — provide intentional defaults for ordinary documents and inline title/contents behavior without report-specific workarounds. Preserve the existing API while improving the shortest authoring path.
3. **Journal quality and onboarding** — validate shared changes in real entries, improve the entry/index workflow, and provide a concise starting point. Letter parity remains secondary backlog work.

See [the quality and usability assessment](docs/document-quality.md) for current coverage, dependency fit, and acceptance criteria.

### Work items

- [ ] **Basic document entry point** — provide a simple, unnumbered, no-TOC starting point for ordinary documents such as notes, lists, and link collections
- [x] **Native heading rhythm** — remove nested heading blocks and the forced h1 gap, increase default space below headings, expose paragraph spacing/indentation, and verify native flow plus page-edge cases in `examples/latex-parity/check_typography.py`
- [x] **Inline config quick start** — README explains optional `config.typ`, inline overrides, and a complete one-file letter using the existing public API
- [ ] **Journal onboarding** — make a new research journal straightforward to set up, with a copyable starter example and clear instructions for entries, the index, and customization
- [x] **Cover page presets** — preserve the composable cover API and add ready-made classic, research, and minimal layouts with neutral, jade, slate, warm, plum, and rose themes
- [ ] **Table authoring and styling** — make attractive tables easy to create with sensible defaults and reusable helpers; include examples for common table layouts
- [x] **Dependency review** — [initial package assessment](docs/package-research.md) and [additional candidates](docs/additional-packages.md); integration remains incremental
- [ ] **LaTeX reference collection** — paired KOMA-Script/satz ordinary document, report/thesis extract, and letter; compare typography and authoring effort using [the parity plan](docs/latex-parity.md)
  - [x] First source/PDF recreations: official KOMA-Script letter and commentary article, with reproducible builds and documented gaps in [examples/latex-parity](examples/latex-parity/README.md)
  - [x] Original 12-page KOMA-Script/satz comparison: headers, front matter, simple top floats, cross-references, and override checks
  - [ ] Extend the report pair with bibliography and automatic pagination cases
- [ ] **Package integration trials** — assess Hydra for running headers, Glossarium for glossary/abbreviations, Tidy for the API manual, and optional Tschich/Meander layouts; see [the package review](docs/package-research.md)
  - [x] Hydra running headers and Glossarium abbreviation-list workflow compiled and checked through satz
  - [ ] Tidy manual generation; compare Zero/Pillar on representative tables before selecting a table API
- [x] **Binding correction (BCOR)** — two-sided layout implemented in `class.typ:79-103` (binding → inside/outside margins, alternating footers, running headers parity fix). Needs visual QA on printed book.
- [x] **Running headers** — Hydra 0.6.3 replaces custom chapter/section state; chapter openings stay blank, sections update on their starting page, section-free chapters fall back correctly. Toggle `page.headers: true` with binding enabled; verified against the paired KOMA-Script report.
- [ ] **DFG proposal** — fix level 2–4 numbering, Arial font, proper 53.01 layout
- [x] **List of Figures (Abbildungsverzeichnis)** — auto-generated from figure captions
- [x] **List of Tables (Tabellenverzeichnis)** — auto-generated from table captions
- [x] **List of Abbreviations (Abkürzungsverzeichnis)** — optional Glossarium 0.5.10 namespace via satz, term dictionaries, first-use expansion, linked references, and printable abbreviation list; see `examples/glossary.typ`
- [x] **Figure/table caption styling** — configurable prefix, numbering, separator, font size
- [ ] **Abstract environment** — styled abstract block
- [ ] **Author/affiliation block** — name, affiliation, email, ORCID
- [ ] **Article mode** — `kind: "article"`, two-column layout, abstract, author block
- [ ] **Footnote styling** — configurable separator, size, spacing
- [ ] **i18n for invoice** — match letter's `lang: "de"/"en"` pattern
- [x] **Named letter enclosures** — render `anlagenverzeichnis` even when no files are embedded; regression verified in `examples/latex-parity/check_letter.py`
- [x] **Legal complaint (Klageschrift)** — ZPO civil court template with Rubrum, Streitwert, Anlagen
- [x] **Gastspielvertrag** — guest performance contract, fill-in blanks, 3 doc modes, §1–8, transport calc, buy-out

> **Note:** Counter parity fix resolved — `counter(page).update(1)` → `update(2)`, so the first content page after a TOC displays correctly in two-sided layout (see AGENTS.md, "Page counter ordering matters").

## 🧪 Later / Maybe

- [ ] **Margin notes** — likely its own package
- [ ] **`\typearea`-style auto-margins** — compute page margins from font size
- [ ] **Signature helper for letters** — `signature(name, rolle: none)` composable block: underline for signing + name + optional role beneath. Support multiple stacked signatures. Currently users must define this themselves with `signatur: false` on brief().
- [ ] **CI/CD** — `typst compile` on all examples in GitHub Actions

## 📦 Publishing

- [ ] Push to GitHub (`git push --force origin main`)
- [ ] Submit to Typst Universe (`satz` package name confirmed available)
