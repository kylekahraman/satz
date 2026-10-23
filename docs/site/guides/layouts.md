---
title: "Page layout, binding, and columns"
---

Start by choosing a document template, then adjust the page settings the template supports. Satz uses Typst's page layout system, so values such as margins and column gaps use Typst lengths (`25mm`, `2cm`, `1em`) rather than plain numbers.

## Set page size and margins

Reports and journals accept shared page configuration. For example:

```typst
#show: report.with(config: (
  page: (
    paper: "a4",
    margin: (top: 25mm, bottom: 25mm, left: 30mm, right: 20mm),
  ),
))
```

The margin dictionary gives a separate length for each edge. A smaller right margin makes room for binding or notes; check the PDF to make sure the text block still feels balanced. Margin keys and accepted values are listed under [`page.margin`](/satz/reference/configuration/#page-margin).

## Prepare a two-sided document for binding

When a supported template has a binding edge, configure the inside and outside margins and a binding correction:

```typst
#show: report.with(config: (
  page: (
    binding: left,
    binding-correction: 5mm,
    margin: (inside: 30mm, outside: 22mm, top: 25mm, bottom: 25mm),
  ),
))
```

`inside` is the edge near the spine; `outside` is the fore edge. The correction reserves extra space at the binding side. Compile a document with several pages and inspect it as facing pages before printing, because page-side alternation is only apparent in a spread. See [`page.binding`](/satz/reference/configuration/#page-binding) and [`page.binding-correction`](/satz/reference/configuration/#page-binding-correction).

## Choose an article layout

The `article` template supplies article front matter and two columns in Satz 0.2.0. Its column count and gutter are controlled through configuration; a two-column article may need narrower images or a figure that spans the page. Mixed-width floats can affect page flow, so review the compiled PDF rather than relying only on the editor's source view. See the [`article` API](/satz/reference/api/#article) for its metadata arguments and compile it with the local 0.2.0 package as described in [setup](/satz/getting-started/setup/).

## Control body line spacing

The candidate configuration supports two distinct ways to describe line spacing:

```typst
typography: (
  line-spacing: 1.5,
)
```

`line-spacing` asks for a baseline-to-baseline distance equal to a multiple of the body font size. It uses font metrics to calculate Typst's leading and takes precedence over `typography.leading`. If you prefer to set Typst's line gap directly, use `leading: 0.65em` instead. Paragraph spacing is separate: it controls the gap between paragraphs, not between text lines. See [line and paragraph spacing](/satz/reference/configuration/#typography-line-spacing) for the exact types and defaults.

## Find the full setting list

The [configuration reference](/satz/reference/configuration/) includes shared page, typography, heading, footer, table, caption, and color settings, with template-specific overrides. The [API reference](/satz/reference/api/) shows which template accepts `config` and what other arguments it requires.
