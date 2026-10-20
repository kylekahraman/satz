# Configuration

Most templates accept a `config` dictionary. Pass only the settings you want to change; nested settings are merged with defaults.

```typst
#import "@preview/satz:0.1.1": report

#show: report.with(config: (
  typography: (
    font: "Libertinus Serif",
    size: 11pt,
    leading: 0.75em,
    paragraph-spacing: 1em,
  ),
  page: (paper: "a4", margin: 25mm),
  colors: (brand-primary: blue),
))
```

This keeps the rest of the report defaults. For multiple documents, put the dictionary in `config.typ` and pass it to each document.

## Main configuration groups

| Group | Controls |
| --- | --- |
| `page` | Paper, margins, binding, columns, and column gutter |
| `typography` | Body font, size, leading, paragraph spacing and indentation, justification, and hyphenation |
| `headings` | Numbering, size, and spacing for four levels |
| `page-footer` | Page number format, size, and weight |
| `links` | Link colors |
| `tables` | Table rule, font size, and cell inset |
| `captions` | Caption size, text weight, alignment, and label weight |
| `toc`, `lof`, `lot` | Contents and figure/table list depth, spacing, and compact entries |
| `colors` | Shared palette |

The exact keys and defaults are documented in the [source defaults](https://github.com/kylekahraman/satz/blob/main/defaults.typ). Some document details belong as direct template arguments, and a few components accept their own local options.

## Template data and appearance

Use direct arguments for content that defines the document, such as a letter's recipient or a journal entry's date. Use `config` for appearance shared across the document. Use component options for local behavior, such as a figure's short caption. This division is the current direction; older templates have some historical differences.

Features marked development-only in the changelog may appear in the repository before they are available in the published package.
