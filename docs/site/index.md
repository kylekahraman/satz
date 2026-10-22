# Your next document starts here

Satz gives your reports, research journals, letters, and proposals a consistent starting point in [Typst](https://typst.app/). You write the content; Satz supplies the document layout. Start with one file and change the settings when you need to.

**New to Typst?** Follow [Set up and write](getting-started/setup.md). You can try Satz in your browser without installing anything.

## What would you like to write?

| Your document | Start here |
| --- | --- |
| Report, assignment, or research protocol | [Write your first report](getting-started/report.md) |
| Research diary or meeting notes | [Start a journal](guides/journals.md) |
| Letter | [Write a letter](getting-started/letter.md) |
| Grant or project proposal | [Proposal templates and coverage](guides/proposals.md) |
| Something else | [Choose a template](reference/templates.md) |

## A complete first document

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

[Change fonts, spacing, and colors](reference/configuration.md), [add figures and tables](guides/figures-and-tables.md), or [split a growing document into sections](getting-started/report.md#when-the-report-grows). If something goes wrong, start with [Troubleshooting](guides/troubleshooting.md).

## Which version am I using?

Copyable beginner examples use **Satz 0.1.1**, the published package. An import containing `@preview/satz:0.1.1` keeps that version, so a future release will not silently change your document.

**Development features** are labelled explicitly. New palettes, cover presets, proposal improvements, and the journal launcher are being developed in the repository. They are not all available in the published package yet. See [Development versions and updates](guides/development.md) before using them.

Have a question or a confusing example? [Open an issue on GitHub](https://github.com/kylekahraman/satz/issues). Describe what you wanted to do and include a small example without private information.
