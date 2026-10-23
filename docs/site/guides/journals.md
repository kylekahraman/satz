---
title: "Keep a research journal"
---

A research journal is useful when each entry records a question, what you did, what you observed, and what you will do next. Satz styles the entry and can build an index from entries in the same document. This tutorial starts with one file; you can split it into a folder later.

## Write one entry

Create `main.typ` and paste this example:

```typst
#import "@preview/satz:0.1.1": journal-entry

#show: journal-entry.with(
  title: "Planning the pilot study",
  date: "Wednesday, 21/10/26",
  keywords: "planning, pilot",
)

== Question

What should the pilot establish before the full study begins?

== Work and observations

Record what I tried, what happened, and any source files or measurements
that will help me reproduce the work.

== Decisions and next steps

- Decision: start with a small equipment check.
- [ ] Confirm the available recording time.
- [ ] Review the procedure with the team.
```

The `journal-entry` show rule styles all content after it. The title, date, and keywords appear in the entry header. Use a date string in `YYYY-MM-DD`, `DD/MM/YY`, or `DD/MM/YYYY` form; a weekday may come before it. The date is text you supply, not an automatic timestamp. An empty date is allowed for a draft and is grouped as “Undated” by the index. Impossible dates such as `31/02/2026` produce an error.

## Put several entries in one document

For a journal with an index, use `journal-entry` as a content function for each entry rather than a show rule for the whole file:

```typst
#import "@preview/satz:0.1.1": journal-entry, journal-index

#journal-index()

#journal-entry(
  title: "Planning the pilot",
  date: "2026-10-21",
  keywords: "planning",
)[
  == Question
  What should the pilot establish?

  == Next step
  Check equipment availability.
]

#journal-entry(
  title: "Pilot results",
  date: "22/10/26",
  keywords: "results",
)[
  == Observation
  Record the result and the next question to investigate.
]
```

`journal-index()` queries the entries in the document, orders them by date, and groups entries by month. Put the index before the entries. To add an entry, copy one entire `#journal-entry(...)[...]` block and change its fields and content. Labels and notes can use normal Typst markup.

## Adjust the page and typography

Each entry and the index accept a `config` dictionary. For example, a smaller paper size and different font can be set like this:

```typst
#let journal-config = (
  page: (paper: "iso-b5"),
  typography: (font: "Libertinus Serif", size: 11pt),
)
#journal-index(config: journal-config)
#journal-entry(
  title: "Equipment check",
  date: "2026-10-23",
  config: journal-config,
)[Notes from the equipment check.]
```

Use the same config for the index and each entry to keep their page and type settings consistent. `typography.line-spacing` sets baseline distance as a multiple of the font size when available in the version you use; `typography.leading` controls the line gap directly. The [configuration reference](/satz/reference/configuration/) explains each field and default. The [API reference](/satz/reference/api/#journal-entry) lists entry and index arguments.

## Split entries into files when the journal grows

Make one `.typ` file per entry under a folder such as `entries/`, then include those files in `main.typ` after the index. For example:

```typst
#import "@preview/satz:0.1.1": journal-entry, journal-index
#journal-index()
#include "entries/2026-10-21-pilot.typ"
#include "entries/2026-10-22-results.typ"
```

Each entry file should import `journal-entry` and contain one complete `#journal-entry(...)[...]` call. Keep the project folder and its relative paths together when moving the journal to another computer.

## Starter and launcher

The repository also contains a modular journal starter and a standalone launcher for Windows, macOS, and Linux. These are development tools, not part of the published `0.1.1` package. See [Development versions](/satz/guides/development/) before using them. The one-file and multi-entry examples above only need the published package.
