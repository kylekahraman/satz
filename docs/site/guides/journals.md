---
title: "Keep a research journal"
description: "Start a useful research journal in Typst, write entries you can return to, and build a linked index as it grows."
---

A research journal is a record of how your work changes over time. It helps you return to the question you were investigating, remember what you tried, and see why you made a decision. An entry does not need to be polished. It needs enough context that future-you can understand it.

This guide takes you from an empty file to a small, organized journal. It uses the published Satz `0.1.1` package and ordinary Typst files. You can write entries manually; the optional starter and launcher are described at the end.

## 1. Start with one entry

Create `main.typ` and write one entry with a question, a record of the work, and a next step. Replace the example text with your own.

```typst
#import "@preview/satz:0.1.1": journal-entry, remember, question

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

The `journal-entry` show rule puts the title, date, and keywords in the entry header, then styles everything that follows. It also enables checklists. On later pages of a long entry, the title and date stay in the running header. The `remember` and `question` callouts mark something to keep visible or investigate; they do not create a separate task system.

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

## 3. Add entries and an index

When you want several entries in one document, use `journal-entry` as a content function and put `journal-index()` first:

```typst
#import "@preview/satz:0.1.1": journal-entry, journal-index

#journal-index()

#journal-entry(
  title: "Pilot recording: first equipment check",
  date: "2026-10-21",
  keywords: "pilot, equipment",
)[
  == What I did
  Checked the trigger cable and recorded a short test run.

  == What I learned
  Every trigger appeared in the event channel.
]

#journal-entry(
  title: "Pilot recording: timing follow-up",
  date: "2026-10-23",
  keywords: "pilot, timing",
)[
  == Question
  Does event timing stay stable during a full session?

  == Result
  The timing was stable from the first block to the last.
]
```

The index finds entries in the same Typst document, even though it comes before them. It sorts dated entries chronologically, groups them by month and year, and links each title to its entry page. Undated drafts appear after dated entries under “Undated.” You can add an older entry anywhere in the source; the index still places it by its date.

Each entry's keywords are displayed in its header. The index lists the date, title, and page number; it does not filter or search by keyword. The link targets are generated when Typst compiles the document, so compile or preview the main file to refresh the page numbers and links.

For one entry in a standalone document, `#show: journal-entry.with(...)` is the short path. For several entries in a journal, use `#journal-entry(...)[...]` for each entry. That keeps each entry's metadata and body together and lets the index find it.

## 4. Keep entries readable and useful

An entry body is normal Typst content: paragraphs, headings, lists, equations, code, figures, and tables can all be used. Start with plain text and add structure only when it helps you find or compare information.

- Give an entry one descriptive title: “ICA threshold comparison” is easier to revisit than “Notes”.
- Put a question or purpose near the beginning so the observations have context.
- Separate what you observed from what you infer or decide. This helps when you reinterpret the result later.
- Add file names, paths, software versions, and parameter values when they affect whether someone can reproduce the work.
- Use a small, consistent set of keywords for topics you expect to revisit. They are labels for readers, not automatic tags.
- Leave open questions and unchecked tasks in the entry. They make unfinished work visible when you return.

The template does not impose a fixed scientific method or a required entry type. A meeting note, field observation, experiment log, analysis record, or personal research reflection can each use headings suited to the work.

## 5. Choose how to organize a growing journal

For a few entries, keeping everything in `main.typ` is simplest. You can search it in your editor and the index will see all entries in that file.

As the journal grows, split entries into separate files while keeping one main file to assemble them:

```text
my-journal/
├── main.typ
└── entries/
    ├── 2026-10-21-equipment-check.typ
    └── 2026-10-23-timing-follow-up.typ
```

`main.typ` imports the functions, generates the index, then includes the entry files in chronological order:

```typst
#import "@preview/satz:0.1.1": journal-entry, journal-index

#journal-index()
#include "entries/2026-10-21-equipment-check.typ"
#include "entries/2026-10-23-timing-follow-up.typ"
```

Each entry file contains one `#journal-entry(...)[...]` call and no index. Keep the relative folder structure when moving the project, and keep `main.typ` as the document you preview or compile. The files remain editable Typst source; the PDF is the reading copy generated from them.

You can apply one appearance config to the index and all entries. Add this after the import, then pass `config: journal-config` to `journal-index` and each `journal-entry`:

```typst
#let journal-config = (
  page: (paper: "iso-b5"),
  typography: (font: "Libertinus Serif", size: 11pt),
)
```

See the [configuration reference](/satz/reference/configuration/) for each field and the [API reference](/satz/reference/api/#journal-entry) for the function arguments.

Keep your journal folder in your normal backup or version-control routine. A compiled PDF is convenient to read, while the `.typ` files preserve the editable entries, their structure, and the index source.

## 6. Optional project starter and launcher

The package API above is enough to start and maintain a journal. The repository also has a ready-made project starter with a cover, separate entry files, and a bundled copy of Satz. A small optional `journal` command can create projects and add dated entry files. Neither is required to use the published package. See the [journal starter guide in the repository](https://github.com/kylekahraman/satz/blob/main/docs/journal-starter.md) for setup and current launcher limits.

If you use features from the repository source that are newer than `0.1.1`, follow [Development versions and updates](/satz/guides/development/). The examples in this tutorial use the published package.
