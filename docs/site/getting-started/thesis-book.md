---
title: "Typeset a thesis or book"
description: "Choose a thesis-style report or a book structure, then build the contents and chapters with Satz 0.2.0."
---

After trying a letter, report, and research journal, use this guide for a longer work. A thesis and a book both need deliberate front matter, contents, page numbering, and chapters, but they start from different Satz entry points. These examples use the Satz 0.2.0 local package.

## Choose the starting point

- Use `custom(kind: "thesis")` when you want your own thesis structure with Satz's shared page setup, heading rules, contents, and bibliography behavior.
- Use `book()` when you want the experimental book layout with a title page, contents, front matter, main matter, appendices, and back matter.

The book API is experimental in 0.2.0. Compile a short sample and inspect its page breaks before moving a complete manuscript into it.

## Option A: start a thesis with your own structure

Create `thesis.typ` and start with this compact structure:

```typst
#import "@local/satz:0.2.0": custom
#show: custom.with(
  kind: "thesis",
  config: (
    page: (
      paper: "a4",
      binding: left,
      binding-correction: 8mm,
      headers: true,
    ),
  ),
)

= Abstract

Write a short summary of the research question, method, main result, and
conclusion.

= Introduction

Explain the problem and state the research question.

= Methods

Describe the design, materials, and analysis.

= Results

Report the findings.

= Discussion

Explain what the findings mean and what they do not establish.

```

`custom` lets you decide the section order and wording. The `thesis` kind turns on shared long-document behavior such as a table of contents and thesis numbering; it does not generate a university-specific cover or required chapter structure. Confirm those requirements with your department and add the required front matter yourself.

Move each chapter into its own file when the source becomes difficult to navigate. For example, replace the Introduction text with `#include "chapters/introduction.typ"` and keep the included file in a `chapters/` folder beside `thesis.typ`. When you need a bibliography, create a `.bib` file and add `#bibliography("references.bib", style: "apa")` where the references should appear.

## Option B: start a book

Create `book.typ`. This smaller example gives you a title page, contents, numbered main matter, and an appendix:

```typst
#import "@local/satz:0.2.0": book, book-contents, book-mainmatter, book-appendix, book-backmatter

#show: book.with(
  title: [A Short Guide to Field Notes],
  subtitle: [Methods and examples],
  author: [Alex Example],
  date: [2026],
  font: "Libertinus Serif",
  binding: left,
)

= Preface

Explain who the book is for and how to use it.

#book-contents()

#book-mainmatter[
  = First chapter

  Introduce the first main idea.

  == A section

  Develop one part of the chapter.

  = Second chapter

  Continue with another main idea.
]

#book-appendix[
  = Additional material

  Put supporting material here.
]

#book-backmatter[
  = Further reading

  List books and articles for readers who want to continue.
]
```

Text before `#book-contents()` is front matter. Put numbered chapters inside `book-mainmatter[...]`; put unnumbered supporting material in `book-appendix[...]`. Add `book-backmatter[...]` after the appendix for references or further reading. The book API and its remaining options are documented in the [book API reference](/satz/reference/api/#book).

## Compile and review the long document

For a local package directory called `packages`, compile with:

```sh
typst compile --package-path packages thesis.typ
```

Use `book.typ` instead when compiling the book example. Read the PDF from front to back. Check that contents entries point to the right pages, chapter starts and page numbers follow your institution's requirements, long headings fit, and figures and tables stay near their discussion. The [configuration reference](/satz/reference/configuration/) describes every shared setting if you need to adjust a specific value; the examples above compile without opening that reference first.

This page targets Satz 0.2.0 while it is under usability review. After it is published, change `@local` to `@preview` in the imports and keep the version at `0.2.0`.
