# Write the document. Satz handles the layout.

Satz is a Typst toolkit for reports, journals, letters, invoices, proposals, and
other structured documents. It gives common documents a coordinated starting
point, then lets you adjust the parts that matter.

## Start with a report

Create a `main.typ`, import `report`, and begin writing. You do not need to copy
Satz's implementation into your project.

```typst
#import "@preview/satz:0.1.1": report
#show: report.with()

= Introduction

Write your report here.

== A section

Add headings, paragraphs, figures, tables, and citations as you normally would
in Typst.
```

For a full working example and next steps, follow [Write a report](getting-started/report.md).

## Find your path

- **Report, thesis, or assignment:** start with the report template and add configuration only when you need it.
- **Research notes:** create entries with a title, date, keywords, and body.
- **Scientific figures and tables:** use native Typst elements, with optional Satz helpers for captions and scientific rules.
- **Two-column article:** use the article entry point for a title, authors, abstract, and column layout.
- **Letter or invoice:** use the structured sender and recipient fields.

The [template guide](reference/templates.md) shows which entry point fits each document. The [configuration guide](reference/configuration.md) explains what you can change.

## How Satz is designed

Satz aims to make usual document work easy and keep advanced Typst features available when you need them. It is inspired by KOMA-Script; it does not attempt to reproduce every KOMA class or option.

Common appearance settings live in a shared configuration. A template adds document-specific fields such as a report title, journal date, or letter recipient. Components such as callouts and scientific tables expose options to fit them into a document.

The [API design notes](maintainers/api-design.md) explain the conventions we are working toward and where older interfaces still differ.

## Current release

The examples on this site target the published `0.1.1` API unless marked as development features. Unreleased improvements for the planned `0.2.0` release are not available from `@preview/satz:0.1.1` yet. See the [changelog](https://github.com/kylekahraman/satz/blob/main/CHANGELOG.md) for current status.
