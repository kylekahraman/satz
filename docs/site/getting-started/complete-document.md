---
title: "From a blank file to a finished document"
description: "A beginner's step-by-step course for planning, writing, formatting, compiling, and finishing a Satz document."
---

This is the full report-writing path. It uses the same Satz 0.2.0 API as the focused tutorials and assumes the [local package setup](/satz/getting-started/setup/). You will choose a document type, create a project, write and organize real content, add a table and references, adjust the design, compile a PDF, and check the result. The example builds a short research report; the final section shows how the same steps lead into a letter, journal, invoice, or proposal.

## What you need

Install the [Typst CLI](https://github.com/typst/typst#installation) and make sure the local Satz 0.2.0 package is available. You can also install [Visual Studio Code](https://code.visualstudio.com/) and the [Tinymist Typst extension](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist) for a live preview.

Create a new folder or blank Typst project named `field-notes`. Keep the main file, images, bibliography, and included sections in this project. We will create `main.typ` and, later, `references.bib`.

## 1. Decide what the document must do

Before picking a template, write down the document's purpose, audience, required sections, and output format. For this example, the purpose is to communicate a small study to a colleague. The audience needs to understand the question, method, result, and a limitation. The finished artifact will be a PDF plus the editable source files.

Choose a full document template when you want Satz to set page layout and document-wide styles. Choose a component such as `callout` or `satz-figure` only when adding that component inside another document. The [template index](/satz/reference/templates/) explains which features are published and which require the development source.

| If you are making… | Start with… | Follow this focused guide |
| --- | --- | --- |
| Business letter | `letter` / `brief` | [Write a letter](/satz/getting-started/letter/). |
| Report, assignment, or research protocol | `report` | Continue this course, or use [Write your first report](/satz/getting-started/report/). |
| Research diary | `journal-entry`, `journal-index` | [Keep a research journal](/satz/guides/journals/). |
| Thesis or book | `custom(kind: "thesis")`, `book` | [Typeset a thesis or book](/satz/getting-started/thesis-book/). |
| Invoice | `invoice` / `rechnung` | [Create an invoice](/satz/getting-started/invoice/). |
| DFG, NWO, or project proposal | Proposal-specific template | Check current scope in [Proposal templates](/satz/guides/proposals/). |

## 2. Write the smallest complete document

Put this in `main.typ`. This is a complete report that compiles as-is:

```typst
#import "@local/satz:0.2.0": report
#show: report.with()

= Purpose

This report explains what the pilot tested, what happened, and what should
happen next. Replace this sentence with the purpose of your own document.

= Question

What changed after the intervention?

= Method

We compared the measurement before and after the intervention. Record enough
detail that a reader can understand how the comparison was made.

= Findings

The measured response changed from 0.12 at baseline to 0.38 after the
intervention. These example values are placeholders; replace them with your
actual observations.

= Limitations

This example contains only two measurements. It cannot establish whether the
change would be consistent across participants or repeated trials.

= Next steps

- Repeat the measurement with a planned sample.
- Check whether the measurement method is reliable.
- Report any changes to the procedure.
```

The first line imports the function. `#show: report.with()` applies its layout to the document that follows. A line beginning with `=` is a heading; `==` creates a subsection. A blank line separates paragraphs. A hyphen followed by a space starts a bulleted list. Typst uses `#` when you call a function or insert a computed element; ordinary prose can remain plain text.

Change the headings and replace the placeholder statements with your own content. Keep the import and show rule at the top. You can write the whole document in this single file; splitting it into multiple files is optional.

## 3. Preview your work as you write

With the local package directory from [setup](/satz/getting-started/setup/) available, compile this document from the project folder:

```sh
typst compile --package-path packages main.typ
```

Typst writes `main.pdf`. The preview is useful for checking what each edit changes, but still inspect the exported PDF: that is the file another person will read or print. If compilation fails, read the first reported error. It usually points to a misspelled name, a missing bracket, or a file path that cannot be found.

## 4. Make the structure useful to readers

Use headings to show the argument's structure, not to make text look larger. In this example, the main headings show the report's sequence. If a section is long, add a subsection such as `== Participants` under `= Method`. Do not skip heading levels just to change appearance; change the style through configuration instead.

Add facts as sentences, lists, equations, or tables according to what the reader needs. Here is a table that compares the example observations. Insert it inside the Findings section, after the first sentence:

```typst
#figure(
  table(
    columns: (1fr, auto),
    table.header([Condition], [Measured response]),
    [Baseline], [0.12],
    [After intervention], [0.38],
  ),
  caption: [Measured response before and after the intervention.],
) <response-comparison>

The values in @response-comparison show the observed change.
```

`table` lays out the cells. `figure` adds a caption and numbering. `<response-comparison>` gives the figure a unique label, and `@response-comparison` refers to it by number. Replace the values and caption with information supported by your own work. The [figures and tables tutorial](/satz/guides/figures-and-tables/) explains image paths, shorter captions, and placement.

## 5. Add a source when you cite one

If the document makes a claim from a published source, cite that source in the text and include its bibliography record. Create a file called `references.bib` next to `main.typ`:

```bibtex
@article{example2024,
  author = {Example, Alex},
  title = {Replace this with the actual article title},
  journal = {Example Journal},
  year = {2024},
  volume = {1},
  pages = {1--5},
}
```

Then add `A related method is described by @example2024.` in a paragraph and put `#bibliography("references.bib", style: "apa")` at the end of the document. Replace the sample with a real, verified reference before sharing. The path is relative to `main.typ`; keep the `.bib` file in the project folder. If your report does not cite outside sources, skip this step.

## 6. Adjust the design without losing the defaults

Start with a small override. Replace the show rule at the top with:

```typst
#show: report.with(config: (
  typography: (
    font: "Libertinus Serif",
    size: 11pt,
    leading: 0.65em,
  ),
  colors: (brand-primary: rgb("#355D50")),
))
```

Each setting is inside the group it belongs to. `leading: 0.65em` is a length and controls the gap between lines. The shared configuration is deep-merged, so this override leaves other defaults in place. The selected font must exist in the environment that compiles the PDF. Look up each field's type and effect in the [configuration reference](/satz/reference/configuration/); check the exact function signature in the [API reference](/satz/reference/api/#report). Satz 0.2.0 also supports `line-spacing: 1.25`, which requests a baseline distance 1.25 times the font size; it is a different option from `leading` and is documented separately in the reference.

When a value does not change the output, check whether the chosen template supports it. A setting listed for one template may not apply to another. The configuration reference lists the settings accepted by the 0.2.0 implementation.

## 7. Finish and check the PDF

Compile again after your final edit. Read the PDF from the first page through the last and check:

1. The title and headings describe the actual content.
2. The page breaks do not strand a heading or split an important table awkwardly.
3. Every figure and table has a useful caption and a working reference in the text.
4. Every citation has a matching bibliography entry, and the metadata is correct.
5. Names, dates, units, spelling, links, and page numbers are correct.
6. The PDF contains no placeholder text from this tutorial.

Share `main.pdf` as the reading copy. Keep `main.typ`, `references.bib`, and any images or included sections as the editable project. To rebuild later, open the project folder and run `typst compile --package-path packages main.typ` again. For a repeatable build, keep the same explicit package version and make sure the needed fonts are available.

## Continue with another document type

You now know the common cycle: choose a structure, write content, add the elements readers need, adjust supported settings, compile, and inspect the PDF. For a different kind of document, keep the writing and finishing steps but replace the report template with the relevant starter:

- [Letters](/satz/getting-started/letter/) and [invoices](/satz/getting-started/invoice/) collect structured sender/recipient fields before the body.
- [Journals](/satz/guides/journals/) organize dated entries and can generate an index.
- [Proposals](/satz/guides/proposals/) depend on the exact funder scheme and call revision; verify coverage before drafting in a candidate template.
- [All templates](/satz/reference/templates/) and their exact [inputs and outputs](/satz/reference/api/) explain the remaining document types and reusable components.
- If you hit an error, follow [Troubleshooting](/satz/guides/troubleshooting/).
