---
title: "Add a cover page"
description: "Build a reusable cover page for a report or thesis with a title, author, and optional project details."
---

Use `cover-page()` to add a cover to a larger document. The cover is a component: it does not replace the document template that styles the report, thesis, or book that follows it.

## 1. Add a research cover to a report

Create `main.typ` and paste this complete example. The details are fictional:

```typst
#import "@local/satz:0.2.0": cover-page, report

#cover-page(
  layout: "research",
  title: [Field Notes from a Pilot Study],
  subtitle: [An example report],
  author: [Alex Example],
  date: [October 2026],
  keywords: [pilot, methods],
)

#show: report.with()

= Introduction

Start the report after the cover. The report template styles the pages that
follow and creates its contents page from the headings.
```

`layout: "research"` creates a generated title page. The title is required for this layout; subtitle, author, date, keywords, and supervisors are optional. Keep the cover call before the report show rule so it appears first and the report styles the document body.

## 2. Choose a simpler generated cover

Use `layout: "minimal"` for a compact title page:

```typst
#cover-page(
  layout: "minimal",
  title: [Field Notes from a Pilot Study],
  author: [Alex Example],
)
```

Both generated layouts use the built-in theme by default. To choose another palette, add a theme such as `theme: "plum"` or `theme: "soft-slate"`. You can also override shared colors through `config`.

## 3. Compile and check the cover

Compile with `typst compile --package-path packages main.typ`. Check that the title, author, and other details fit without awkward line breaks and that the first report page follows the cover. For a hand-designed cover, use `layout: "classic"` and pass your own `body: [...]`; the [`cover-page` API entry](/satz/reference/api/#cover-page) documents the available slots and theme names.

This tutorial uses Satz 0.2.0 during usability testing. After publication, change `@local` to `@preview` in the import and keep version `0.2.0`.
