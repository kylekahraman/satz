---
title: "Write a research article"
description: "Create a two-column research article with a title, authors, affiliations, abstract, and ordinary Typst body content."
---

Use `article()` when you need a compact research-paper structure with author information and an abstract above a two-column body. This tutorial uses the Satz 0.2.0 local package and fictional research content.

## 1. Create the article file

Create `article.typ` and paste this complete starter:

```typst
#import "@local/satz:0.2.0": article
#show: article.with(
  title: "A Small Example Study",
  authors: ((name: "Alex Example", affiliations: (1,)),),
  affiliations: ("Example Research Group, Sample University",),
  abstract: [
    This example explains how to structure an article with Satz. Replace this
    summary with the research question, method, main finding, and conclusion.
  ],
  date: "October 2026",
)

= Introduction

Explain the problem and state the question the article addresses.

= Method

Describe the participants or materials, procedure, and analysis. Include enough
detail for a reader to understand what was done.

= Results

Report the observations and refer to any figures or tables in the text.

= Discussion

Explain what the results mean, state their limitations, and identify a useful
next step.
```

The `#show` rule formats the title block and applies the article layout to the body. The headings and paragraphs are ordinary Typst content. Change the title, author, affiliation, abstract, and date in the settings; write the article below the closing parenthesis.

## 2. Add more authors or affiliations

Each author is a record with a `name`. Add one-based affiliation numbers when an author belongs to one or more affiliations:

```typst
authors: (
  (name: "Alex Example", affiliations: (1, 2)),
  (name: "Sam Reader", affiliations: (2,)),
),
affiliations: (
  "Example Research Group, Sample University",
  "Methods Lab, Example Institute",
),
```

Every affiliation number must point to an entry in `affiliations`. The article checks this when it compiles and reports an error if a number is missing or out of range.

## 3. Change to a one-column layout

For an assignment or a manuscript that should use one column, add a shared page override inside `article.with(...)`:

```typst
config: (page: (columns: 1)),
```

This only changes the page column count; the other article defaults remain in place. Keep the default two-column layout when preparing a compact paper. See the [article API](/satz/reference/api/#article) for metadata fields and the [configuration reference](/satz/reference/configuration/) for each shared setting.

## 4. Compile and inspect

Compile with the local 0.2.0 package:

```sh
typst compile --package-path packages article.typ
```

Check that the title, superscript affiliation markers, abstract, and section order are correct. In two columns, review figures and tables for width and placement. A figure intended to span both columns needs a suitable placement and scope; see [Figures and tables](/satz/guides/figures-and-tables/).

This tutorial targets Satz 0.2.0 during usability testing. After publication, change `@local` to `@preview` and keep the version number unchanged.
