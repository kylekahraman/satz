# Set up and write

You can use Satz in a browser or on your own computer. Both routes produce a PDF. You do not need LaTeX, Python, Go, or a command line to try the published templates.

## Try it in your browser

1. Open the [Typst web app](https://typst.app/) and create a blank project.
2. Paste the example from [Write your first report](report.md) into its main file.
3. Change a heading or paragraph and watch the preview update.
4. Export the PDF when you are ready to share it.

The package downloads on the first compile. Your source stays editable; the PDF is the copy you share with readers.

## Use VS Code on Windows, macOS, or Linux

1. Install [Visual Studio Code](https://code.visualstudio.com/).
2. Install the [Tinymist Typst extension](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist). It supplies the editor integration and preview; a separate Typst CLI is optional for this route.
3. Create a folder for your document and open that folder in VS Code.
4. Create `main.typ`, then paste in the [report example](report.md).
5. Open the Command Palette and search for **Typst Preview** to open the preview provided by Tinymist.

Save your source files as you work. Keep any images or bibliography files inside your project folder so the document is easy to move or share.

## What do I have to learn?

Start with these four conventions:

| Write | Meaning |
| --- | --- |
| `= Heading` | A heading; add another `=` for a subsection |
| A blank line | Start a new paragraph |
| `*important*` | Bold text |
| `- An item` | A list item |

Commands start with `#`. Leave the import and show rule at the top of the starter while you learn. The [Typst writing tutorial](https://typst.app/docs/tutorial/writing-in-typst/) explains the rest as you need it.

## Prefer the terminal?

With the [Typst CLI](https://github.com/typst/typst#installation) installed, run this from your document folder:

```sh
typst compile main.typ
```

It creates `main.pdf`. For automatic rebuilding while you write, use `typst watch main.typ`.
