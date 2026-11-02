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

/// One journal entry — title, date, keywords, and your notes.
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
/// - config (dictionary): shared Satz overrides plus `journal.*` spacing keys.
///   For example, use `typography: (font: "Libertinus Serif", size: 11pt)` or
///   `page: (paper: "a4", columns: 1)`. Shared typography defaults to
///   Libertinus Serif at 11pt; journal defaults use ISO B5, one column, and
///   set entry spacing in `journal/defaults.typ`. All shared keys and values
///   are in `defaults.typ`.
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

/// The index — all entries, grouped by month.
///
/// Every `journal-entry` contributes a `<journal-item>`; the index lists date,
/// title, and page with a dotted line and clickable link. Put the index before
/// your entries—Typst resolves them at compile time. The fixed heading is
/// English "Index"; undated entries appear under "Undated"; month headings gain
/// a year only when the journal spans multiple years.
///
/// - config (dictionary): same shared settings and journal defaults as
///   `journal-entry`; use `toc`, `colors`, or `typography` overrides here too.
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
