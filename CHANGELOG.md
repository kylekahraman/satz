# Changelog

## Unreleased — work toward 0.2.0

The package manifest remains at 0.1.1. These are development changes, not a
release announcement or a claim of complete LaTeX/KOMA-Script parity.

### Report typography and reusable components

- Style native headings without nested layout wrappers. Preserve native
  page-start trimming and attachment to following content.
- Expose `h1-above` through `h4-above`; `auto` preserves native spacing by
  omitting the override. Below-spacing and paragraph indentation remain
  configurable. See [the typography guide](docs/typography.md).
- Honor `tables.font-size` and `tables.inset`, which previously existed in
  configuration but were ignored.
- Add `scientific-table`: explicit header cells, stronger top/bottom rules,
  a thinner header separator, repeated headings/rules across pages, native
  table cells and optional group separators.
- Add the opt-in `scientific-tables` show rule for table figures,
  top captions, ragged-right caption text and deliberate breakability. Related
  native tables can share one figure, caption and reference.
- Add `callout`: breakable explanatory boxes, consistent paragraph/list gaps,
  inherited body type and leading, and body-height preservation for smaller
  code-only lines. The research report now consumes this shared helper.
- Keep headings ragged-right and unhyphenated by default, even in justified
  prose. Add optional attached, palette-colored callout titles with a deliberate
  title/body gap; see `examples/callout.typ`.
- Preserve left-aligned reading text in callouts nested inside centered figures.
- Expose caption alignment and label weight independently, preserving native
  labels/references and the existing long-caption/short-list workflow.
- Add `chapter-numbering` scopes: figure/table/equation prefixes remain correct
  in forward, backward and cross-appendix references. Add opt-in
  `headings.h1-pagebreak` for report chapters that start on a new page.
- Fix internal reference colors: resolved references also carry a fallback
  citation field, so testing for that field incorrectly skipped their styling.
- Expose `typography.math-font`; `auto` retains Typst's native math typeface.
  The research report explicitly selects STIX Two Math to match its LaTeX source.
- Expose `typography.mono-font` independently; `auto` retains native raw-text
  styling, while the research report selects Fira Code.
- Refine contents, figure-list, and table-list typography with configurable
  entry size, leading, row gaps, title gaps, and section gaps. Preserve Typst's
  native numbering, links, page-number formatting, and wrapped-entry indents.
- Make the contents, figure list, and table list independent; omit empty lists
  and figures marked `outlined: false`. Compact lists keep custom numbering and
  page formats while omitting captions.
- Make the six named palettes available as report themes and custom document
  palettes. Reports now default to neutral black-on-white colors; opt into a
  colored palette with `theme:`. Explicit nested color settings take precedence.
- Add `decorative.list-tight`; the default list gap is now `0.9em`, while
  `list-tight: true` selects paragraph-leading spacing. These visual changes
  can reflow existing reports; see the migration notes in the README.

### Other development work already committed

- Hydra running headers and an optional Glossarium namespace.
- Native placeholder figures and composable cover presets.
- An article entry point with native columns, author affiliations and abstract.
- Grouped chapter entries in the report contents.
- An experimental book entry point and educational components. This remains
  under review and is not the same specimen as the research report.
- A one-file letter quick start and named enclosures without embedded files.

### Letter and invoice inputs

- Accept English top-level names and English sender/recipient fields alongside
  the existing German spellings; both paths normalize to the existing renderers.
- Accept invoice items as `(description, quantity, unit-price)` records or keep
  the original tuple form. Invoice output remains German; English input does not
  imply localization.
- Report a field-specific conflict when callers provide both spellings, and
  identify missing fields in English invoice item records.

### Shared appearance precedence

- Resolve letter and invoice themes, direct appearance arguments, and nested
  config overrides through one adapter while preserving DIN-specific geometry.
- Apply the shared theme palette to article and book entry points. Book
  `accent`, `math-font`, and other direct appearance arguments now participate
  in the documented precedence order instead of bypassing nested config.
- Reject unsupported letter/invoice appearance groups and keys with a
  field-specific error. `examples/latex-parity/check_appearance_precedence.py`
  checks palette application, nested overrides, and rejection behavior.
- Validate journal dates as real calendar dates and support ISO `YYYY-MM-DD`,
  `DD/MM/YY`, and `DD/MM/YYYY` for month grouping. Optional weekday prefixes
  are accepted; blank dates remain valid for drafts and group under “Undated”.
  See `examples/latex-parity/check_journal_dates.py`.
- Validate article author/affiliation record shapes, required author names,
  one-based indices, and affiliation content types with field-specific errors.
  Unknown author keys remain available for caller metadata.
- Validate letter/invoice address record shapes and text fields, plus invoice
  item tuples/records and numeric ranges, without rejecting extension keys.

### Verification and remaining release work

- Exclude `tools/**` and local workbook conversions from the Typst package.
  A staged-package check now compiles report, article, journal, letter, invoice,
  cover, and proposal starters from the manifest-filtered tree. This verifies
  the current source tree only; published-version comparison remains open.
- Add a GitHub Actions workflow for the staged-package check and focused public
  API/PDF regressions on pushes and pull requests. Pin the Python PDF inspection
  tools used by those checks and use the current `pymupdf` module import.

The [research report audit](docs/report-parity-audit.md) distinguishes shared
package fixes from document settings and records remaining conversion/layout
gaps. Focused PDF checks cover heading flow, callout fragmentation, scientific
rules, table configuration and repeated table headings. A successful compile
does not establish visual or content parity.

The research report's missing verdict macros, grouped table captions, chapter
references and math/code typefaces are now corrected. All pages were rendered
and visually reviewed against LaTeX. Before a release: refine float distribution
and sparse chapter endings, broaden two-column/journal visual coverage, review
the final integrated package and update supported API documentation. The outline
example compiles and its extracted text contains the expected contents and lists;
the PyMuPDF geometry assertions are in `examples/latex-parity/check_outlines.py`.
