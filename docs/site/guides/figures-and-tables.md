---
title: "Figures, tables, captions, and references"
---

Use Typst's native `figure` and `table` elements for most illustrations and data tables. A figure can contain an image, drawing, or table. Its caption provides the displayed description; a label makes it possible to refer to the numbered item elsewhere in the text.

## Add and reference an image

Put `results.png` next to `main.typ`, or change the path to the image's location relative to the Typst source file. Then add:

```typst
#figure(
  image("results.png", width: 80%),
  caption: [Response across conditions.],
) <response-plot>

The pattern in @response-plot shows a larger response in the second condition.
```

The `caption` is content in square brackets. The label in angle brackets must be unique within the document. Typst numbers the figure and resolves `@response-plot` to its number. If the path or label is misspelled, the compiler reports it.

Satz formats captions with a regular label and a hanging layout by default:
when the caption wraps, its later lines start under the caption text, not under
“Figure 1:”. To bold only the label, configure the document:

```typst
#show: report.with(config: (
  captions: (label-weight: "bold"),
))
```

Set `captions.hanging: false` separately if you want the label inline.

## Keep text flowing around large figures

Typst keeps figures in source order unless placement is set to `auto`. Satz
reports set `figures.placement: auto` by default, so a large figure can move to
a nearby page top or bottom while later text fills the remaining space. Other
templates use source-order placement by default. Change the setting through the
template config; for example, to keep report figures in source order:

```typst
#show: report.with(config: (figures: (placement: none)))
```

Set `figures.placement: auto` to enable floating in another template. This
setting applies to native figures, including tables wrapped in figures. Floats
may move away from their source location, so keep each figure's markup near its
first reference and inspect the compiled PDF for placement and reading order.
`auto` chooses the nearer top or bottom position; it does not reproduce LaTeX's
full float-placement algorithm. See the [Typst figure reference](https://typst.app/docs/reference/model/figure/).

Table cells default to left-aligned, unjustified text for readable columns. Set `align:` on a table or individual cell to choose a different alignment.

## Use a shorter list entry

For long captions, `satz-figure` lets the page show the full caption while a short version appears in the List of Figures:

```typst
#import "@local/satz:0.2.1": report, satz-figure
#show: report.with()

= Results

#satz-figure(
  image("results.png", width: 80%),
  caption: [Full caption describing the acquisition, preprocessing, and interpretation of the result.],
  short-caption: [Response across conditions.],
) <response-plot>

See @response-plot for the measurement details.
```

Use this helper when the detailed caption would make the list hard to scan. Standard `figure` works when the same caption is suitable in both places. The `satz-figure` helper and the `lof.compact` setting are documented in the [API reference](/satz/reference/api/#satz-figure) and [configuration reference](/satz/reference/configuration/#lof-compact).

## Make a table

Here is a complete report section with a native table:

```typst
#import "@local/satz:0.2.1": report
#show: report.with()

= Results

#figure(
  table(
    columns: (1fr, auto),
    table.header([Measure], [Value]),
    [Baseline], [0.12],
    [Treatment], [0.38],
  ),
  caption: [Summary measurements.],
) <summary-table>

See @summary-table for the measured values.
```

The column tuple gives the first column flexible width and lets the second fit its contents. `table.header` marks the header row. Wrapping the table in `figure` gives it a caption, figure numbering, a label, and an entry in the List of Figures. For a List of Tables, use Typst's table element directly with the appropriate figure kind; see the [Typst figure documentation](https://typst.app/docs/reference/model/figure/) and [table documentation](https://typst.app/docs/reference/model/table/).

## Add a captioned table with the development helper

`scientific-table` and the `scientific-tables` show rule provide extra scientific-table conventions in Satz 0.2.0. See the [API reference](/satz/reference/api/#scientific-table) for their arguments and the source [scientific tables guide](https://github.com/kylekahraman/satz/blob/main/docs/scientific-tables.md) for complete examples.

## Troubleshoot figure placement

For two-column articles, confirm whether a figure should fit one column or span both; mixed-width floats can change page flow. The [layout guide](/satz/guides/layouts/) covers columns, and the [API reference](/satz/reference/api/) lists Satz's figure and table helpers.
