# Page layout and columns

Satz templates use native Typst page and layout behavior. Choose a template for the document structure, then use shared configuration for common page settings.

## Reports

Reports use one column by default and can use binding correction and two-sided headers. Page margins, paper size, columns, and gutter are configured under `page`.

## Articles

The article entry point provides a title, author/affiliation block, abstract, and two-column body. Its API is in development; see the [article example](https://github.com/kylekahraman/satz/blob/main/examples/article.typ). Native figures can use a column width or span both columns. Mixed-width figures can change page flow, so review their placement in the compiled document.

## Two-sided documents

Set a binding edge to use inside/outside margins and alternating page furniture. Check the print preview as a facing-page spread before binding a book or report.

For current configuration keys, see [Configuration](../reference/configuration.md).
