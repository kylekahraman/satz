# Satz configuration reference — 0.2.0 candidate

This is the candidate reference for the shared `personal(config:)` interface.
It documents the executable baseline in `defaults.typ`; it does not claim that
every template consumes every key. `report`, `article`, `book`, `journal`,
`cover-page`, `letter`, `invoice`, and proposal templates add or override
settings in their own APIs. Their documented differences take precedence over
the shared baseline. The package is still 0.1.1, so these candidate contracts
are not available from the published package.
The candidate's declared minimum compiler version is Typst 0.15.0.

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

## Template-specific appearance defaults

These values override the shared baseline when the named template is used.
They are appearance defaults only; the wrappers also expose content-specific
arguments described in their source API comments and guides.

| Template | Defaults or notable differences |
| --- | --- |
| `personal` | Uses the shared defaults table above. `kind` defaults to `"report"`; other kinds can change front matter, numbering, headers, and bibliography behavior. |
| `report` | `theme: "neutral"`; all remaining appearance defaults come from `personal`. `theme: none` leaves the shared palette in place. |
| `article` | `page.columns: 2`; `typography.size: 10pt`, `hyphenate: true`; heading numbering `none`, sizes `12pt`, `10.5pt`, `10pt`, `10pt`; `toc.depth`, `lof.depth`, `lot.depth: 0`; white paper. Article layout fields: title `18pt`, author `11pt`, affiliation `8.5pt`, abstract `9pt`, title gap `1em`, body gap `1.5em`. |
| `journal-entry` / `journal-index` | `page.paper: "iso-b5"`; margins `(x: 2cm, top: 2.5cm, bottom: 2.5cm)`; body `Libertinus Serif 11pt`, `0.65em` leading, no hyphenation, justified; h1 `16pt`, h2 `12pt`, h3/h4 `11pt`; date `10pt`, header/footer `9pt`/`10pt`; list gap `0.65em`; neutral gray palette. Journal block and running-header gaps are in `journal.*` above. |
| `letter` / `brief` | DIN A4, margins `(left: 25mm, right: 20mm, top: 25mm, bottom: 25mm)`, Inter `11pt`, `0.65em` leading, justified, no hyphenation, black text/accent, white paper. Direct options include `font`, `papier`, `seitenraender`, `schriftgroesse`, `zeilenabstand`, and `blocksatz`; nested config only accepts the documented page, typography, color, and link keys. |
| `invoice` / `rechnung` | Same DIN page geometry and Inter `11pt`, `0.65em` leading; output remains German. Direct `font` is supported. Nested config accepts the same limited appearance keys as letters. |
| `book` (experimental) | A4; margins `(left: 27mm, right: 25mm, top: 25mm, bottom: 27mm)`; left binding with `5mm` correction; Libertinus Serif `11pt`; New Computer Modern Math; `0.74em` leading; `14pt` paragraph gap; no page headers; default teal accent and dark slate ink. `theme: none` selects these defaults. |
| `cover-page` | A4, `2.5cm` margins, Libertinus Serif `11pt`, neutral cover palette; `theme` defaults to `"neutral"`, and layout defaults to `"classic"`. Generated title content requires `layout: "research"` or `"minimal"`; classic remains the composable slot-based layout. |
| `research-proposal` / `project-proposal` | No contents/lists; margins `(x: 25mm, y: 25mm)`; white paper, black text and links; paragraph gap `0.7em`; heading numbering `"1.1"`. |
| `dfg-proposal` | DFG form 53.01 (09/26), A4, margins `(left: 25mm, right: 20mm, top: 25mm, bottom: 15mm)`; Arial `11pt`, form-specific leading, four-level numbering `"1.1.1.1"`; no contents/lists; black text/links; left captions. |
| `nwo-proposal` | Only source-checked 2026 profiles; A4 with `25mm` margins; Arial, 9.5pt pre-proposal or 10pt Vici full form; no contents/lists; black text/links. Form profile controls remaining typography and page budget. |

These wrappers intentionally do not share identical layouts. Their appearance
inputs follow the documented per-template contract; omitted values use the
template-specific defaults in this table.

## Candidate examples

This compiles with the candidate `personal` API and illustrates a minimal
override. A report or other template may expose its own wrapper around
`personal`:

```typst
#import "@local/satz:0.2.0": personal
#show: personal.with(config: (
  typography: (font: "EB Garamond", size: 12pt),
  colors: (brand-primary: rgb("#355D50")),
))
= A heading
Body text.
```

`@local/satz:0.2.0` refers to the isolated candidate package tree used by the
release check. For ordinary use, import the published package version. The
0.2.0 candidate has not been published.

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

Letter and invoice sender/recipient values must be dictionaries. Text address
fields (`name`, street, postal-code/city, country, and contact/billing fields)
must be strings; sender logos accept Typst content or `none`. Invoice items are
three-value arrays `(description, quantity, unit-price)` or records with those
three fields. Descriptions accept strings or content, quantities are positive
numbers, and unit prices are non-negative numbers. The existing German tuple
form remains supported.

`brief` / `letter` accepts only `lang: "de"` or `lang: "en"` (the English
alias is `language:`). DFG proposals accept `form-date` as a display string and
`check-pages` as a boolean. NWO profiles currently require the integer year
`2026`; an equal-looking floating-point value is rejected.
