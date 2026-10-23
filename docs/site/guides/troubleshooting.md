---
title: "Troubleshoot a Satz document"
---

When a document fails, begin with the first error reported by Typst. Later errors often follow from the first one. Check the import version, file path, and value named in that error before changing layout settings.

## The package cannot be downloaded

For a 0.2.0 tutorial, check that the local package import is spelled exactly as shown: `@local/satz:0.2.0`. Pass the package directory with `typst compile --package-path packages main.typ`. After 0.2.0 is published, use `@preview/satz:0.2.0` and compile without the local package path.

The current tutorials use a local checkout because 0.2.0 is being usability-tested before publication. See [Set up the local 0.2.0 package](/satz/getting-started/setup/) for the package path.

## Typst says an argument is unknown

First compare the imported package version with the page's version label. A feature marked **development** may only exist in the 0.2.0 candidate source. Published imports are fixed to the version in the import line, so installing a newer editor does not add missing package functions.

Then check spelling and punctuation in the argument name. Use the [API reference](/satz/reference/api/) to confirm the exact name, whether it is required, and its default. For example, the letter API uses the established German field names even though `letter` is its English alias.

## Typst rejects a setting value

Check the type and accepted values in the [configuration reference](/satz/reference/configuration/). Typst values include units: write `12pt`, `5mm`, or `1.2em`, not a bare number when the setting expects a length. Strings require quotes (`"A4"` or `"Libertinus Serif"`); booleans are `true` and `false`; `none` is a special value, not the string `"none"`.

Nested settings must be dictionaries, for example `typography: (font: "Libertinus Serif")`. Satz merges nested dictionaries with defaults, so change only the field you need. Misspelled fields in known groups are rejected; a custom top-level group may be accepted but have no effect if the template does not use it.

## A font looks different or is missing

The compiler can use only fonts available to its runtime. A font installed on your computer may be unavailable in the browser editor or on a colleague's machine. Start with the template defaults. If you choose a different font, check it in the same environment that produces the PDF and share or install the font as its license permits.

## The preview does not update

Save the source file and make sure Tinymist is previewing the document's main file, usually `main.typ`, rather than an included chapter or journal entry. Look at the first message in VS Code's Problems panel. If an include or image path is wrong, fix that path before investigating later layout symptoms.

## An image, section, or bibliography cannot be found

Place the file in the project folder and use a path relative to the `.typ` file that refers to it. Check capitalization: paths that work on one operating system can fail on another if the letter case differs. For an included source that imports files above its directory, compile with an appropriate project root; the development guide explains `typst compile --root .` for local source checkouts.

## Text spacing or page layout looks wrong

Line spacing, paragraph spacing, and heading spacing are separate controls. `typography.line-spacing` sets baseline distance as a multiple of font size in the candidate; `typography.leading` sets Typst's line gap directly. Paragraph spacing controls the gap between paragraphs. See each field's type and default in [Configuration](/satz/reference/configuration/#typography-line-spacing).

For a layout that looks wrong, inspect the compiled PDF at normal zoom and as a full page. Check whether the problem appears throughout the document or only around one figure, heading, or page break. A local float-placement issue usually calls for adjusting nearby content or image width, while a repeated text-width problem may need a page-margin change.

## I need help reproducing the problem

If the issue remains, [open a GitHub issue](https://github.com/kylekahraman/satz/issues) with a minimal source file, the exact import version, the first compiler error, what you expected, and what happened instead. For a visual issue, attach a screenshot or PDF page. Remove real names, addresses, grant details, and private research data before sharing.
