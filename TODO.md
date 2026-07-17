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

## 🚧 v0.2.0 — Planned

- [ ] **Running headers** — section/chapter name in page header for report/thesis. Pattern proven in journal.
- [ ] **Binding correction (BCOR)** — two-sided layout, alternating inner/outer margins for printed theses
- [ ] **DFG proposal** — fix level 2–4 numbering, Arial font, proper 53.01 layout
- [ ] **List of Figures (Abbildungsverzeichnis)** — auto-generated from figure captions
- [ ] **List of Tables (Tabellenverzeichnis)** — auto-generated from table captions
- [ ] **List of Abbreviations (Abkürzungsverzeichnis)** — key-value glossary table
- [ ] **Figure/table caption styling** — configurable prefix, numbering, separator, font size
- [ ] **Abstract environment** — styled abstract block
- [ ] **Author/affiliation block** — name, affiliation, email, ORCID
- [ ] **Article mode** — `kind: "article"`, two-column layout, abstract, author block
- [ ] **Footnote styling** — configurable separator, size, spacing
- [ ] **Letter/invoice unification** — use `personal()` engine for configurable fonts, colors, margins
- [ ] **i18n for invoice** — match letter's `lang: "de"/"en"` pattern
- [ ] **Legal complaint** — German civil court template (Zivilklage)

## 🧪 Later / Maybe

- [ ] **Margin notes** — likely its own package
- [ ] **`\typearea`-style auto-margins** — compute page margins from font size
- [ ] **CI/CD** — `typst compile` on all examples in GitHub Actions

## 📦 Publishing

- [ ] Push to GitHub (`git push --force origin main`)
- [ ] Submit to Typst Universe (`satz` package name confirmed available)
