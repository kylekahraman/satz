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

### Other development work already committed

- Hydra running headers and an optional Glossarium namespace.
- Native placeholder figures and composable cover presets.
- An article entry point with native columns, author affiliations and abstract.
- Grouped chapter entries in the report contents.
- An experimental book entry point and educational components. This remains
  under review and is not the same specimen as the research report.
- A one-file letter quick start and named enclosures without embedded files.

### Verification and remaining release work

The [research report audit](docs/report-parity-audit.md) distinguishes shared
package fixes from document settings and records remaining conversion/layout
gaps. Focused PDF checks cover heading flow, callout fragmentation, scientific
rules, table configuration and repeated table headings. A successful compile
does not establish visual or content parity.

Before a release: resolve the report's missing converted macros, review table
grouping/captions and figure placement, verify the final integrated package in
real report and journal consumers, and update the supported API documentation.
Concurrent outline/palette work is not represented here as a verified release.
