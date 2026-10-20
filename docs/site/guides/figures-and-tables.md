# Figures, tables, and captions

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

The development API adds explicit header and rule conventions for scientific tables while retaining native cells and references:

```typst
#import "@preview/satz:0.2.0": scientific-table

#figure(
  scientific-table(
    columns: (1fr, auto),
    header: ([Measure], [Value]),
    [Baseline], [0.12],
    [Treatment], [0.38],
  ),
  kind: table,
  caption: [Summary measurements.],
) <summary-table>
```

`scientific-table` and `scientific-tables` are planned for the next release; they are not in `@preview/satz:0.1.1`. Check the changelog before using development examples. Ordinary tables need no Satz helper.

Caption alignment, caption label weight, and caption text weight are separate controls in the development API. This allows a bold figure/table label with regular caption text.
