---
title: "How to contribute"
description: "A practical path for changing Satz templates, configuration, and shared layout behavior."
---

Satz is a Typst package, so the most useful contribution is a small, compiling document that demonstrates the change. Before editing, check the [roadmap](https://github.com/kylekahraman/satz/blob/main/TODO.md), the [package architecture](/satz/maintainers/architecture/), and the existing public contract in the [API reference](/satz/reference/api/).

## Pick the right place for a change

1. **A new document field or behavior for one template:** edit that template's public function, usually in its `template.typ` or main implementation file.
2. **A visual setting shared across document types:** add its default to `defaults.typ`, use it in the shared class, and document it in the configuration reference.
3. **A visual setting used by one template only:** add a template-specific default and keep its description beside that template's reference section.
4. **A reusable visual element:** put it with the template or document family that owns it. Export it from `lib.typ` only if users should call it directly.
5. **A dependency feature:** expose the upstream function when it already provides a good interface. Add a Satz wrapper when it supplies a meaningful default or coordinates behavior across the document.

Avoid adding an option that only duplicates a native Typst setting. Keep document data in template arguments, shared appearance in `config`, and local appearance on the item that uses it.

## Add a configuration field

1. Add a sensible default in the shared or template-specific defaults dictionary.
2. Decide whether the field's type and allowed values can be checked at the public entry point. Add a clear assertion for invalid values when silent misuse would be confusing.
3. Use the field from the implementation; avoid keeping a setting that does not affect output.
4. Add a field-level entry to `docs/site/reference/configuration.md` with type, default, effect, and an anchor.
5. Add an example showing a small override, and compile it.

Shared groups in `defaults.typ` participate in common validation. If a new shared key should be accepted there, add it to the default group. Template-specific values can remain in their own group; keep those values documented and validate them in the template that owns them.

## Add a template or public helper

1. Create or extend the relevant template folder. Keep its public function, defaults, components, and compiling example close together.
2. Use named arguments for semantic fields, and accept `config` for appearance that follows the shared contract.
3. Reuse `document-class()` when the document needs the shared page, text, heading, and paragraph behavior. A standalone helper should not install global show rules unless its documented use requires that.
4. Write `///` documentation for each exported function. State each argument's type, default, accepted values, and whether it expects content or returns content. Include a short example.
5. Export the intended public name from `lib.typ`, then add it to the overview table and detailed section in `docs/site/reference/api.md`.
6. Add a real example or focused regression check in `examples/` and include the source in the existing check workflow when appropriate.

Do not export internal helpers merely to make one example compile. Public exports are a compatibility commitment.

## Verify the change

For a focused source check, use Typst 0.15.0 or the version named by the project and compile the relevant example from the repository root:

```sh
typst compile --root . journal/example.typ /tmp/satz-journal-check.pdf
```

For the documentation site, from the repository root run:

```sh
npm ci
npm run build
python3 tools/docs/check.py
```

The documentation check compiles beginner examples against the package version they declare and checks internal links and page structure. The release workflow also runs focused PDF checks, including:

```sh
python3 examples/latex-parity/check_journal_dates.py
python3 examples/latex-parity/check_public_input_validation.py
```

For page-layout changes, compile a longer real example and inspect the PDF. Check the page breaks, headings, page numbers, headers, and links affected by the change. Do not commit generated PDFs.

## Keep the public contract aligned

Update the API or configuration reference in the same change as the implementation. Mark candidate-only features clearly so readers do not copy them into documents using a published version that lacks them. If a change breaks existing source, document the migration and compatibility decision; do not quietly rename a public argument.

Before release, reconcile the roadmap and changelog, compile examples against the candidate and the published baseline where relevant, inspect representative PDFs, and verify that the documentation deployment completed. See [API design and maintenance](/satz/maintainers/api-design/) for the package's conventions.
