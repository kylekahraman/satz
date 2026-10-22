---
title: "Start a research journal"
---

A journal keeps your questions, decisions, results, and next steps together. Start with one file. You can add a cover and separate entry files later.

## Your first entry

Create `main.typ` and paste this:

```typst
#import "@preview/satz:0.1.1": journal-entry

#show: journal-entry.with(
  title: "Planning the pilot study",
  date: "Wednesday, 21/10/26",
  keywords: "planning, pilot",
)

== Goal

Decide what the pilot should answer.

== Notes

Record what I tried and why.

== Next steps

- [ ] Check the equipment.
- [ ] Discuss the plan with a colleague.
```

The title and date belong to the entry. Use `==` for sections inside it. Checkboxes use `- [ ]` and `- [x]`. The monthly index accepts `DD/MM/YY`, `DD/MM/YYYY`, or ISO `YYYY-MM-DD`, optionally preceded by a weekday (with a comma or space). Empty dates are allowed for drafts and appear under “Undated”. Invalid calendar dates fail with a field-specific error. Dates are text you supply; this basic example does not insert today's date automatically.

## Keep several entries in one file

Use a content block for each entry instead of applying one show rule to the whole file. This is a complete second starting point:

```typst
#import "@preview/satz:0.1.1": journal-entry, journal-index

#journal-index()

#journal-entry(
  title: "Planning the pilot",
  date: "Wednesday, 21/10/26",
  keywords: "planning",
)[
  == Goal
  Decide what the pilot should answer.
]

#journal-entry(
  title: "Pilot results",
  date: "Thursday, 22/10/26",
  keywords: "results",
)[
  == Findings
  Record the results and the next question.
]
```

Satz separates the entries and generates an index. Keep entries in the order you want to read them. To add another entry, copy an entire `#journal-entry(...)[...]` block and replace its fields and notes.

## Adjust the appearance

Pass a small `config` dictionary to each entry. For example, add `config: (page: (paper: "b5"))` alongside its title and date. [Configuration](/satz/reference/configuration/) explains fonts and line spacing. If several entries share settings, define one `#let config = (...)` at the top and pass `config: config` to each entry and the index.

## Add a cover or separate entry files later

A cover and a folder of entry files are optional. Once the journal grows, move a complete entry block into `entries/pilot.typ` and replace it in `main.typ` with `#include "entries/pilot.typ"`. The entry file needs its own import of `journal-entry`, because included files have their own variable scope.

Keep one project folder per journal. This lets you maintain a thesis journal and a separate project journal without mixing their entries.

## Development starter and launcher

The repository also contains a shareable starter and a standalone `journal` launcher for Windows, macOS, and Linux. These are **development tools**, and currently use a more modular folder layout. Read [the starter guide](https://github.com/kylekahraman/satz/blob/main/docs/journal-starter.md) for its actual commands and requirements.

A general `satz new ...` command and a named journal chooser are design work, not released features. You can use the one-file examples above today without installing a launcher.
