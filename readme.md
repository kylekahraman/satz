# satz

A Typst document class for everyday documents — letters, invoices, reports, journals, and grant proposals.

Inspired by KOMA-Script, **satz** provides a unified configuration system (`defaults.typ` + `personal.typ`) with per-template wrapper functions, so all your documents share a consistent look without repeating yourself.

## Quick Usage

```typst
#import "@preview/satz:0.0.1": *

#show: report.with(config: (
  page: (margin: (left: 3cm)),
  typography: (font: "Gentium Plus"),
))

= My Report
...
```

```typst
#import "@preview/satz:0.0.1": *

#show: journal-entry.with(
  title: "Experiment 42",
  date: "2025-03-15",
  keywords: ("synthesis", "characterization"),
)

...
```

## Templates

| Template | Function | Description |
|---|---|---|
| **letter** | `brief(absender, empfaenger, datum, betreff, lang:, body)` | DIN 5008 conform letter with fold/punch marks. Supports `lang: "de"` / `"en"` for localized labels. Structured recipient fields: `name`, `zusatz`, `strasse`, `plz_ort`, `land`. |
| **invoice** | `rechnung(absender, empfaenger, datum, posten, qr:, qr-betrag:, qr-verwendungszweck:, body)` | German invoice adapted from the letter template. Optional EPC QR code (GiroCode) — banking apps auto-fill transfer details. |
| **journal** | `journal-entry(..)`, `journal-index(..)` | Research diary with entries, keywords, and auto-generated monthly index |
| **report** | `report(body, config: (:))` | Scientific articles, protocols, thesis (article mode, BCOR, TOC planned) |
| **dfg-proposal** | `dfg-proposal(...)` | DFG form 53.01 (Sachbeihilfe) in German and English — **work in progress** |
| **legal-complaint** | — | Formal complaint for submission to German courts (ZPO) — **placeholder** |

### Letter — Internationalization

The `brief()` function accepts `lang: "de"` (default) or `"en"`:
- Labels for phone, email, date, attachments, page numbers switch language
- Text language is set accordingly for hyphenation rules

### Invoice — EPC QR Code

Set `qr: true` (default) to embed a scannable GiroCode:
- Encodes IBAN, BIC, amount (auto-calculated from line items or overridden via `qr-betrag`), and purpose (`qr-verwendungszweck`)
- Banking apps (e.g. N26, Sparkasse) auto-fill transfer details when scanned

## Structure

satz is built around a shared document class defined in `personal.typ`. It reads its defaults from `defaults.typ` and accepts per-document overrides through a `config` dictionary. Each template in its own folder wraps `personal.typ` with the appropriate layout, page geometry, and template-specific parameters.

```
lib.typ              ← re-exports all templates
defaults.typ         ← unified default configuration
personal.typ         ← shared document class
letter/              ← brief() — DIN 5008 letter with i18n
invoice/             ← rechnung() — German invoice with QR code
journal/             ← journal-entry / journal-index
report/              ← report() wrapper
dfg-proposal/        ← dfg-proposal wrapper
legal-complaint/     ← placeholder for German court complaints
cover.typ            ← cover page composable
```

## License

MIT

## Status

Early development. The API is still evolving and may change without notice.
