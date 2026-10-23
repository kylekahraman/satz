---
title: "Your next document starts here"
---

Satz gives your reports, research journals, letters, and proposals a consistent starting point in [Typst](https://typst.app/). You write the content; Satz supplies the document layout. Start with one file and change the settings when you need to.

**New to Typst?** Follow the full [blank file to finished document course](/satz/getting-started/complete-document/). It teaches the writing and compiling steps from the beginning. Use [Set up and write](/satz/getting-started/setup/) if you first need to choose an editor.

## What would you like to write?

| Your document | Start here |
| --- | --- |
| Letter | [Write a letter](/satz/getting-started/letter/) |
| Report, assignment, or research protocol | [Write your first report](/satz/getting-started/report/) |
| Research diary or meeting notes | [Start a journal](/satz/guides/journals/) |
| Thesis or book | [Typeset a thesis or book](/satz/getting-started/thesis-book/) |
| Invoice | [Create an invoice](/satz/getting-started/invoice/) |
| Research article | [Write a research article](/satz/getting-started/article/) |
| Grant or project proposal | [Proposal templates and coverage](/satz/guides/proposals/) |
| Cover page | [Add a cover page](/satz/getting-started/cover-page/) |
| Legal complaint | [Prepare a legal complaint document](/satz/getting-started/legal-complaint/) |
| Guest performance contract | [Create a guest performance contract](/satz/getting-started/guest-contract/) |
| Something else | [Choose a template](/satz/reference/templates/) |

## A quick first letter

Create a file called `main.typ` and paste this in:

```typst
#import "@local/satz:0.2.0": letter
#show: letter.with(
  sender: (name: "Alex Example", street: "One Street", postal-code-city: "12345 Example City"),
  recipient: (name: "Research Office", street: "Sample Road", postal-code-city: "54321 Sample City"),
  subject: "A first letter",
  language: "en",
)

Dear Research Office,

This is my first letter with Satz.

Kind regards,

Alex Example
```

The import loads the letter template; the show rule places the sender, recipient, and subject above your message. Edit the details and the message, then compile the PDF. The [letter tutorial](/satz/getting-started/letter/) explains postal letters, digital PDFs, and optional fields.

## Make it yours

[Change fonts, spacing, and colors](/satz/reference/configuration/), [add figures and tables](/satz/guides/figures-and-tables/), or [split a growing document into sections](/satz/getting-started/report/#5-split-a-longer-report-into-files). If something goes wrong, start with [Troubleshooting](/satz/guides/troubleshooting/).

## Which version am I using?

Every tutorial on this site targets **Satz 0.2.0**. The package is being usability-tested from a local checkout, so the examples import `@local/satz:0.2.0`. After 0.2.0 is published, change `@local` to `@preview`; the version stays `0.2.0`.

Have a question or a confusing example? [Open an issue on GitHub](https://github.com/kylekahraman/satz/issues). Describe what you wanted to do and include a small example without private information.
