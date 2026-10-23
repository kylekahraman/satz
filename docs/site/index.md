---
title: "Your next document starts here"
---

Satz gives your reports, research journals, letters, and proposals a consistent starting point in [Typst](https://typst.app/). You write the content; Satz supplies the document layout. Start with one file and change the settings when you need to.

**New to Typst?** Follow the full [blank file to finished document course](/satz/getting-started/complete-document/). It teaches the writing and compiling steps from the beginning. Use [Set up and write](/satz/getting-started/setup/) if you first need to choose an editor.

## What would you like to write?

| Your document | Start here |
| --- | --- |
| Report, assignment, or research protocol | [Write your first report](/satz/getting-started/report/) |
| Research diary or meeting notes | [Start a journal](/satz/guides/journals/) |
| Letter | [Write a letter](/satz/getting-started/letter/) |
| Invoice | [Create an invoice](/satz/getting-started/invoice/) |
| Grant or project proposal | [Proposal templates and coverage](/satz/guides/proposals/) |
| Something else | [Choose a template](/satz/reference/templates/) |

## A quick first document

Create a file called `main.typ` and paste this in:

```typst
#import "@preview/satz:0.1.1": report
#show: report.with()

= Introduction

This is my first report with Satz.

== Next steps

- Describe the question.
- Add the findings.
- Share the PDF.
```

The first line loads Satz. The second applies the report layout to everything below it. Lines starting with `=` are headings. You can keep writing in this same file: a separate setup or configuration file is optional.

## Make it yours

[Change fonts, spacing, and colors](/satz/reference/configuration/), [add figures and tables](/satz/guides/figures-and-tables/), or [split a growing document into sections](/satz/getting-started/report/#5-split-a-longer-report-into-files). If something goes wrong, start with [Troubleshooting](/satz/guides/troubleshooting/).

## Which version am I using?

Copyable beginner examples use **Satz 0.1.1**, the published package. An import containing `@preview/satz:0.1.1` keeps that version, so a future release will not silently change your document.

**Development features** are labelled explicitly. New palettes, cover presets, proposal improvements, and the journal launcher are being developed in the repository. They are not all available in the published package yet. See [Development versions and updates](/satz/guides/development/) before using them.

Have a question or a confusing example? [Open an issue on GitHub](https://github.com/kylekahraman/satz/issues). Describe what you wanted to do and include a small example without private information.
