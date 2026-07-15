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

## 🔧 v0.2.0 — Next

- [ ] **Running headers** for report/thesis — section/chapter name in page header. Pattern proven in journal template.
- [ ] **Binding correction (BCOR)** — two-sided layout, alternating inner/outer margins for printed theses
- [ ] **DFG proposal** — fix level 2–4 numbering, Arial font, proper 53.01 layout
- [ ] **Force push** clean history to GitHub

## 📋 v0.3.0 — Lists & Frontmatter

- [ ] **List of Figures (Abbildungsverzeichnis)** — auto-generated from figure captions
- [ ] **List of Tables (Tabellenverzeichnis)** — auto-generated from table captions
- [ ] **List of Abbreviations (Abkürzungsverzeichnis)** — key-value glossary table
- [ ] **Figure/table caption styling** — configurable prefix, numbering, separator, font size
- [ ] **Abstract environment** — styled abstract block (show rule on `= Abstract` / `= Zusammenfassung`)
- [ ] **Author/affiliation block** — name, affiliation, email, ORCID for articles

## 📋 v0.4.0 — Article & Publication

- [ ] **Article mode** — `kind: "article"`, author block, abstract, optional two-column layout
- [ ] **Footnote styling** — configurable separator, size, spacing, numbering format
- [ ] **Letter/invoice unification** — use `personal()` engine so font, colors, margins are configurable
- [ ] **i18n for invoice** — match letter's `lang: "de"/"en"` pattern

## 🧪 Later / Maybe

- [ ] **Legal complaint** — German civil court template (Zivilklage)
- [ ] **Margin notes** — likely its own package; too complex for satz core
- [ ] **`\typearea`-style auto-margins** — compute page margins from font size (KOMA-Script classic)
- [ ] **CI/CD** — `typst compile` on all examples in GitHub Actions

## 📦 Publishing

- [ ] Push to GitHub (`git push --force origin main`)
- [ ] Submit to Typst Universe (`satz` package name confirmed available)
