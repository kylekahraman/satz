---
title: "Figures, tables, and captions"
---

Use native Typst `figure` and `table` for ordinary content. A captioned figure is numbered, referenceable, and included in the relevant list.

```typst
#figure(
  image("results.png", width: 100%),
  caption: [Response across conditions.],
) <response-plot>

See @response-plot for the response pattern.
```

Use `satz-figure` when the printed caption needs more detail than its entry in the List of Figures:

```typst
#satz-figure(
  image("results.png", width: 100%),
  caption: [Full caption with methods and interpretation.],
  short-caption: [Response across conditions.],
) <response-plot>
```

## A complete table example

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

See @summary-table for the values.
```

For images, replace `results.png` in the earlier examples with a real file in your project. Import `satz-figure` alongside `report` if you use that helper.

**Development:** `scientific-table` and `scientific-tables` add scientific rule and header conventions. They are not available in `@preview/satz:0.1.1`; follow [the development setup](/satz/guides/development/) and [scientific table guide](https://github.com/kylekahraman/satz/blob/main/docs/scientific-tables.md) to try them.
