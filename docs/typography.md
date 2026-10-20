# Heading, paragraph and callout rhythm

Satz keeps native Typst heading layout. Headings remain attached to following
content, spacing can trim at a page start, and adjacent block gaps collapse.
Use configuration rather than inserting manual `v()` around each heading.

## Shared defaults and document calibration

| Level | Size | Above | Below |
| --- | --- | --- | --- |
| 1 | 14pt | native (`auto`) | 1em |
| 2 | 12pt | native (`auto`) | 1em |
| 3 | 11pt | native (`auto`) | 0.9em |
| 4 | 11pt | native (`auto`) | 0.75em |

`headings.h1-above` through `h4-above` accept explicit lengths. For `auto`, Satz
omits the block override entirely: explicitly setting `block(above: auto)`
does not preserve the heading's own spacing in the same way. The regression
checks verify that increasing above-spacing changes the preceding gap without
changing the following gap, at every supported level.

There is no universal correct number of points. Inside a flowing text passage,
the heading should normally be closer to the text it introduces than to the
previous passage. Smaller headings generally need smaller absolute gaps.
Chapter openings, consecutive headings, lists, equations and page starts
require separate inspection.

`headings.h1-pagebreak` defaults to `false`. Set it to `true` when every
top-level heading must begin on a fresh page. That preserves the chapter-opening
convention used by report classes such as `scrreprt`, but it can leave a short
ending on the previous page when Typst's wrapping differs from another engine.
Set it to `false` for continuous reports where flowing into the next chapter is
preferable to that extra white space; native heading stickiness still keeps a
heading with its following content.

```typst
#show: report.with(config: (headings: (h1-pagebreak: false)))
```

The research report's STIX Two Text calibration is **document configuration**,
not a replacement for the shared defaults:

| Heading | Size | Configured above / below | Measured visible gap before / after |
| --- | --- | --- | --- |
| Section (level 2) | 14.35pt | 2.6em / 1.95em | about 33.2pt / 23.4pt |
| Subsection (level 3) | 11.95pt | 2.75em / 2em | about 29.0pt / 19.9pt |

The corresponding LaTeX reference gaps were about 32.7/23.2pt and 28.7/19.8pt.
The smaller subsection font resolves `em` to fewer points, so its absolute gaps
decrease even though its numeric `em` value is larger. Configured block gaps
and visible ink-to-ink gaps differ because font edges and adjacent content
also affect the measurement. These are selected same-page measurements, not
a promise that every heading in either document has identical geometry.

## Why the line spacing became cramped

Typst's `par.leading` measures the gap between line edges. `par.spacing`
controls paragraph separation; it is not an extra amount added to leading.
A paragraph spacing smaller than leading can therefore make paragraph
boundaries tighter than ordinary lines.

At 11pt STIX Two Text with `leading: 0.75em`, the report's ordinary baseline
distance is about 15.48pt, close to the LaTeX reference's 15.45pt. That does not
protect a callout with its own `spacing: 0.4em`, a smaller code-only line, or a
tight list. Those contexts need to be checked separately.

The public `callout` helper inherits body size, font and leading, sets paragraph
spacing to 1em, and uses loose list/enum spacing of 1.2em. Smaller raw-only
lines retain the surrounding body's measured cap-height. The block breaks
within the normal text area and keeps the ordinary footer clear.

```typst
#import "@local/satz:0.1.1": report, callout
#show: report.with(config: (toc: (depth: 0),))

#callout(title: [Main finding])[
  Explain the result here. Long content can continue onto the next page.
]
```

Component configuration is explicit: pass `config:` to `callout` to share a
document palette or customize `callouts.inset`, `radius`, `stroke`,
`paragraph-spacing`, `list-spacing` and `title-below`. Optional `title:` uses
the component palette and stays with following content. `fill:` and `stroke:` allow individual
overrides. Arbitrary headings, custom show rules or unbreakable objects inside
a box still need visual review.

## Verification

Run `python3 examples/latex-parity/check_typography.py` and
`python3 examples/latex-parity/check_callouts.py`. The first checks native flow,
page boundaries and all four heading levels; the second checks body/code
paragraphs at 11pt and 13pt, content preservation and footer clearance.

Use [Typst's paragraph reference](https://typst.app/docs/reference/model/par/)
and [block reference](https://typst.app/docs/reference/layout/block/) for the
underlying spacing semantics. Always render the consuming document and compare
each changed component and affected page with the reference PDF.
