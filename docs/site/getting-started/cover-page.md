---
title: "Add a cover page"
description: "Build a reusable cover page for a report or thesis with a title, author, and optional project details."
---

Satz reports, custom documents, articles, and journal entries do not create a cover automatically. You can write a cover in Typst or use the optional `cover-page()` component. It does not replace the template that styles the following document. The experimental `book` template creates its own title page unless you provide a cover image.

## 1. Add a cover to a report

Create `main.typ` and paste this complete example. The details are fictional:

```typst
#import "@local/satz:0.2.1": cover-page, report

#cover-page(
  title: [Field Notes from a Pilot Study],
  subtitle: [An example report],
  author: [Alex Example],
  date: [October 2026],
)

#show: report.with()

= Introduction

Start the report after the cover. The report template styles the pages that
follow. A contents page is optional.
```

Passing `title:` generates the cover. The default `layout: "research"` aligns the title block left and adds a vertical accent rule. Subtitle, author, date, keywords, and supervisors are optional. Keep the cover call before the report show rule so it appears first and the report styles the document body.

Plain strings work too: `title: "Field Notes from a Pilot Study"` produces the same result. Use `[...]` when the title needs markup such as `*bold*`, `_italic_`, or `$math$`.

## 2. Use the minimal layout

`layout: "minimal"` centers a spare title block. The date moves to the bottom unless a `footer` replaces it:

```typst
#cover-page(
  layout: "minimal",
  title: [Field Notes from a Pilot Study],
  subtitle: [An example report],
  author: [Alex Example],
  date: [October 2026],
)
```

Both layouts accept the same fields. To choose a palette, add a theme such as `theme: "plum"` or `theme: "soft-slate"`. You can also override shared colors through `config`.

## 3. Share a look deliberately

A cover does not inherit the following document's `theme` or `config`. Pass the same values to both when they should match:

```typst
#let theme = "soft-jade"
#let shared = (typography: (font: "EB Garamond"),)

#cover-page(
  title: [Field Notes from a Pilot Study],
  theme: theme,
  config: shared,
)
#show: report.with(theme: theme, config: shared)
```

The cover reads only `page.paper`, `page.margin`, `typography.font`, `typography.size`, and the cover color keys. Other valid shared keys are accepted but ignored. A typo in a known key fails compilation instead of being silently ignored.

## 4. Draw the cover yourself

Pass `body:` to supply the whole cover content. The `logos`, `footer`, and `footer-left` slots remain available:

```typst
#cover-page(
  logos: image("logo.svg", width: 3cm),
  body: [
    #v(6cm)
    #text(size: 26pt, weight: "bold")[Field Notes]
  ],
  footer: [Example University],
)
```

A cover can also live in a separate file. Create `cover.typ`:

```typst
#import "@local/satz:0.2.1": cover-page
#let my-cover() = cover-page(title: [My document])
```

Then use it before the document show rule in `main.typ`:

```typst
#import "@local/satz:0.2.1": custom
#import "cover.typ": my-cover
```

Then render the cover and the document body:

```typst
#my-cover()
#show: custom.with()

= Introduction
The document starts after the cover.
```

The cover is rendered on its own page. `custom` starts without an automatic
contents page; use `config: (toc: (depth: none))` to add one.

## 5. Compile and check the cover

Compile with `typst compile --package-path packages main.typ`. Check that the title, author, and other details fit without awkward line breaks and that the first report page follows the cover. You can also write a separate Typst page without using the Satz cover component; the [`cover-page` API entry](/satz/reference/api/#cover-page) documents the available slots and theme names.

This tutorial uses Satz 0.2.0 during usability testing. After publication, change `@local` to `@preview` in the import and keep version `0.2.0`.
