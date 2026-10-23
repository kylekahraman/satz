---
title: "Set up and write"
---

This guide gets a first Satz document compiling. You can try the published package in a browser without installing software, or write locally with an editor. In either case, the source is a plain-text `.typ` file and Typst produces the PDF.

## Fastest route: the Typst web app

1. Open [Typst](https://typst.app/) and create a blank project.
2. Open the [first report tutorial](/satz/getting-started/report/) and copy its complete example into the main file.
3. Wait for the live preview. Change a heading or sentence to see the preview update.
4. Export the PDF from the project when it is ready to share.

The first compile downloads the package and its dependencies. Your source remains editable in the project; the PDF is the fixed copy you can send to someone else.

## Local route: VS Code and Tinymist

1. Install [Visual Studio Code](https://code.visualstudio.com/) and the [Tinymist Typst extension](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist).
2. Create a folder for the document and open that folder in VS Code.
3. Create `main.typ` and paste in the [report example](/satz/getting-started/report/).
4. Open the Command Palette, choose **Typst Preview**, and select `main.typ` if asked.
5. Save the file as you write. Tinymist updates the preview and reports compile errors in VS Code.

Keep images, bibliography files, and included section files in the project folder. That makes their relative paths work when you move or share the project. A separate Typst CLI is optional if you use the editor preview.

## What to learn first

Typst is a markup language with commands prefixed by `#`. Start with these conventions:

| Syntax | Meaning |
| --- | --- |
| `= Main heading` | Creates a level-one heading. Use more `=` signs for lower levels. |
| A blank line | Starts a new paragraph. |
| `*important*` | Bold text. |
| `_emphasis_` | Emphasized text. |
| `- An item` | A bulleted list item. |
| `#strong[important]` | Calls a Typst function in the text. |

For now, leave the import and `#show` line in place; the show rule applies Satz's document layout to the content that follows. Learn more in the official [Typst writing tutorial](https://typst.app/docs/tutorial/writing-in-typst/).

## Compile from a terminal

Install the [Typst CLI](https://github.com/typst/typst#installation), open a terminal in the project folder, then run:

```sh
typst compile main.typ
```

This creates `main.pdf`. During writing, `typst watch main.typ` recompiles when the source changes. If compilation fails, start with the first reported error; later errors can be consequences of that one. See [Troubleshooting](/satz/guides/troubleshooting/) for common package, font, and file-path problems.

## Choose a document

Start with the full [blank file to finished document course](/satz/getting-started/complete-document/), or go straight to [a report](/satz/getting-started/report/), [a letter](/satz/getting-started/letter/), [an invoice](/satz/getting-started/invoice/), or [a research journal](/satz/guides/journals/). The [template index](/satz/reference/templates/) lists the other document types and marks features that are still development-only.
