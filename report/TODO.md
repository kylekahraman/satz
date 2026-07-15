# satz — Roadmap & TODO

## ✅ Done (v0.1.0)

- [x] **DIN 5008 letter** with i18n (de/en), structured recipient, fold/punch marks, Postvermerk
- [x] **Invoice** with EPC QR code (GiroCode), line item calculation, kleinunternehmer toggle
- [x] **Journal** with entries, keyword tags, running headers, monthly index, checklist support
- [x] **Report** with numbered headings, bibliography, link styling, auto Table of Contents
- [x] **Cover page** with logos, footer, configurable layout
- [x] **Deep merge** config system — override one color without losing the rest
- [x] **Doc comments** on all public functions
- [x] Configurable font for letter and invoice (`font` parameter)
- [x] Date format: DIN 5008 YYYY-MM-DD (overridable)
- [x] Typst 0.15 scoping fix (set/show rules in if blocks)
- [x] Merge mutation bug fix (reference vs copy)
- [x] All examples use placeholder text — no real names or PII

## 🔧 In Progress (v0.2.0)

- [ ] **DFG proposal** — fix level 2–4 numbering, Arial font requirement, proper 53.01 form layout

## 📋 Planned (v0.3.0+)

### Running headers
- Show section/chapter name in page header for report/thesis
- Configurable: `header.show`, `header.text: "auto" | "chapter" | "custom"`
- Pattern: similar to journal header (uses Typst state tracking)

### Binding correction (BCOR)
- Double-sided layout for printed theses
- Alternating inner/outer margins
- Page numbers on outside edges
- Config: `page.binding: none | auto | length`

### Article mode
- Config flag: `kind: "article"`
- No chapter numbering, author + affiliation block, abstract
- Optional two-column layout: `columns: 1 | 2`

### Abstract environment
- Show rule on `= Abstract` heading for styled abstract block

### Author/affiliation frontmatter
- Author block with name, affiliation, email, ORCID

### Footnote styling
- Configurable footnote separator, size, spacing

## 🧪 Experiments / Maybe

- **Margin notes** — `kind: "book"` or extend report with configurable margin width
- **Letter/invoice unification** — use `personal()` engine for configurable fonts, colors, margins
- **i18n for invoice** — match letter's `lang: "de"/"en"` pattern
- **Legal complaint** — German court template (Zivilklage)
- **Table/figure caption styling** — configurable formatting, prefix, numbering

## 📦 Publishing

- [ ] Push to GitHub (`git push --force` after PII purge)
- [ ] Submit to Typst Universe (package name `satz` confirmed available)
- [ ] CI/CD: `typst compile` on all examples
