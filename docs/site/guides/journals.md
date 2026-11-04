---
title: "Keep a research journal"
description: "Start a useful research journal in Typst, write entries you can return to, and build a linked index as it grows."
---

A research journal is a record of how your work changes over time. It helps you return to the question you were investigating, remember what you tried, and see why you made a decision. An entry does not need to be polished. It needs enough context that future-you can understand it.

This guide takes you from an empty file to a small, organized journal. It uses the Satz `0.2.0` API from the local package and ordinary Typst files. You can write entries manually; the optional starter and launcher are described at the end.

> **Before customizing the appearance:** this guide keeps each entry in a separate `.typ` file. If you want to change the journal-wide style, create `journal-style.typ` and import it from both `main.typ` and every entry. A config defined only in `main.typ` does not reach the separate entry files. The default setup needs no `journal-style.typ`; the optional style module is explained in [Section 5](#5-optional-shared-appearance-settings).

## 1. Create the journal files

Keep the assembly in `main.typ` and put each entry in its own file under `entries/`. Start with this small project:

```text
my-journal/
├── main.typ
└── entries/
    └── 2026-10-21-equipment-check.typ
```

Write the entry in `entries/2026-10-21-equipment-check.typ`:

```typst
#import "@local/satz:0.2.0": journal-entry, remember, question

#show: journal-entry.with(
  title: "Pilot recording: first equipment check",
  date: "2026-10-21",
  keywords: "pilot, equipment, MEG",
)

== Question

Can we record the planned task reliably with the current setup?

== What I did

I checked the trigger cable and recorded a short test run. The trigger
appeared in the event channel on every trial.

== What I learned

The current setup is suitable for a longer pilot. I have not checked
whether the event timing stays stable across a full session.

#remember[Keep the cable configuration from this test for the next session.]

#question[Does the event timing drift during a full recording?]

== Next time

- [ ] Record a complete pilot session.
- [ ] Compare event timing at the beginning and end.
```

The `journal-entry` show rule puts the title, date, and keywords in the entry header, then styles everything that follows. It also enables checklists. The journal templates default to ISO B5 with the journal typography in `journal/defaults.typ`; pass `config` only when you want to change those values. On later pages of a long entry, the title and date stay in the running header. The `remember` and `question` callouts mark something to keep visible or investigate; they do not create a separate task system.

Journal list spacing has its own settings. For example, set `journal.list-spacing`
to tighten or open the gap between list items:

```typst
#show: journal-entry.with(config: (
  journal: (list-spacing: 0.4em),
))
```

The default is `0.65em`. Set `journal.list-tight: true` to use paragraph
leading between list items instead.

Now make `main.typ` the file you preview and compile:

```typst
#import "@local/satz:0.2.0": journal-index

#journal-index()
#include "entries/2026-10-21-equipment-check.typ"
```

The index can find entries in included files. Keep each entry as a separate file; `main.typ` assembles them and provides the index.

You choose the headings that fit your work. A useful entry often answers these questions in some form:

1. What were you trying to find out?
2. What did you do, using which data, materials, settings, or version?
3. What happened, including unexpected results?
4. What did you decide, and why?
5. What will you try or check next?

Record enough detail to make an important result interpretable later. For a meeting, that might mean the decision and who owns the next step. For an analysis, it might mean the input files, code revision, parameters, and a path to the output. A short note such as “reran the model” is hard to use later; “reran `pilot-03` with the 21 October filter settings; the artifact count fell from 14 to 9” gives you something to follow up.

## 2. Choose and enter dates

The date is a string that you provide; Satz does not timestamp entries automatically. You can write `2026-10-21`, `21/10/26`, or `21/10/2026`. An optional weekday prefix is allowed, for example `Wednesday, 21/10/26`. Blank dates are allowed while drafting and appear under “Undated” in an index. Impossible dates, such as `31/02/2026`, fail with an error.

Use one date convention throughout a journal so entries are easy to scan. The date shown in an entry stays as you typed it; the index parses it to choose its month and year group.

## 3. Add entries and update the index

Create another file under `entries/`, import `journal-entry` there, and include it from `main.typ`:

```typst
#import "@local/satz:0.2.0": journal-entry

#show: journal-entry.with(
  title: "Pilot recording: timing follow-up",
  date: "2026-10-23",
  keywords: "pilot, timing",
)

== Question
Does event timing stay stable during a full session?

== Result
The timing was stable from the first block to the last.
```

Add the new file to `main.typ`:

```typst
#include "entries/2026-10-23-timing-follow-up.typ"
```

The index finds included entries even though it comes before them. It sorts dated entries chronologically, groups them by month and year, and links each title to its entry page. Undated drafts appear after dated entries under “Undated.” You can include an older entry anywhere in `main.typ`; the index still places it by date.

Each entry's keywords are displayed in its header. The index lists the date, title, and page number; it does not filter or search by keyword. The link targets are generated when Typst compiles the document, so compile or preview the main file to refresh the page numbers and links.

Each entry file contains its metadata and body together. That keeps entry editing independent while `main.typ` remains the one document you compile.

## 4. Keep entries readable and useful

An entry body is normal Typst content: paragraphs, headings, lists, equations, code, figures, and tables can all be used. Start with plain text and add structure only when it helps you find or compare information.

- Give an entry one descriptive title: “ICA threshold comparison” is easier to revisit than “Notes”.
- Put a question or purpose near the beginning so the observations have context.
- Separate what you observed from what you infer or decide. This helps when you reinterpret the result later.
- Add file names, paths, software versions, and parameter values when they affect whether someone can reproduce the work.
- Use a small, consistent set of keywords for topics you expect to revisit. They are labels for readers, not automatic tags.
- Leave open questions and unchecked tasks in the entry. They make unfinished work visible when you return.

The template does not impose a fixed scientific method or a required entry type. A meeting note, field observation, experiment log, analysis record, or personal research reflection can each use headings suited to the work.

## 5. Optional shared appearance settings

You can start without a style file: `journal-entry` and `journal-index` use Satz's journal defaults. Add `journal-style.typ` only if you want custom settings shared by the index and all entries. Separate Typst files have separate module scopes, so entries cannot read config variables from `main.typ`.

Create `journal-style.typ` with the settings you want to override and bind the Satz functions once:

```typst
#import "@local/satz:0.2.0": journal-entry as base-entry, journal-index as base-index

#let journal-config = (
  page: (paper: "iso-b5"),
  typography: (font: "Libertinus Serif", size: 11pt),
)

#let journal-entry = base-entry.with(config: journal-config)
#let journal-index = base-index.with(config: journal-config)
```

Then import the preconfigured functions from `journal-style.typ` in `main.typ` and each entry. Satz supplies every setting omitted from `journal-config`; this is a short list of overrides, not a copy of Satz's defaults. If you do not need custom settings, skip this module and import the relevant Satz function directly in each file.

In `main.typ`, import the index and include the entry files:

```typst
#import "journal-style.typ": journal-index

#journal-index()
#include "entries/2026-10-21-equipment-check.typ"
```

For example, an entry file starts with:

```typst
#import "../journal-style.typ": journal-entry

#show: journal-entry.with(
  title: "Pilot recording",
  date: "2026-10-21",
)

== What I did
Checked the trigger cable and recorded a short test run.
```

See the [configuration reference](/satz/reference/configuration/) for each field and the [API reference](/satz/reference/api/#journal-entry) for the function arguments.

Keep your journal folder in your normal backup or version-control routine. A compiled PDF is convenient to read, while the `.typ` files preserve the editable entries, their structure, and the index source.

## 6. Optional project starter and launcher

The package API above is enough to start and maintain a journal. The repository also has a ready-made project starter with a cover, separate entry files, and a bundled copy of Satz. A small optional `journal` command can create projects and add dated entry files. Neither is required to use the package API. See the [journal starter guide in the repository](https://github.com/kylekahraman/satz/blob/main/docs/journal-starter.md) for setup and current launcher limits.

This tutorial uses the same 0.2.0 API that is under usability review. While it is not yet published, compile with your local Satz 0.2.0 package; after release, change the import namespace from `@local` to `@preview`.
