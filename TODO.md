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

## ✅ v0.1.1 — Done (this session)

- [x] **Letter/invoice unification** — invoice imports absender_block, empfaenger_block, geschaeftszeile_block, signatur_block from letter. Rechnung.typ reduced 254→145 lines.
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

## 🚧 v0.2.0 — Planned

- [ ] **Running headers** — section/chapter name in page header for report/thesis
- [ ] **Binding correction (BCOR)** — two-sided layout, alternating inner/outer margins
- [ ] **DFG proposal** — fix level 2–4 numbering, Arial font, proper 53.01 layout
- [ ] **List of Figures (Abbildungsverzeichnis)** — auto-generated from figure captions
- [ ] **List of Tables (Tabellenverzeichnis)** — auto-generated from table captions
- [ ] **List of Abbreviations (Abkürzungsverzeichnis)** — key-value glossary table
- [ ] **Figure/table caption styling** — configurable prefix, numbering, separator, font size
- [ ] **Abstract environment** — styled abstract block
- [ ] **Author/affiliation block** — name, affiliation, email, ORCID
- [ ] **Article mode** — `kind: "article"`, two-column layout, abstract, author block
- [ ] **Footnote styling** — configurable separator, size, spacing
- [ ] **i18n for invoice** — match letter's `lang: "de"/"en"` pattern
- [x] **Legal complaint (Klageschrift)** — ZPO civil court template with Rubrum, Streitwert, Anlagen
- [x] **Gastspielvertrag** — guest performance contract, fill-in blanks, 3 doc modes, §1–8, transport calc, buy-out

## 🧪 Later / Maybe

- [ ] **Margin notes** — likely its own package
- [ ] **`\typearea`-style auto-margins** — compute page margins from font size
- [ ] **CI/CD** — `typst compile` on all examples in GitHub Actions

## 📦 Publishing

- [ ] Push to GitHub (`git push --force origin main`)
- [ ] Submit to Typst Universe (`satz` package name confirmed available)
