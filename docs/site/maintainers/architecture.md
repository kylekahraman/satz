---
title: "Package architecture"
description: "How Satz exports its Typst templates, shares configuration, and composes document layouts."
---

Satz is a Typst package: a document imports a public function, passes its content and optional settings, and receives Typst content with a consistent layout. The implementation is also written in Typst. There is no runtime service or generated code between the author's source file and the compiled document.

## How a document becomes a Satz document

```text
Author's .typ file
    │ imports a public name
    ▼
lib.typ ── exports the package's public functions
    │
    ├── template function ── semantic inputs + template defaults
    │         │
    │         ├── local components and layout
    │         └── shared config + selected theme
    │                    │
    │                    ▼
    └────────────── personal() in class.typ
                           │
                           ▼
                    Typst content and show rules
                           │
                           ▼
                    Typst compiler → PDF
```

`lib.typ` is the supported import surface. It re-exports names from focused source files and template folders, so a user can write `#import "@preview/satz:0.2.0": report` without importing an internal path. Internal imports use relative paths. A public name is not available to users until `lib.typ` exports it.

## Source map

| File or folder | Responsibility |
| --- | --- |
| `lib.typ` | Public exports and English aliases. |
| `defaults.typ` | Shared config defaults, recursive `merge()`, and validation of known shared settings. |
| `class.typ` | `personal()` applies page geometry, fonts, paragraph rhythm, heading rules, links, outlines, lists, tables, captions, and optional running headers. |
| `heading-layout.typ` | Shared KOMA-inspired heading spacing calculations used by document classes. |
| `themes.typ`, `cover.typ` | Named palettes and reusable cover layouts. |
| `letter/`, `invoice/`, `journal/`, `report/`, `proposal/`, etc. | Public template functions, local defaults, examples, and template-specific components. |
| `examples/latex-parity/` | Small compiled checks for layout behavior, public inputs, date parsing, and selected output details. |
| `docs/site/` | Beginner guides, public reference, and maintainer guidance. |

The `journal/` folder is a compact example of the package model. `journal-entry` validates and presents one entry, records metadata for the index, and delegates shared document styling to `personal(kind: "journal")`. `journal-index` queries the metadata labels and links to entry locations. The date parser is separate so accepted formats and calendar errors can be checked in one place.

## Configuration flow

Shared settings live in `defaults.typ`. A template may add its own defaults, and a theme may supply colors. `merge(base, overrides)` recursively merges nested dictionaries: overriding `colors.brand-primary` leaves other color keys intact. The last override wins.

Keep three kinds of inputs distinct:

- **Document identity** belongs in named template arguments, such as a title, date, sender, or recipient.
- **Shared appearance** belongs in `config` when the setting means the same thing across templates, such as font, page margins, or heading spacing.
- **Local choices** belong on a component or template when they only affect that item, such as an invoice QR option or a callout fill.

Shared validation catches misspelled keys in known groups while allowing template-specific groups and caller extensions. Template-specific input validation belongs close to the public function that understands that input. Read [configuration reference](/satz/reference/configuration/) for the user-facing contract and [API design](/satz/maintainers/api-design/) before adding a setting.

## Document-wide behavior

`personal()` centralizes behavior that should remain consistent within a document: page setup, typography, paragraph spacing, heading styles, links, and lists. It also owns optional table, caption, table-of-contents, and running-header rules. Templates supply their semantic fields and can provide local headers or footers where needed.

Typst evaluates many style rules in document context. Page headers and footers also depend on counters, locations, and document state. The implementation therefore uses `context`, `query`, labels, and counter updates where the result depends on compiled layout. For example, the journal index can link to each entry's final page because Typst resolves the entry label and location during compilation.

These rules make compile checks essential. A source-level change may be valid Typst yet alter a page break, header, or link in a consuming document. Check both compilation and the resulting PDF when changing layout behavior. See [how to contribute](/satz/maintainers/contributing/) for focused checks.

## Design choices and tradeoffs

The shared class is intentionally the central place for document-wide styles; changing it has a wide effect, so keep a representative report or journal compile in the check set. Template folders own their document-specific choices instead of forcing every form into one identical wrapper.

The public surface grew while the package added different kinds of documents. Some functions take body content directly, some are show rules, and some expose German source-compatible argument names alongside English aliases. Those differences are documented and may be reviewed for a major/minor API transition, but a broad rename would break existing documents. The package has no promise of full KOMA-Script compatibility.

The standalone journal starter copies a pinned Satz runtime into the project. That trades automatic updates for portability and stable output: a journal changes templates only when its owner deliberately refreshes the copy. The package itself remains usable without the launcher.

The current design is sound enough to extend. The clearest small consistency gap found in review was that `journal-index` did not validate shared config keys even though `journal-entry` does; this is now checked at the index entry point. Larger changes should follow a demonstrated user need and a compiling example rather than add seams or abstractions preemptively.
