# Troubleshooting

## The package cannot be downloaded

Check your internet connection and the import spelling: `@preview/satz:0.1.1`. The first compile needs to download Satz and its dependencies. On a restricted university network, try the browser editor or ask whether package downloads are blocked.

## Unknown argument or unknown variable

Check the version in your import. A feature labelled **development** on this site may not exist in the published `0.1.1` package. Use the matching published example or follow [the development setup](development.md).

## A font looks different or is missing

The document can only use fonts available to its compiler. A font installed on your computer may not exist in the browser editor, or on a colleague's computer. Begin with the starter's defaults; if you choose another font, make it available wherever you compile.

## The preview does not update

Save the file and confirm that Tinymist is previewing your project's `main.typ`. If you opened an individual chapter or entry, open the main document instead. Read the first error in VS Code's Problems panel; later errors may be caused by it.

## The text is too tight or too loose

Body line spacing, paragraph spacing, and heading spacing are separate settings. Adjust `typography.leading` for body lines and native `#set par(spacing: 1em)` after the show rule for paragraphs. The development version also offers `typography.paragraph-spacing`. Start with a small change and compare the PDF. See [Configuration](../reference/configuration.md#line-and-paragraph-spacing).

## An image or bibliography cannot be found

Put the file inside the project folder and use a path relative to the Typst file that reads it. Check capitalization, especially when sharing between operating systems. If a local source import goes above the project boundary, compile with an appropriate `--root`; see [Development versions](development.md).

## Should I update Satz to get a fix?

Published imports are versioned. A local source checkout can change as you edit or update it; a copied `_satz` folder stays unchanged until you replace it. See [Development versions and updates](development.md) for the tradeoff.

## I am still stuck

[Open a GitHub issue](https://github.com/kylekahraman/satz/issues) with the smallest example that reproduces the problem, the import version, and what you expected. Include a screenshot for a layout problem, and remove names, addresses, grant details, and private research data from the example.
