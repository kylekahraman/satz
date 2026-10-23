---
title: "Set up and write"
---

Every tutorial in this release check targets Satz 0.2.0. Since the package has not been published yet, compile against a local checkout with the Typst CLI. After 0.2.0 is published, the same imports can use `@preview` and the Typst web app.

## Make the local package available

1. Install the [Typst CLI](https://github.com/typst/typst#installation) and clone or locate the Satz repository. The checkout's `typst.toml` identifies it as version `0.2.0`.
2. Create a document project folder and a local package directory inside it:

   ```sh
   mkdir -p packages/local/satz
   ln -s /absolute/path/to/satz packages/local/satz/0.2.0
   ```

   Replace `/absolute/path/to/satz` with the path to the repository checkout. On Windows, create a directory symlink to the checkout with the equivalent command for your shell.

3. Create `main.typ` in the project folder. Tutorials import the package as `@local/satz:0.2.0`.
4. Compile from the project folder and pass the package directory:

   ```sh
   typst compile --package-path packages main.typ
   ```

Keep images, bibliography files, and included section files in the project folder so their relative paths work when you move or share the project. You can also open the project in VS Code with Tinymist and use its preview; make sure its package path points to `packages`.

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

After setting up the local package directory, open a terminal in the project folder and run:

```sh
typst compile --package-path packages main.typ
```

This creates `main.pdf`. During writing, `typst watch --package-path packages main.typ` recompiles when the source changes. If compilation fails, start with the first reported error; later errors can be consequences of that one. See [Troubleshooting](/satz/guides/troubleshooting/) for common package, font, and file-path problems.

## Choose a document

Follow the tutorials in order: [write a letter](/satz/getting-started/letter/), [write a report](/satz/getting-started/report/), [keep a research journal](/satz/guides/journals/), then [typeset a thesis or book](/satz/getting-started/thesis-book/). The [complete-document course](/satz/getting-started/complete-document/) covers longer report writing; the [template index](/satz/reference/templates/) lists other document types.
