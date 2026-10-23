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

## Use a shorter list entry

For long captions, `satz-figure` lets the page show the full caption while a short version appears in the List of Figures:

```typst
#import "@preview/satz:0.1.1": report, satz-figure
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
#import "@preview/satz:0.1.1": report
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

`scientific-table` and the `scientific-tables` show rule provide extra scientific-table conventions. They are development features and are not in the published `0.1.1` package. Follow [Development versions](/satz/guides/development/) to use them. See the [candidate API reference](/satz/reference/api/#scientific-table) for their arguments and the source [scientific tables guide](https://github.com/kylekahraman/satz/blob/main/docs/scientific-tables.md) for complete candidate examples.

## Troubleshoot figure placement

Typst decides where a floating figure fits on the page. If it appears earlier or later than expected, shorten nearby content, reduce the image width, or inspect the compiled PDF before changing margins. For two-column articles, confirm whether a figure should fit one column or span both; mixed-width floats can change page flow. The [layout guide](/satz/guides/layouts/) covers columns, and the [API reference](/satz/reference/api/) lists Satz's figure and table helpers.
