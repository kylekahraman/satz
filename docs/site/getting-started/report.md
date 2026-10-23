---
title: "Write your first report"
---

This walkthrough starts with one file and ends with a compiled report. It assumes no prior Typst experience. You will learn what the import and show rule do, how to write headings and paragraphs, and how to change one setting without replacing the rest of the template configuration.

## 1. Start with a blank file

Create `main.typ` in a new folder, then paste this complete example:

```typst
#import "@preview/satz:0.1.1": report
#show: report.with()

= Introduction

This report describes the question, the approach, and the main result.

== Context

Use two equals signs for a section below the main heading. A blank line starts
a new paragraph.

= Method

Describe what you did and how you did it.

= Findings

Write the result here. You can add a table, figure, or citation as the report
develops.
```

The import makes the `report` function available in this file. `#show: report.with()` applies its document layout to the content that follows. The equals signs create Typst headings; they also become numbered headings in the report. The text itself remains ordinary Typst, so you can use lists, emphasis, links, equations, and other Typst features inside the template.

## 2. Compile and read the result

In the Typst web app, paste the example into a blank project and wait for the preview. In VS Code with Tinymist, open the preview for `main.typ`. With the Typst command-line program installed, run this from the folder containing the file:

```sh
typst compile main.typ
```

Typst writes `main.pdf` next to the source. The first compile may download Satz. If the document has multiple pages, the report can generate a contents page from your headings. Add enough content to see how page breaks and the contents respond.

## 3. Change one setting

You can replace the show rule with a configured one. For example, this selects a serif font and makes entries in the List of Figures shorter:

```typst
#show: report.with(config: (
  typography: (font: "Libertinus Serif"),
  lof: (compact: true),
))
```

The nested dictionaries matter: `typography` contains text settings and `lof` contains List of Figures settings. Satz merges these overrides with its defaults, so you do not need to repeat unrelated values. `compact: true` omits caption text from that list; it does not shorten captions where they appear in the report. The font must be available in the environment that compiles the PDF.

For the type, default, and effect of each supported field, use the [configuration reference](/satz/reference/configuration/). The [API reference](/satz/reference/api/) documents the `report` arguments and which configuration groups each template uses.

## 4. Add a figure or table

Put image files beside `main.typ` (or in a subfolder) and refer to them by a relative path. Native Typst figures get captions, numbering, labels, and references:

```typst
#figure(
  image("results.png", width: 80%),
  caption: [Response across conditions.],
) <response-plot>

See @response-plot for the plotted response.
```

Continue with the [figures and tables tutorial](/satz/guides/figures-and-tables/) for tables, short captions, and cross-references.

## 5. Split a longer report into files

Once the document becomes hard to navigate, move a section into another `.typ` file and include it:

```typst
#include "sections/introduction.typ"
#include "sections/method.typ"
```

Create those files inside the project folder. `#include` inserts their content at that point in the document, so the report show rule still styles their headings. Keep the imports and show rule in `main.typ` so the entry file controls the whole document.

## Where to go next

- For all layout options, follow [Configuration](/satz/reference/configuration/).
- For available templates and their release status, see [Choose a template](/satz/reference/templates/).
- For compiler errors, missing fonts, and paths, see [Troubleshooting](/satz/guides/troubleshooting/).
