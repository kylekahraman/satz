---
title: "Configuration reference"
---

This is the candidate reference for the shared styling interface; custom documents use `custom(config:)`.
It documents the executable baseline in `defaults.typ`; it does not claim that
every template consumes every key. `report`, `article`, `book`, `journal`,
`cover-page`, `letter`, `invoice`, and proposal templates add or override
settings in their own APIs. Their documented differences take precedence over
the shared baseline. The package is the unpublished 0.2.0 candidate, so these
contracts are not available from the published package.
The candidate's declared minimum compiler version is Typst 0.15.0.

Pass only values to change. Satz deep-merges dictionaries: an override such as
`(colors: (brand-primary: blue))` preserves the other color defaults. Arrays,
scalars, and non-dictionary values replace the old value. The generic `merge`
helper does not validate unknown keys. Validation is performed by individual
public APIs where supported; in particular, letters and invoices reject
unsupported keys in their documented appearance groups.

## Find a setting

Select a field to jump to its type, default, and effect. Template-specific overrides are listed below.

**page:** [`page.paper`](#page-paper), [`page.margin`](#page-margin), [`page.binding`](#page-binding), [`page.binding-correction`](#page-binding-correction), [`page.headers`](#page-headers), [`page.columns`](#page-columns), [`page.column-gutter`](#page-column-gutter)

**typography:** [`typography.font`](#typography-font), [`typography.math-font`](#typography-math-font), [`typography.mono-font`](#typography-mono-font), [`typography.size`](#typography-size), [`typography.line-spacing`](#typography-line-spacing), [`typography.leading`](#typography-leading), [`typography.paragraph-spacing`](#typography-paragraph-spacing), [`typography.first-line-indent`](#typography-first-line-indent), [`typography.hyphenate`](#typography-hyphenate), [`typography.justify`](#typography-justify)

**headings:** [`headings.numbering`](#headings-numbering), [`headings.hyphenate`](#headings-hyphenate), [`headings.h1-pagebreak`](#headings-h1-pagebreak), [`headings.spacing`](#headings-spacing)

**heading sizes and gaps:** [`headings.h1-size`](#headings-h1-size), [`headings.h2-size`](#headings-h2-size), [`headings.h3-size`](#headings-h3-size), [`headings.h4-size`](#headings-h4-size), [`headings.h1-above`](#headings-h1-above), [`headings.h2-above`](#headings-h2-above), [`headings.h3-above`](#headings-h3-above), [`headings.h4-above`](#headings-h4-above), [`headings.h1-below`](#headings-h1-below), [`headings.h2-below`](#headings-h2-below), [`headings.h3-below`](#headings-h3-below), [`headings.h4-below`](#headings-h4-below)

**journal:** [`journal.header-below`](#journal-header-below), [`journal.running-gutter`](#journal-running-gutter), [`journal.running-leading`](#journal-running-leading)

**decorative:** [`decorative.header-size`](#decorative-header-size), [`decorative.footer-size`](#decorative-footer-size), [`decorative.date-size`](#decorative-date-size), [`decorative.keywords-size`](#decorative-keywords-size), [`decorative.list-tight`](#decorative-list-tight), [`decorative.list-spacing`](#decorative-list-spacing)

**page-footer:** [`page-footer.format`](#page-footer-format), [`page-footer.size`](#page-footer-size), [`page-footer.weight`](#page-footer-weight)

**links:** [`links.color`](#links-color), [`links.url-color`](#links-url-color)

**tables:** [`tables.stroke`](#tables-stroke), [`tables.inset`](#tables-inset), [`tables.font-size`](#tables-font-size), [`tables.caption-position`](#tables-caption-position), [`tables.caption-gap`](#tables-caption-gap)

**callouts:** [`callouts.inset`](#callouts-inset), [`callouts.radius`](#callouts-radius), [`callouts.stroke`](#callouts-stroke), [`callouts.title-below`](#callouts-title-below), [`callouts.paragraph-spacing`](#callouts-paragraph-spacing), [`callouts.list-spacing`](#callouts-list-spacing)

**captions:** [`captions.size`](#captions-size), [`captions.weight`](#captions-weight), [`captions.alignment`](#captions-alignment), [`captions.label-weight`](#captions-label-weight)

**toc:** [`toc.depth`](#toc-depth), [`toc.title`](#toc-title), [`toc.indent`](#toc-indent), [`toc.entry-size`](#toc-entry-size), [`toc.leading`](#toc-leading), [`toc.entry-above`](#toc-entry-above), [`toc.main-entry-above`](#toc-main-entry-above), [`toc.title-below`](#toc-title-below), [`toc.below`](#toc-below)

**lof:** [`lof.depth`](#lof-depth), [`lof.title`](#lof-title), [`lof.indent`](#lof-indent), [`lof.entry-size`](#lof-entry-size), [`lof.leading`](#lof-leading), [`lof.entry-above`](#lof-entry-above), [`lof.title-below`](#lof-title-below), [`lof.below`](#lof-below), [`lof.compact`](#lof-compact)

**lot:** [`lot.depth`](#lot-depth), [`lot.title`](#lot-title), [`lot.indent`](#lot-indent), [`lot.entry-size`](#lot-entry-size), [`lot.leading`](#lot-leading), [`lot.entry-above`](#lot-entry-above), [`lot.title-below`](#lot-title-below), [`lot.below`](#lot-below), [`lot.compact`](#lot-compact)

**bibliography:** [`bibliography.style`](#bibliography-style)

**colors:** [`colors.bg-paper`](#colors-bg-paper), [`colors.bg-subtle`](#colors-bg-subtle), [`colors.brand-primary`](#colors-brand-primary), [`colors.brand-accent`](#colors-brand-accent), [`colors.text-main`](#colors-text-main), [`colors.text-muted`](#colors-text-muted)

**template-specific:** [`page.header-ascent`](#page-header-ascent), [`decorative.list-indent`](#decorative-list-indent), [`decorative.list-body-indent`](#decorative-list-body-indent), [`decorative.list-block-spacing`](#decorative-list-block-spacing), [`headings.h1-number-size`](#headings-h1-number-size), [article settings](#article-specific-settings), [book settings](#book-specific-settings)

## Shared defaults

Values below come from `defaults.typ`. Lengths use Typst units. Colors are
Typst color values. `auto` delegates a choice or policy to the template;
`none` disables a feature or selects the template's fallback where stated.

| Key | Type and accepted values | Shared default | Meaning and scope |
| --- | --- | --- | --- |
| <span id="page-paper"></span>`page.paper` | Typst paper name or custom page size | `"a4"` | Paper size. See [Typst page](https://typst.app/docs/reference/layout/page/). |
| <span id="page-margin"></span>`page.margin` | dictionary of edge names to lengths | `(top: 2.5cm, bottom: 2.5cm, left: 2.5cm, right: 2.5cm)` | Page margins. Two-sided templates may derive inside/outside margins. |
| <span id="page-binding"></span>`page.binding` | `none` or a horizontal alignment (`left` / `right`) | `none` | Enables two-sided inside/outside layout where supported. |
| <span id="page-binding-correction"></span>`page.binding-correction` | length | `0pt` | Extra binding-side space when two-sided layout is enabled. |
| <span id="page-headers"></span>`page.headers` | boolean | `false` | Enables a running header in templates that implement it. |
| <span id="page-columns"></span>`page.columns` | positive integer | `1` | Number of page columns where the template supports columns. |
| <span id="page-column-gutter"></span>`page.column-gutter` | length | `5mm` | Gap between columns. |
| <span id="page-header-ascent"></span>`page.header-ascent` | length | `24.442pt` in DFG | Extra ascent reserved for the DFG running header. Only used by `dfg-proposal`. |
| <span id="typography-font"></span>`typography.font` | font family name | `"Libertinus Serif"` | Main text family. Font must be installed or embedded by the runtime. |
| <span id="typography-math-font"></span>`typography.math-font` | font family name or `auto` | `auto` | Math typeface; `auto` retains Typst's native selection. |
| <span id="typography-mono-font"></span>`typography.mono-font` | font family name or `auto` | `auto` | Monospaced typeface; `auto` retains Typst's native raw-text style. |
| <span id="typography-size"></span>`typography.size` | length | `11pt` | Main text size. |
| <span id="typography-line-spacing"></span>`typography.line-spacing` | positive number or `none` | `none` | Optional baseline-to-baseline distance as a multiple of the body font size (for example `1.5`). Uses the selected font metrics and overrides `typography.leading`. |
| <span id="typography-leading"></span>`typography.leading` | length | `0.65em` | Distance between line bounds, not a multiplier. |
| <span id="typography-paragraph-spacing"></span>`typography.paragraph-spacing` | length | `1.2em` | Space between paragraphs. |
| <span id="typography-first-line-indent"></span>`typography.first-line-indent` | length | `0pt` | First-line indentation for paragraphs. |
| <span id="typography-hyphenate"></span>`typography.hyphenate` | boolean | `false` | Enables automatic word hyphenation. |
| <span id="typography-justify"></span>`typography.justify` | boolean | `true` | Justifies body paragraphs when supported. |
| <span id="headings-numbering"></span>`headings.numbering` | Typst numbering pattern/function or `none` | `"1.1"` | Heading numbering passed to the native heading system. |
| <span id="headings-hyphenate"></span>`headings.hyphenate` | boolean | `false` | Hyphenation within headings. |
| <span id="headings-h1-pagebreak"></span>`headings.h1-pagebreak` | boolean | `false` | Starts level-one headings on a new page where supported. |
| <span id="headings-spacing"></span>`headings.spacing` | `"koma"` or `"native"` | `"koma"` | Uses translated KOMA baseline skips or leaves native Typst spacing. |
| <span id="headings-h1-number-size"></span>`headings.h1-number-size` | length | `25pt` in book | Size of the level-one chapter number in the experimental book template. |
| <span id="headings-h1-size"></span><span id="headings-h2-size"></span><span id="headings-h3-size"></span><span id="headings-h4-size"></span>`headings.h1-size` … `headings.h4-size` | length | `14pt`, `12pt`, `11pt`, `11pt` | Size for heading levels one through four. Templates may override these. |
| <span id="headings-h1-above"></span><span id="headings-h2-above"></span><span id="headings-h3-above"></span><span id="headings-h4-above"></span>`headings.h1-above` … `headings.h4-above` | `auto` or length | `auto` | Space before each level. `auto` follows `headings.spacing`; an explicit length overrides the policy. |
| <span id="headings-h1-below"></span><span id="headings-h2-below"></span><span id="headings-h3-below"></span><span id="headings-h4-below"></span>`headings.h1-below` … `headings.h4-below` | `auto` or length | `auto` | Space after each level. `auto` follows native/template policy. |
| <span id="journal-header-below"></span>`journal.header-below` | length | `1.5em` | Gap between the complete entry header/date and notes. Journal only. |
| <span id="journal-running-gutter"></span>`journal.running-gutter` | length | `1em` | Gap between running-header columns. Journal only. |
| <span id="journal-running-leading"></span>`journal.running-leading` | length | `0.35em` | Line gap in a multi-line running header. Journal only. |
| <span id="decorative-header-size"></span>`decorative.header-size` | length | `9pt` | Running-header text size. |
| <span id="decorative-footer-size"></span>`decorative.footer-size` | length | `10pt` | Footer text size where implemented. |
| <span id="decorative-date-size"></span>`decorative.date-size` | length | `10pt` | Date text size where implemented. |
| <span id="decorative-keywords-size"></span>`decorative.keywords-size` | length | `9pt` | Keyword text size where implemented. |
| <span id="decorative-list-tight"></span>`decorative.list-tight` | boolean | `false` | Uses paragraph leading between list items when `true`. |
| <span id="decorative-list-spacing"></span>`decorative.list-spacing` | length | `0.9em` | Gap between list items when `list-tight` is `false`. |
| <span id="decorative-list-indent"></span>`decorative.list-indent` | length | `17.9669pt` in DFG | Indentation of list and enumeration markers in the DFG template. |
| <span id="decorative-list-body-indent"></span>`decorative.list-body-indent` | length | `5.475 × 72 ÷ 72.27 pt` in DFG | Gap from each list or enumeration marker to its body text. |
| <span id="decorative-list-block-spacing"></span>`decorative.list-block-spacing` | length | `baseline + paragraph-skip - cap + 3 × 72 ÷ 72.27 pt` in DFG | Space above and below list and enumeration blocks; uses the DFG font metrics. |
| <span id="page-footer-format"></span>`page-footer.format` | Typst numbering pattern/function | `"1"` | Page-number format where the template uses the shared footer. |
| <span id="page-footer-size"></span>`page-footer.size` | length | `10pt` | Page-number size. |
| <span id="page-footer-weight"></span>`page-footer.weight` | Typst font-weight value | `"bold"` | Page-number weight. |
| <span id="links-color"></span><span id="links-url-color"></span>`links.color`, `links.url-color` | color | `#B4313F`, `#45556c` | Internal-reference and external-URL colors respectively. |
| <span id="tables-stroke"></span>`tables.stroke` | length | `0.5pt` | Default table rule thickness for shared table helpers. |
| <span id="tables-inset"></span>`tables.inset` | length or dictionary such as `(x: 8pt, y: 4pt)` | `(x: 8pt, y: 4pt)` | Cell padding for shared table helpers. |
| <span id="tables-font-size"></span>`tables.font-size` | length | `10pt` | Text size in shared styled tables. |
| <span id="tables-caption-position"></span>`tables.caption-position` | `top` or `bottom` | `top` | Caption position for the scientific-table show rule. |
| <span id="tables-caption-gap"></span>`tables.caption-gap` | length | `6pt` | Space between a table caption and its table. |
| <span id="callouts-inset"></span>`callouts.inset` | length | `9pt` | Inner padding for `callout`. |
| <span id="callouts-radius"></span>`callouts.radius` | length | `3pt` | Corner radius for `callout`. |
| <span id="callouts-stroke"></span>`callouts.stroke` | length | `0.8pt` | Border thickness for `callout`. |
| <span id="callouts-title-below"></span>`callouts.title-below` | length | `1em` | Gap between callout title and body. |
| <span id="callouts-paragraph-spacing"></span>`callouts.paragraph-spacing` | length | `1em` | Paragraph gap inside a callout. |
| <span id="callouts-list-spacing"></span>`callouts.list-spacing` | length | `1.2em` | List-item gap inside a callout. |
| <span id="captions-size"></span>`captions.size` | length | `10pt` | Caption text size. |
| <span id="captions-weight"></span>`captions.weight` | Typst font-weight value | `"regular"` | Caption text weight. |
| <span id="captions-alignment"></span>`captions.alignment` | Typst alignment | `center` | Caption alignment. |
| <span id="captions-label-weight"></span>`captions.label-weight` | Typst font-weight value | `"regular"` | Weight of the caption label, independently of caption text. |
| <span id="toc-depth"></span>`toc.depth` | `none` or non-negative integer | `none` | `0` disables the contents; other depths depend on the template. |
| <span id="toc-title"></span>`toc.title` | content or `none` | `[Table of Contents]` | Contents title; `none` omits it. |
| <span id="toc-indent"></span>`toc.indent` | `auto` or length | `auto` | Entry indentation policy. |
| <span id="toc-entry-size"></span>`toc.entry-size` | length | `10pt` | Contents entry size. |
| <span id="toc-leading"></span>`toc.leading` | length | `0.65em` | Line gap in wrapped entries. |
| <span id="toc-entry-above"></span>`toc.entry-above` | length | `0.65em` | Gap between ordinary entries. |
| <span id="toc-main-entry-above"></span>`toc.main-entry-above` | length | `1.25em` | Extra gap before main-section entries. |
| <span id="toc-title-below"></span>`toc.title-below` | length | `1.5em` | Gap below the contents title. |
| <span id="toc-below"></span>`toc.below` | length | `2em` | Gap after the contents. |
| <span id="lof-depth"></span><span id="lot-depth"></span>`lof.depth`, `lot.depth` | `none` or non-negative integer | `none` | `0` disables the corresponding list; `none` uses automatic depth. |
| <span id="lof-title"></span><span id="lot-title"></span>`lof.title`, `lot.title` | content or `none` | `[List of Figures]`, `[List of Tables]` | Heading above the list; `none` omits the title. |
| <span id="lof-indent"></span><span id="lot-indent"></span>`lof.indent`, `lot.indent` | `auto` or length | `auto` | Indentation for nested entries. |
| <span id="lof-entry-size"></span><span id="lot-entry-size"></span>`lof.entry-size`, `lot.entry-size` | length | `10pt` | Text size for list entries. |
| <span id="lof-leading"></span><span id="lot-leading"></span>`lof.leading`, `lot.leading` | length | `0.65em` | Gap between lines in wrapped entries. |
| <span id="lof-entry-above"></span><span id="lot-entry-above"></span>`lof.entry-above`, `lot.entry-above` | length | `0.85em` | Gap before each entry. |
| <span id="lof-title-below"></span><span id="lot-title-below"></span>`lof.title-below`, `lot.title-below` | length | `1.5em` | Gap between the list title and first entry. |
| <span id="lof-below"></span><span id="lot-below"></span>`lof.below`, `lot.below` | length | `2em` | Gap after the list. |
| <span id="lof-compact"></span><span id="lot-compact"></span>`lof.compact`, `lot.compact` | boolean | `false` | When true, omit caption text and show only label and page. |
| <span id="bibliography-style"></span>`bibliography.style` | CSL style name | `"apa"` | Citation style where bibliography support is enabled. |
| <span id="colors-bg-paper"></span><span id="colors-bg-subtle"></span><span id="colors-brand-primary"></span><span id="colors-brand-accent"></span><span id="colors-text-main"></span><span id="colors-text-muted"></span>`colors.bg-paper`, `bg-subtle`, `brand-primary`, `brand-accent`, `text-main`, `text-muted` | Typst color | `#f8fafc`, `#f1f5f9`, `#1d293d`, `#0f172b`, `#020618`, `#90a1b9` | Paper, panel, accent, and text colors. Templates can provide their own palette. |


## Article-specific settings

`article` accepts these additional keys when using `article`. They control the
full-width title block and abstract; headings, page columns and typography still
use the shared settings above. See the [`article` API](/satz/reference/api/#article) for the
function inputs such as authors, affiliations, and date.

| Field | Type | Default | Effect |
| --- | --- | --- | --- |
| <span id="article-title-size"></span>`article.title-size` | length | `18pt` | Size of the title in the full-width front matter. |
| <span id="article-author-size"></span>`article.author-size` | length | `11pt` | Size of author names. |
| <span id="article-affiliation-size"></span>`article.affiliation-size` | length | `8.5pt` | Size of affiliation lines. |
| <span id="article-abstract-size"></span>`article.abstract-size` | length | `9pt` | Size of abstract text. |
| <span id="article-title-gap"></span>`article.title-gap` | length | `1em` | Vertical gap after the title and before the abstract. |
| <span id="article-body-gap"></span>`article.body-gap` | length | `1.5em` | Gap between front matter and article body. |

## Book-specific settings

The experimental `book` template accepts common shared settings through `config` and adds the `book` group below. These keys are used by the book components; defaults are for the candidate implementation.

| Field | Type | Default | Effect |
| --- | --- | --- | --- |
| <span id="book-ink"></span>`book.ink` | Typst color | `#24313B` | Color for the book cover title and chapter headings; the direct `ink:` argument can override it. |
| <span id="book-contents-title-before"></span>`book.contents.title-before` | length | `24.5pt` | Space before the contents title. |
| <span id="book-contents-title-after"></span>`book.contents.title-after` | length | `26pt` | Gap after the contents title. |
| <span id="book-contents-title-size"></span>`book.contents.title-size` | length | `17pt` | Contents title size. |
| <span id="book-contents-entry-size"></span>`book.contents.entry-size` | length | `10pt` | Text size for contents entries. |
| <span id="book-contents-entry-spacing"></span>`book.contents.entry-spacing` | length | `11.8pt` | Vertical space between contents entries. |
| <span id="book-worked-example-above"></span>`book.worked-example.above` | length | `26pt` | Space before a worked example. |
| <span id="book-worked-example-below"></span>`book.worked-example.below` | length | `27pt` | Space after a worked example. |
| <span id="book-worked-example-inset"></span>`book.worked-example.inset` | length | `27pt` | Inner padding for a worked example. |
| <span id="book-worked-example-label-gap"></span>`book.worked-example.label-gap` | length | `0pt` | Gap between the worked-example label and its body. |
| <span id="book-worked-example-label-size"></span>`book.worked-example.label-size` | length | `9pt` | Worked-example label size. |
| <span id="book-worked-example-body-size"></span>`book.worked-example.body-size` | length | `9pt` | Worked-example body size. |
| <span id="book-exercise-grid-gap"></span>`book.exercise.grid-gap` | length | `11pt` | Space between an exercise prompt and its answer grid. |
| <span id="book-exercise-group-gap"></span>`book.exercise.group-gap` | length | `20pt` | Space between exercise groups. |
| <span id="book-footer-dy"></span>`book.footer-dy` | length | `5pt` | Vertical offset for the page number. |
| <span id="book-cover-top"></span>`book.cover-top` | length | `28mm` | Top spacing for the book cover layout. |
| <span id="book-cover-eyebrow-size"></span>`book.cover-eyebrow-size` | length | `14.3pt` | Cover eyebrow text size. |
| <span id="book-cover-eyebrow-below"></span>`book.cover-eyebrow-below` | length | `14mm` | Space below the eyebrow. |
| <span id="book-cover-title-size"></span>`book.cover-title-size` | length | `25pt` | Cover title size. |
| <span id="book-cover-title-leading"></span>`book.cover-title-leading` | length | `8pt` | Gap between cover-title lines. |
| <span id="book-cover-title-below"></span>`book.cover-title-below` | length | `13.5mm` | Space below the cover title. |
| <span id="book-cover-subtitle-size"></span>`book.cover-subtitle-size` | length | `14.3pt` | Cover subtitle size. |
| <span id="book-cover-subtitle-leading"></span>`book.cover-subtitle-leading` | length | `6.5pt` | Gap between subtitle lines. |
| <span id="book-cover-subtitle-below"></span>`book.cover-subtitle-below` | length | `21.6mm` | Space below the subtitle. |
| <span id="book-cover-rule-width"></span>`book.cover-rule-width` | length | `0.8pt` | Cover divider rule thickness. |
| <span id="book-cover-author-size"></span>`book.cover-author-size` | length | `12pt` | Cover author size. |
| <span id="book-cover-author-below"></span>`book.cover-author-below` | length | `3pt` | Space below the author. |
| <span id="book-cover-note-size"></span>`book.cover-note-size` | length | `10pt` | Cover note size. |
| <span id="book-cover-note-below"></span>`book.cover-note-below` | length | `11.2mm` | Space below the cover note. |
| <span id="book-cover-date-dy"></span>`book.cover-date-dy` | length | `6.5pt` | Vertical offset for the cover date. |

The complete group is defined by the [book template](https://github.com/kylekahraman/satz/blob/main/book/template.typ). The [`book` API entry](/satz/reference/api/#book) documents its direct arguments and how to compose the book components.

## Template-specific appearance defaults

These values override the shared baseline when the named template is used.
They are appearance defaults only; the wrappers also expose content-specific
arguments described in their source API comments and guides.

| Template | Defaults or notable differences |
| --- | --- |
| `custom` | Uses the shared defaults table above. `kind` defaults to `"report"`; other kinds can change front matter, numbering, headers, and bibliography behavior. |
| `report` | `theme: "neutral"`; all remaining appearance defaults come from the internal shared document class. `theme: none` leaves the shared palette in place. |
| `article` | `page.columns: 2`; `typography.size: 10pt`, `hyphenate: true`; heading numbering `none`, sizes `12pt`, `10.5pt`, `10pt`, `10pt`; `toc.depth`, `lof.depth`, `lot.depth: 0`; white paper. Article layout fields: title `18pt`, author `11pt`, affiliation `8.5pt`, abstract `9pt`, title gap `1em`, body gap `1.5em`. |
| `journal-entry` / `journal-index` | `page.paper: "iso-b5"`; margins `(x: 2cm, top: 2.5cm, bottom: 2.5cm)`; body `Libertinus Serif 11pt`, `0.65em` leading, no hyphenation, justified; h1 `16pt`, h2 `12pt`, h3/h4 `11pt`; date `10pt`, header/footer `9pt`/`10pt`; list gap `0.65em`; neutral gray palette. Journal block and running-header gaps are in `journal.*` above. |
| `letter` / `brief` | DIN A4, margins `(left: 25mm, right: 20mm, top: 25mm, bottom: 25mm)`, Inter `11pt`, `0.65em` leading, justified, no hyphenation, black text/accent, white paper. Direct options include `font`, `papier`, `seitenraender`, `schriftgroesse`, `zeilenabstand`, and `blocksatz`; nested config only accepts the documented page, typography, color, and link keys. |
| `invoice` / `rechnung` | Same DIN page geometry and Inter `11pt`, `0.65em` leading; output remains German. Direct `font` is supported. Nested config accepts the same limited appearance keys as letters. |
| `book` (experimental) | A4; margins `(left: 27mm, right: 25mm, top: 25mm, bottom: 27mm)`; left binding with `5mm` correction; Libertinus Serif `11pt`; New Computer Modern Math; `0.74em` leading; `14pt` paragraph gap; no page headers; default teal accent and dark slate ink. `theme: none` selects these defaults. |
| `cover-page` | A4, `2.5cm` margins, Libertinus Serif `11pt`, black-on-white neutral cover palette; `theme` defaults to `"neutral"`, and layout defaults to `"classic"`. Generated title content requires `layout: "research"` or `"minimal"`; classic remains the composable slot-based layout. The research layout leaves `4.5cm` above its title block. |
| `research-proposal` / `project-proposal` | No contents/lists; margins `(x: 25mm, y: 25mm)`; white paper, black text and links; paragraph gap `0.7em`; heading numbering `"1.1"`. |
| `dfg-proposal` | DFG form 53.01 (09/26), A4, margins `(left: 25mm, right: 20mm, top: 25mm, bottom: 15mm)`; Arial `11pt`, form-specific leading, four-level numbering `"1.1.1.1"`; no contents/lists; black text/links; left captions. |
| `nwo-proposal` | Only source-checked 2026 profiles; A4 with `25mm` margins; Arial, 9.5pt pre-proposal or 10pt Vici full form; no contents/lists; black text/links. Form profile controls remaining typography and page budget. |

These wrappers intentionally do not share identical layouts. Their appearance
inputs follow the documented per-template contract; omitted values use the
template-specific defaults in this table.
