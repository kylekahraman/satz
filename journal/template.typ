#import "@preview/cheq:0.4.0": checklist
#import "../class.typ": document-class
#import "../defaults.typ": defaults, merge, validate-config
#import "defaults.typ": defaults as journal-defaults
#import "../themes.typ": theme-config
#import "components.typ": journal-metadata-entry, journal-date-keywords, remember, question
#import "dates.typ": journal-date-parts

/// Reserved internal state slot initialized as `true`.
///
/// Current journal layout and index behavior use `journal-state` and Typst's
/// native page flow; this value is not read or updated by the current template.
#let journal-entry-state = state("entry-start", true)

/// Internal state for the running header of the current journal entry.
///
/// Each `journal-entry` stores its title, date, and first page here. On later
/// pages, the header reads these values and shows the entry title and date; the
/// saved start page prevents that header from appearing on the first page.
#let journal-state = state("journal-entry-state", (
  title: "",
  date: "",
  page: 0,
))

/// One journal entry: title, date, keywords, and notes.
///
/// You get a heading, date and keyword badges, and a running header that keeps
/// showing the title and date on later pages. Checklists work with
/// `- [ ] todo` and `- [x] done`. Journal entries use ISO B5 paper by default.
///
/// ```example
/// #journal-index()
/// #journal-entry(
///   title: [Pilot run],
///   date: "2026-10-27",
///   keywords: "DCM, working memory",
/// )[
///   - [ ] Check the model comparison.
/// ]
/// ```
///
/// - title (str): entry title; inserted verbatim
/// - date (str): `YYYY-MM-DD` or `DD/MM/YY` / `DD/MM/YYYY`, optionally
///   preceded by a weekday; empty is allowed for drafts
/// - keywords (str): comma-separated keywords, e.g. `"MEG, ICA"`; inserted
///   verbatim
/// - body (content): your notes
/// - config (dictionary): nested overrides. Dictionaries merge recursively;
///   explicit `config` values win over the journal defaults and `theme`.
///   Unspecified values keep the defaults below. Only listed fields are read
///   by this template or the shared document class. Lengths are Typst lengths,
///   colors are Typst colors, and content fields accept Typst content.
///   - `page.paper` (paper name or custom size; `"iso-b5"`): paper format.
///   - `page.margin` (dictionary; left/right `2cm`, top/bottom `2.5cm`): page
///     edges. Edge values are lengths; `x` and `y` set horizontal/vertical
///     pairs. `inside` and `outside` are accepted for two-sided layouts.
///   - `page.binding` (`none`, `left`, `right`; `none`): binding edge; a value
///     enables two-sided page layout.
///   - `page.binding-correction` (length; `0pt`): extra binding-side margin.
///   - `page.headers` (bool; `false`): automatic shared-header switch. Journal
///     entries supply their own header, and the index has no running header,
///     so this field does not affect either function.
///   - `page.columns` (positive integer; `1`): text columns.
///   - `page.column-gutter` (length; `5mm`): gap between columns.
///   - `typography.font` (font name; `"Libertinus Serif"`): body typeface.
///   - `typography.math-font`, `typography.mono-font` (font name or `auto`;
///     `auto`): math and monospace typefaces. `auto` uses Typst's selection.
///   - `typography.size` (length; `11pt`): body text size.
///   - `typography.line-spacing` (positive number or `none`; `none`): optional
///     baseline distance as a multiple of body size; when set, overrides
///     `leading`.
///   - `typography.leading` (length; `0.65em`): gap between line boxes.
///   - `typography.list-spacing` (non-negative number; `0.5`): additional gap
///     between list items as a fraction of the calculated body baseline
///     distance. It follows `typography.line-spacing` when set, or font
///     metrics and `leading` otherwise. Use `0` for no extra gap.
///   - `typography.paragraph-spacing` (length; `1.2em`): paragraph gap.
///   - `typography.first-line-indent` (bool; `false`): indent every paragraph
///     first line by one em when true.
///   - `typography.hyphenate` (bool; `false`): automatic body hyphenation.
///   - `typography.justify` (bool; `true`): justify paragraphs.
///   - `headings.numbering` (numbering pattern/function or `none`; `"1.1"` in
///     shared defaults, disabled by the journal kind): heading numbering.
///   - `headings.hyphenate` (bool; `false`): allow heading hyphenation.
///   - `headings.h1-pagebreak` (bool; `false`): start level-one headings on a
///     fresh page where supported.
///   - `headings.spacing` (`"koma"` or `"native"`; `"koma"`): gap policy.
///   - `headings.h1-size` through `headings.h4-size` (lengths; `16pt`, `12pt`,
///     `11pt`, `11pt`): heading sizes.
///   - `headings.h1-above` through `headings.h4-above` (`auto` or length;
///     `auto`): space before headings.
///   - `headings.h1-below` through `headings.h4-below` (`auto` or length;
///     `0.65em` for h1-h3, `0.4em` for h4): space after headings.
///   - `journal.header-below` (length; `1.5em`): gap from entry metadata to
///     notes.
///   - `journal.running-gutter` (length; `1em`): running-header column gap.
///   - `journal.running-leading` (length; `0.35em`): running-header line gap.
///   - `journal.running-header-size` (length; `9pt`): entry header text size.
///   - `journal.date-size` (length; `10pt`): entry date text size.
///   - `journal.keywords-size` (length; `9pt`): entry keyword text size.
///   - `decorative.header-size` (length; `9pt`), `date-size` (10pt),
///     `keywords-size` (9pt): accepted shared text settings but ignored by the
///     journal. Use `typography.list-spacing` for journal lists.
///   - `decorative.footer-size` (length; `10pt`): shared footer size; journal
///     templates use `page-footer` directly, so this value has no effect here.
///   - `page-footer.format` (numbering pattern/function in shared config;
///     `"1"`): this journal footer checks only for the exact string `"-1-"`,
///     which wraps the Arabic page number in hyphens. Any other value displays
///     the plain Arabic page number.
///   - `page-footer.size` (length; `10pt`): page-number size.
///   - `page-footer.weight` (font weight; `"regular"`): page-number weight.
///   - `line-numbers.enabled` (bool; `false`), `format` (pattern; `"1"`),
///     `scope` (`"document"` or `"page"`; `"document"`), `size` (length;
///     `8pt`), `color` (color; `#64748B`), and `clearance` (`auto` or length;
///     `auto`): line-number format, reset scope, text style, and gap. Setting
///     `enabled: true` displays line numbers in entry bodies; the index does
///     not display them.
///   - `links.color`, `links.url-color` (colors; `#0563C1`): internal and URL
///     link colors. Entry internal references stay black; `url-color` styles
///     its external URLs. Neither field styles index links.
///   - `tables.stroke` (length; `0.5pt`), `inset` (length or x/y dictionary;
///     `(x: 8pt, y: 4pt)`), `font-size` (length; `10pt`),
///     `caption-position` (`top` or `bottom`; `top`), and `caption-gap`
///     (length; `6pt`): shared table styling.
///   - `callouts.inset` (length; `9pt`), `radius` (length; `3pt`), `stroke`
///     (length; `0.8pt`), `title-below` (length; `1em`),
///     `paragraph-spacing` (length; `1em`), and `list-spacing` (length; `1.2em`):
///     shared callout styling. Pass the same config to a `callout`
///     component separately for these values to style that component.
///   - `captions.size` (length; `10pt`), `weight` and `label-weight` (font
///     weights; `"regular"`), `alignment` (left), and `hanging` (true): shared
///     caption styling. See the configuration reference for customization.
///   - `toc.depth` (`none` or non-negative integer; `none`), `title` (content
///     or `none`; `[Table of Contents]`), `indent` (`auto` or length; `auto`),
///     `entry-size` (length; `10pt`), `leading` (length; `0.65em`),
///     `entry-above` (length; `0.65em`), `main-entry-above` (length; `1.25em`),
///     `title-below` (length; `1.5em`), and `below` (length; `2em`): contents
///     settings. The journal does not create a contents page.
///   - `lof` and `lot` accept the corresponding `toc` fields except
///     `main-entry-above`, and add `compact` (bool; `false`). Their defaults
///     are depth `none`, titles `[List of Figures]` / `[List of Tables]`,
///     entry size `10pt`, leading `0.65em`, entry gap `0.85em`, title gap
///     `1.5em`, below gap `2em`, and `indent: auto`. The journal creates
///     neither list.
///   - `bibliography.style` (CSL style name; `"apa"`): shared citation style.
///   - `colors.bg-paper`, `bg-subtle`, `brand-primary`, `brand-accent`,
///     `text-main`, and `text-muted` (colors; neutral theme uses white paper,
///     white subtle fill, black accents/text): page, accent, and text colors.
///   Additional accepted fields are `page.header-ascent` (length),
///   `headings.h1-number-size` (length), `decorative.list-indent`,
///   `decorative.list-body-indent`, and `decorative.list-block-spacing`
///   (lengths). These extensions have no shared default and do not affect the
///   journal layout. For `journal-entry`, the shared class consumes page,
///   typography, headings, list spacing, line numbers, URL colors, tables,
///   captions, and bibliography settings; this template consumes the journal,
///   date/keyword, running-header, and footer settings. `callouts.*` is used
///   only when the same config is also passed to a callout component. The
///   journal kind suppresses internal-link coloring and automatic contents,
///   figure-list, and table-list pages. For `journal-index`, only
///   `page.paper`, `page.margin`, `typography.font`, `typography.size`,
///   `colors.bg-paper`, `colors.text-main`, and `colors.brand-primary` affect
///   its layout; all other recognized fields are validated and ignored.
///   Other top-level groups are retained as caller extensions but are not read
///   by either function. Values in recognized groups are checked for known
///   keys; Typst checks individual value types when a value is used.
/// - theme (str, none): `neutral` (default), `slate`, `soft-jade`, `soft-slate`, `warm-editorial`,
///   `plum`, or `soft-rose`; explicit config overrides win
#let journal-entry(
  title: "",
  date: "",
  keywords: "",
  body,
  config: (:),
  theme: "neutral",
) = {
  let validated-date = journal-date-parts(date)
  let config = merge(journal-defaults, theme-config(theme, config: config))
  let c = merge(defaults, config)

  context {
    let current-page = counter(page).get().first()
    journal-state.update((
      title: title,
      date: date,
      page: current-page,
    ))
  }

  show: checklist.with(extras: true)

  document-class(
    kind: "journal",
    config: config,
    header: context {
      let entry = journal-state.get()
      if entry != none and counter(page).get().first() != entry.page [
        #set text(size: c.decorative.header-size, fill: c.colors.text-muted)
        #set par(justify: false, first-line-indent: 0pt, leading: c.journal.running-leading)
        #grid(
          columns: (1fr, auto), column-gutter: c.journal.running-gutter,
          align: top,
          align(left + top)[#text(weight: "medium")[#entry.title]],
          align(right + top)[#box[#entry.date]]
        )
      ]
    },
    footer: context {
      let n = counter(page).get().first()
      align(center)[#text(size: c.page-footer.size, weight: c.page-footer.weight, fill: c.colors.brand-primary)[
        #if c.page-footer.format == "-1-" {[-#n-]} else {[#n]}
      ]]
    },
    [
      #block(breakable: false, sticky: true, below: 0pt)[
        #journal-metadata-entry(title, date, keywords)
        #heading(level: 1)[#title]
        #journal-date-keywords(date, keywords, config: c)
      ]
      // A non-collapsing boundary owns this gap once. Keep the notes in the
      // page flow so explicit page breaks and later heading spacing still work.
      #v(c.journal.header-below, weak: false)
      #body
    ],
  )
}

/// English month names keyed by zero-padded month number.
///
/// `journal-index` converts each parsed month number to a two-digit key before
/// looking up its label, so `"01"` maps to `"January"` and `"12"` to
/// `"December"`. Undated entries are grouped separately and do not use this
/// table.
#let month-names = (
  "01": "January", "02": "February", "03": "March", "04": "April",
  "05": "May", "06": "June", "07": "July", "08": "August",
  "09": "September", "10": "October", "11": "November", "12": "December"
)

/// The index of all entries, grouped by month.
///
/// Every `journal-entry` contributes a `<journal-item>`; the index lists date,
/// title, and page with a dotted line and clickable link. Put the index before
/// your entries. Typst resolves them at compile time. The fixed heading is
/// English "Index"; undated entries appear under "Undated"; month headings gain
/// a year only when the journal spans multiple years.
///
/// - config (dictionary): nested overrides. Dictionaries merge recursively;
///   explicit `config` values win over the journal defaults and `theme`.
///   Unspecified values keep the effective defaults below. Lengths are Typst
///   lengths, colors are Typst colors, and content fields accept Typst content.
///   - `page.paper` (paper name or custom size; `"iso-b5"`): paper format.
///   - `page.margin` (dictionary; left/right `2cm`, top/bottom `2.5cm`): page
///     edges. Edge values are lengths; `x` and `y` set horizontal/vertical
///     pairs. `inside` and `outside` are accepted for two-sided layouts.
///   - `page.binding` (`none`, `left`, `right`; `none`): binding edge; a value
///     enables two-sided page layout.
///   - `page.binding-correction` (length; `0pt`): extra binding-side margin.
///   - `page.headers` (bool; `false`): automatic shared-header switch. Journal
///     entries supply their own header, and the index has no running header,
///     so this field does not affect either function.
///   - `page.columns` (positive integer; `1`): text columns.
///   - `page.column-gutter` (length; `5mm`): gap between columns.
///   - `typography.font` (font name; `"Libertinus Serif"`): body typeface.
///   - `typography.math-font`, `typography.mono-font` (font name or `auto`;
///     `auto`): math and monospace typefaces. `auto` uses Typst's selection.
///   - `typography.size` (length; `11pt`): body text size.
///   - `typography.line-spacing` (positive number or `none`; `none`): optional
///     baseline distance as a multiple of body size; when set, overrides
///     `leading`.
///   - `typography.leading` (length; `0.65em`): gap between line boxes.
///   - `typography.list-spacing` (non-negative number; `0.5`): additional gap
///     between list items as a fraction of the calculated body baseline
///     distance. It follows `typography.line-spacing` when set, or font
///     metrics and `leading` otherwise. Use `0` for no extra gap.
///   - `typography.paragraph-spacing` (length; `1.2em`): paragraph gap.
///   - `typography.first-line-indent` (bool; `false`): indent every paragraph
///     first line by one em when true.
///   - `typography.hyphenate` (bool; `false`): automatic body hyphenation.
///   - `typography.justify` (bool; `true`): justify paragraphs.
///   - `headings.numbering` (numbering pattern/function or `none`; `"1.1"` in
///     shared defaults, disabled by the journal kind): heading numbering.
///   - `headings.hyphenate` (bool; `false`): allow heading hyphenation.
///   - `headings.h1-pagebreak` (bool; `false`): start level-one headings on a
///     fresh page where supported.
///   - `headings.spacing` (`"koma"` or `"native"`; `"koma"`): gap policy.
///   - `headings.h1-size` through `headings.h4-size` (lengths; `16pt`, `12pt`,
///     `11pt`, `11pt`): heading sizes.
///   - `headings.h1-above` through `headings.h4-above` (`auto` or length;
///     `auto`): space before headings.
///   - `headings.h1-below` through `headings.h4-below` (`auto` or length;
///     `0.65em` for h1-h3, `0.4em` for h4): space after headings.
///   - `journal.header-below` (length; `1.5em`): gap from entry metadata to
///     notes.
///   - `journal.running-gutter` (length; `1em`): running-header column gap.
///   - `journal.running-leading` (length; `0.35em`): running-header line gap.
///   - `journal.running-header-size` (length; `9pt`): entry header text size.
///   - `journal.date-size` (length; `10pt`): entry date text size.
///   - `journal.keywords-size` (length; `9pt`): entry keyword text size.
///   - `decorative.header-size` (length; `9pt`), `date-size` (10pt),
///     `keywords-size` (9pt): accepted shared text settings but ignored by the
///     journal. Use `typography.list-spacing` for journal lists.
///   - `decorative.footer-size` (length; `10pt`): shared footer size; journal
///     templates use `page-footer` directly, so this value has no effect here.
///   - `page-footer.format` (numbering pattern/function in shared config;
///     `"1"`): this journal footer checks only for the exact string `"-1-"`,
///     which wraps the Arabic page number in hyphens. Any other value displays
///     the plain Arabic page number.
///   - `page-footer.size` (length; `10pt`): page-number size.
///   - `page-footer.weight` (font weight; `"regular"`): page-number weight.
///   - `line-numbers.enabled` (bool; `false`), `format` (pattern; `"1"`),
///     `scope` (`"document"` or `"page"`; `"document"`), `size` (length;
///     `8pt`), `color` (color; `#64748B`), and `clearance` (`auto` or length;
///     `auto`): line-number format, reset scope, text style, and gap. Setting
///     `enabled: true` displays line numbers in entry bodies; the index does
///     not display them.
///   - `links.color`, `links.url-color` (colors; `#0563C1`): internal and URL
///     link colors. Entry internal references stay black; `url-color` styles
///     its external URLs. Neither field styles index links.
///   - `tables.stroke` (length; `0.5pt`), `inset` (length or x/y dictionary;
///     `(x: 8pt, y: 4pt)`), `font-size` (length; `10pt`),
///     `caption-position` (`top` or `bottom`; `top`), and `caption-gap`
///     (length; `6pt`): shared table styling.
///   - `callouts.inset` (length; `9pt`), `radius` (length; `3pt`), `stroke`
///     (length; `0.8pt`), `title-below` (length; `1em`),
///     `paragraph-spacing` (length; `1em`), and `list-spacing` (length; `1.2em`):
///     shared callout styling. Pass the same config to a `callout`
///     component separately for these values to style that component.
///   - `captions.size` (length; `10pt`), `weight` and `label-weight` (font
///     weights; `"regular"`), `alignment` (left), and `hanging` (true): shared
///     caption styling. See the configuration reference for customization.
///   - `toc.depth` (`none` or non-negative integer; `none`), `title` (content
///     or `none`; `[Table of Contents]`), `indent` (`auto` or length; `auto`),
///     `entry-size` (length; `10pt`), `leading` (length; `0.65em`),
///     `entry-above` (length; `0.65em`), `main-entry-above` (length; `1.25em`),
///     `title-below` (length; `1.5em`), and `below` (length; `2em`): contents
///     settings. The journal does not create a contents page.
///   - `lof` and `lot` accept the corresponding `toc` fields except
///     `main-entry-above`, and add `compact` (bool; `false`). Their defaults
///     are depth `none`, titles `[List of Figures]` / `[List of Tables]`,
///     entry size `10pt`, leading `0.65em`, entry gap `0.85em`, title gap
///     `1.5em`, below gap `2em`, and `indent: auto`. The journal creates
///     neither list.
///   - `bibliography.style` (CSL style name; `"apa"`): shared citation style.
///   - `colors.bg-paper`, `bg-subtle`, `brand-primary`, `brand-accent`,
///     `text-main`, and `text-muted` (colors; neutral theme uses white paper,
///     white subtle fill, black accents/text): page, accent, and text colors.
///   Additional accepted fields are `page.header-ascent` (length),
///   `headings.h1-number-size` (length), `decorative.list-indent`,
///   `decorative.list-body-indent`, and `decorative.list-block-spacing`
///   (lengths). These extensions have no shared default and do not affect the
///   journal layout. For `journal-entry`, the shared class consumes page,
///   typography, headings, list spacing, line numbers, URL colors, tables,
///   captions, and bibliography settings; this template consumes the journal,
///   date/keyword, running-header, and footer settings. `callouts.*` is used
///   only when the same config is also passed to a callout component. The
///   journal kind suppresses internal-link coloring and automatic contents,
///   figure-list, and table-list pages. For `journal-index`, only
///   `page.paper`, `page.margin`, `typography.font`, `typography.size`,
///   `colors.bg-paper`, `colors.text-main`, and `colors.brand-primary` affect
///   its layout; all other recognized fields are validated and ignored.
///   Other top-level groups are retained as caller extensions but are not read
///   by either function. Values in recognized groups are checked for known
///   keys; Typst checks individual value types when a value is used.
/// - theme (str, none): `neutral` (default), `slate`, `soft-jade`, `soft-slate`, `warm-editorial`,
///   `plum`, or `soft-rose`; explicit config overrides win
#let journal-index(config: (:), theme: "neutral") = context {
  let config = merge(journal-defaults, theme-config(theme, config: config))
  let config = validate-config(config)
  let c = merge(defaults, config)

  set page(
    paper: c.page.paper,
    margin: c.page.margin,
    numbering: none,
    fill: c.colors.bg-paper
  )
  set text(font: c.typography.font, size: c.typography.size, fill: c.colors.text-main)

  heading(level: 1, numbering: none)[#text(fill: c.colors.brand-primary, weight: "bold")[Index]]
  v(1.5em)

  let entries = query(<journal-item>).sorted(key: entry => {
    let parsed = journal-date-parts(entry.value.date)
    if parsed == none { 99999999 } else { parsed.year * 10000 + parsed.month * 100 + parsed.day }
  })

  // Detect whether entries span multiple years.
  // If yes, append the year to month group headings.
  let years = ()
  for entry in entries {
    let data = entry.value
    let parsed = journal-date-parts(data.date)
    if parsed != none {
      let y = str(parsed.year)
      if not years.contains(y) { years.push(y) }
    }
  }
  let multi-year = years.len() > 1

  let current-month = ""
  let current-year = ""

  for entry in entries {
    let data = entry.value
    let page-num = entry.location().page()
    let parsed = journal-date-parts(data.date)
    let year = if parsed == none { "" } else { str(parsed.year) }
    let month-code = if parsed == none { "" } else if parsed.month < 10 { "0" + str(parsed.month) } else { str(parsed.month) }
    let month-name = if parsed == none { "Undated" } else { month-names.at(month-code) }
    let clean-date = if parsed == none { "" } else {
      let date-parts = data.date.split(", ")
      let without-comma-prefix = if date-parts.len() == 2 { date-parts.last() } else { data.date }
      let word-parts = without-comma-prefix.split(" ")
      if word-parts.len() == 2 { word-parts.last() } else { without-comma-prefix }
    }

    if month-name != current-month or year != current-year {
      current-month = month-name
      current-year = year
      let heading-text = if multi-year {
        [#month-name #year]
      } else {
        [#month-name]
      }
      text(fill: c.colors.brand-primary, weight: "bold", size: 13pt)[#heading-text]
      v(0.3em)
    }

    let entry-text = [
      #text(fill: c.colors.text-main, weight: "bold")[#clean-date] #text(fill: c.colors.text-main, weight: "regular")[#h(0.5em) #data.title]
    ]

    link(entry.location())[
      #grid(
        columns: (1fr, auto),
        gutter: 1em,
        [#entry-text #box(width: 1fr, repeat([.]))],
        [#text(weight: "bold", fill: c.colors.brand-primary)[#page-num]]
      )
    ]
    v(0.5em)
  }
}
