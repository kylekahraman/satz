# Write your first report

Satz's report template is a starting point for assignments, protocols, and longer reports. It adds numbered headings, a contents page, page layout, and shared typography defaults while leaving the document content in ordinary Typst.

If you have not chosen an editor yet, follow [Set up and write](setup.md) first.

## 1. Create a file

In a new `main.typ`, write:

```typst
#import "@preview/satz:0.1.1": report
#show: report.with()

= Introduction

This is the opening paragraph of the report.

== Background

Explain the context here. Continue writing with normal Typst markup.

= Method

Describe the method.
```

The report supplies heading numbers and contents. Change the headings and paragraphs to your own text; keep the import and show rule at the top.

## 2. Compile it

With the Typst CLI installed, run:

```sh
typst compile main.typ
```

In the Typst web app, create a document, paste the example, and let the live preview compile it. The first compile downloads the package if it is not already available locally.

## 3. Add only the settings you need

For example, choose a body font and shorter figure-list entries:

```typst
#show: report.with(config: (
  typography: (font: "Libertinus Serif"),
  lof: (compact: true),
))
```

You can use the same settings in several documents by placing them in `config.typ` and importing that dictionary. A separate configuration file is optional. See [Configuration](../reference/configuration.md) for available settings and examples.

## Add figures, tables, and references

Use Typst's built-in `figure`, `table`, `bibliography`, and `@label` references. Satz styles them as part of the report. The [figures and tables guide](../guides/figures-and-tables.md) covers captions, cross-references, and optional scientific table helpers.

## When the report grows

Split long documents into section files and include them from `main.typ`:

```typst
#include "sections/introduction.typ"
#include "sections/method.typ"
```

Keep each section as ordinary Typst content. The report show rule still applies to the included material. For appendices, references, and advanced page layouts, see the template and configuration guides.
