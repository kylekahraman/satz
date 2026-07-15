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
| **german-letter** | `brief(...)` | DIN 5008 conform German letter with fold/punch marks |
| **german-invoice** | `rechnung(...)` | German invoice adapted from the letter template |
| **journal** | `journal-entry(..)`, `journal-index(..)` | Research diary with entries, keywords, and auto-generated monthly index |
| **report** | `report(body, config: (:))` | Scientific articles, protocols, thesis (article mode, BCOR, TOC planned) |
| **dfg-proposal** | `dfg-proposal(...)` | DFG form 53.01 (Sachbeihilfe) in German and English — **work in progress** |
| **german-legal-complaint** | — | Formal complaint for submission to court / counsel — **planned** |

## Structure

satz is built around a shared document class defined in `personal.typ`. It reads its defaults from `defaults.typ` and accepts per-document overrides through a `config` dictionary. Each template in its own folder wraps `personal.typ` with the appropriate layout, page geometry, and template-specific parameters.

```
lib.typ                 ← re-exports all templates
defaults.typ            ← unified default configuration
personal.typ            ← shared document class
german-letter/          ← brief wrapper
german-invoice/         ← rechnung wrapper
journal/                ← journal-entry / journal-index
report/                 ← report wrapper
dfg-proposal/           ← dfg-proposal wrapper
cover.typ               ← cover page composable
```

## License

MIT

## Status

Early development. The API is still evolving and may change without notice.
