---
title: "Configuration"
---

Most templates accept a `config` dictionary. Pass only the settings you want to change; nested settings are merged with defaults.

```typst
#import "@preview/satz:0.1.1": report

#show: report.with(config: (
  typography: (
    font: "Libertinus Serif",
    size: 11pt,
    leading: 0.75em,
  ),
  page: (paper: "a4", margin: 25mm),
  colors: (brand-primary: blue),
))
```

This keeps the rest of the report defaults. A separate `config.typ` is optional. Keep settings at the top of `main.typ` until sharing them across files becomes useful.

## Main configuration groups

| Group | Controls |
| --- | --- |
| `page` | Paper, margins, and binding (columns and gutter: development) |
| `typography` | Body font, size, leading, justification, and hyphenation (paragraph spacing and indentation: development) |
| `headings` | Numbering, size, and spacing for four levels |
| `page-footer` | Page number format, size, and weight |
| `links` | Link colors |
| `tables` | Table rule, font size, and cell inset |
| `captions` | Caption size, text weight, alignment, and label weight |
| `toc`, `lof`, `lot` | Contents and figure/table list depth, spacing, and compact entries |
| `colors` | Shared palette |

The exact keys and defaults are documented in the [published defaults](https://github.com/typst/packages/blob/main/packages/preview/satz/0.1.1/defaults.typ). Some document details belong as direct template arguments, and a few components accept their own local options.

## Template data and appearance

Use direct arguments for content that defines the document, such as a letter's recipient or a journal entry's date. Use `config` for appearance shared across the document. Use component options for local behavior, such as a figure's short caption. This division is the current direction; older templates have some historical differences.

Features marked development-only in the changelog may appear in the repository before they are available in the published package.

## Line and paragraph spacing

`typography.leading` is the space between the bottom of one text line and the top of the next. It is not a LaTeX line-spacing multiplier. For paragraph spacing in the published package, use native Typst `set par(spacing: ...)` after the show rule. The development version also exposes `typography.paragraph-spacing` in its configuration. Change these independently:

```typst
#import "@preview/satz:0.1.1": report
#show: report.with(config: (
  typography: (leading: 0.75em),
))
#set par(spacing: 1em)

= Notes

The first paragraph of the report.

A second paragraph, separated by the paragraph spacing.
```

An `em` follows the current font size. The rendered rhythm also depends on the font's metrics, so inspect the PDF when changing fonts. Keep the default heading spacing first; adding blank lines in the source does not create extra heading gaps.

## Named palettes and cover styles

**Development:** the source version provides `neutral`, `soft-jade`, `soft-slate`, `warm-editorial`, `plum`, and `soft-rose`. Journals accept a `theme` argument directly. For other templates accepting `config`, pass `theme-config("plum")` as their configuration; explicit overrides can be supplied to that helper. These shared palettes are not limited to cover pages.

Development cover pages also offer `classic`, `minimal`, and `research` layouts. A preset is a starting point: you can supply your own cover content, logos, or footer. See [the source cover API](https://github.com/kylekahraman/satz/blob/main/cover.typ) and [development setup](/satz/guides/development/).
