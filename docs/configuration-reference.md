# Satz configuration reference — 0.2.0 candidate

This is the candidate reference for the shared `personal(config:)` interface.
It documents the executable baseline in `defaults.typ`; it does not claim that
every template consumes every key. `report`, `article`, `book`, `journal`,
`cover-page`, `letter`, `invoice`, and proposal templates add or override
settings in their own APIs. Their documented differences take precedence over
the shared baseline. The package is still 0.1.1, so these candidate contracts
are not available from the published package.

Pass only values to change. Satz deep-merges dictionaries: an override such as
`(colors: (brand-primary: blue))` preserves the other color defaults. Arrays,
scalars, and non-dictionary values replace the old value. The generic `merge`
helper does not validate unknown keys. Validation is performed by individual
public APIs where supported; in particular, letters and invoices reject
unsupported keys in their documented appearance groups.

## Shared defaults

Values below come from `defaults.typ`. Lengths use Typst units. Colors are
Typst color values. `auto` delegates a choice or policy to the template;
`none` disables a feature or selects the template's fallback where stated.

| Key | Type and accepted values | Shared default | Meaning and scope |
| --- | --- | --- | --- |
| `page.paper` | Typst paper name or custom page size | `"a4"` | Paper size. See [Typst page](https://typst.app/docs/reference/layout/page/). |
| `page.margin` | dictionary of edge names to lengths | `(top: 2.5cm, bottom: 2.5cm, left: 2.5cm, right: 2.5cm)` | Page margins. Two-sided templates may derive inside/outside margins. |
| `page.binding` | `none` or a horizontal alignment (`left` / `right`) | `none` | Enables two-sided inside/outside layout where supported. |
| `page.binding-correction` | length | `0pt` | Extra binding-side space when two-sided layout is enabled. |
| `page.headers` | boolean | `false` | Enables a running header in templates that implement it. |
| `page.columns` | positive integer | `1` | Number of page columns where the template supports columns. |
| `page.column-gutter` | length | `5mm` | Gap between columns. |
| `typography.font` | font family name | `"Libertinus Serif"` | Main text family. Font must be installed or embedded by the runtime. |
| `typography.math-font` | font family name or `auto` | `auto` | Math typeface; `auto` retains Typst's native selection. |
| `typography.mono-font` | font family name or `auto` | `auto` | Monospaced typeface; `auto` retains Typst's native raw-text style. |
| `typography.size` | length | `11pt` | Main text size. |
| `typography.leading` | length | `0.65em` | Distance between line bounds, not a multiplier. |
| `typography.paragraph-spacing` | length | `1.2em` | Space between paragraphs. |
| `typography.first-line-indent` | length | `0pt` | First-line indentation for paragraphs. |
| `typography.hyphenate` | boolean | `false` | Enables automatic word hyphenation. |
| `typography.justify` | boolean | `true` | Justifies body paragraphs when supported. |
| `headings.numbering` | Typst numbering pattern/function or `none` | `"1.1"` | Heading numbering passed to the native heading system. |
| `headings.hyphenate` | boolean | `false` | Hyphenation within headings. |
| `headings.h1-pagebreak` | boolean | `false` | Starts level-one headings on a new page where supported. |
| `headings.spacing` | `"koma"` or `"native"` | `"koma"` | Uses translated KOMA baseline skips or leaves native Typst spacing. |
| `headings.h1-size` … `headings.h4-size` | length | `14pt`, `12pt`, `11pt`, `11pt` | Size for heading levels one through four. Templates may override these. |
| `headings.h1-above` … `headings.h4-above` | `auto` or length | `auto` | Space before each level. `auto` follows `headings.spacing`; an explicit length overrides the policy. |
| `headings.h1-below` … `headings.h4-below` | `auto` or length | `auto` | Space after each level. `auto` follows native/template policy. |
| `journal.header-below` | length | `1.5em` | Gap between the complete entry header/date and notes. Journal only. |
| `journal.running-gutter` | length | `1em` | Gap between running-header columns. Journal only. |
| `journal.running-leading` | length | `0.35em` | Line gap in a multi-line running header. Journal only. |
| `decorative.header-size` | length | `9pt` | Running-header text size. |
| `decorative.footer-size` | length | `10pt` | Footer text size where implemented. |
| `decorative.date-size` | length | `10pt` | Date text size where implemented. |
| `decorative.keywords-size` | length | `9pt` | Keyword text size where implemented. |
| `decorative.list-tight` | boolean | `false` | Uses paragraph leading between list items when `true`. |
| `decorative.list-spacing` | length | `0.9em` | Gap between list items when `list-tight` is `false`. |
| `page-footer.format` | Typst numbering pattern/function | `"1"` | Page-number format where the template uses the shared footer. |
| `page-footer.size` | length | `10pt` | Page-number size. |
| `page-footer.weight` | Typst font-weight value | `"bold"` | Page-number weight. |
| `links.color`, `links.url-color` | color | `#B4313F`, `#45556c` | Internal-reference and external-URL colors respectively. |
| `tables.stroke` | length | `0.5pt` | Default table rule thickness for shared table helpers. |
| `tables.inset` | length or dictionary such as `(x: 8pt, y: 4pt)` | `(x: 8pt, y: 4pt)` | Cell padding for shared table helpers. |
| `tables.font-size` | length | `10pt` | Text size in shared styled tables. |
| `tables.caption-position` | `top` or `bottom` | `top` | Caption position for the scientific-table show rule. |
| `tables.caption-gap` | length | `6pt` | Space between a table caption and its table. |
| `callouts.inset` | length | `9pt` | Inner padding for `callout`. |
| `callouts.radius` | length | `3pt` | Corner radius for `callout`. |
| `callouts.stroke` | length | `0.8pt` | Border thickness for `callout`. |
| `callouts.title-below` | length | `1em` | Gap between callout title and body. |
| `callouts.paragraph-spacing` | length | `1em` | Paragraph gap inside a callout. |
| `callouts.list-spacing` | length | `1.2em` | List-item gap inside a callout. |
| `captions.size` | length | `10pt` | Caption text size. |
| `captions.weight` | Typst font-weight value | `"regular"` | Caption text weight. |
| `captions.alignment` | Typst alignment | `center` | Caption alignment. |
| `captions.label-weight` | Typst font-weight value | `"regular"` | Weight of the caption label, independently of caption text. |
| `toc.depth` | `none` or non-negative integer | `none` | `0` disables the contents; other depths depend on the template. |
| `toc.title` | content or `none` | `[Table of Contents]` | Contents title; `none` omits it. |
| `toc.indent` | `auto` or length | `auto` | Entry indentation policy. |
| `toc.entry-size` | length | `10pt` | Contents entry size. |
| `toc.leading` | length | `0.65em` | Line gap in wrapped entries. |
| `toc.entry-above` | length | `0.65em` | Gap between ordinary entries. |
| `toc.main-entry-above` | length | `1.25em` | Extra gap before main-section entries. |
| `toc.title-below` | length | `1.5em` | Gap below the contents title. |
| `toc.below` | length | `2em` | Gap after the contents. |
| `lof.*`, `lot.*` | Same value forms as matching `toc.*` keys, plus boolean `compact` | `depth: none`, titles `[List of Figures]` / `[List of Tables]`, `indent: auto`, `entry-size: 10pt`, `leading: 0.65em`, `entry-above: 0.85em`, `title-below: 1.5em`, `below: 2em`, `compact: false` | Figure/table list settings. Here `depth: none` selects automatic depth. Empty lists are omitted by the report implementation. `compact: true` omits caption text. |
| `bibliography.style` | CSL style name | `"apa"` | Citation style where bibliography support is enabled. |
| `colors.bg-paper`, `bg-subtle`, `brand-primary`, `brand-accent`, `text-main`, `text-muted` | Typst color | `#f8fafc`, `#f1f5f9`, `#1d293d`, `#0f172b`, `#020618`, `#90a1b9` | Paper, panel, accent, and text colors. Templates can provide their own palette. |

## Candidate examples

This compiles with the candidate `personal` API and illustrates a minimal
override. A report or other template may expose its own wrapper around
`personal`:

```typst
#import "@local/satz:0.1.1": personal
#show: personal.with(config: (
  typography: (font: "EB Garamond", size: 12pt),
  colors: (brand-primary: rgb("#355D50")),
))
= A heading
Body text.
```

`@local/satz:0.1.1` is a local development-package example only. Replace it
with the intended pinned package when compiling a published-version document.
The 0.2.0 candidate has not been published.

The versioned reference is in progress. Before release, add the remaining
template-specific function arguments and nested input records, check each
listed default against executable template defaults, and compile the examples
against both the candidate and any published version they declare.

Journal entry dates have a separate value contract: empty strings are allowed
for drafts; otherwise use ISO `YYYY-MM-DD`, `DD/MM/YY`, or `DD/MM/YYYY`, with an
optional weekday prefix separated by a comma or one space. Calendar values are
validated, and an empty date is grouped as “Undated” in the monthly index. See
the [journal guide](site/guides/journals.md).

For `article`, `authors` is an array of dictionaries with a required `name`
(string or content) and optional `affiliations` (an array of one-based integer
indices). The top-level `affiliations` value is an array of strings or content.
Out-of-range indices and malformed records produce field-specific errors;
unknown author dictionary keys are preserved for caller-side metadata.
