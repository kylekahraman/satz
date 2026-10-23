#import "@preview/cheq:0.4.0": checklist
#import "../class.typ": document-class
#import "../defaults.typ": defaults, merge, validate-config
#import "../themes.typ": theme-config
#import "components.typ": journal-metadata-entry, journal-date-keywords, remember, question
#import "dates.typ": journal-date-parts

/// Has an entry started? We check this for page breaks.
#let journal-entry-state = state("entry-start", true)

/// What the header shows on page 2+.
///
/// Each `journal-entry` drops its title, date, and start page in here.
#let journal-state = state("journal-entry-state", (
  title: "",
  date: "",
  page: 0,
))

/// One journal entry — title, date, keywords, and your notes.
///
/// You get a heading, badges for date + keywords, and a header
/// that keeps showing title + date on later pages.
/// Checklists work: `- [ ] todo` and `- [x] done`.
///
/// - title (str): what this entry is about
/// - date (str): `YYYY-MM-DD` or `DD/MM/YY` / `DD/MM/YYYY`, optionally preceded by a weekday; empty is allowed for drafts
/// - keywords (str): comma-separated, e.g. "MEG, ICA"
/// - body (content): your notes
/// - config (dictionary): tweak colors, fonts ...
/// - theme (str, none): optional shared palette; explicit config overrides win.
#let journal-entry(
  title: "",
  date: "",
  keywords: "",
  body,
  config: (:),
  theme: none,
) = {
  let validated-date = journal-date-parts(date)
  let config = theme-config(theme, config: config)
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

/// Month names for the index.
///
/// "01" -> "January", "02" -> "February" ... you get it.
#let month-names = (
  "01": "January", "02": "February", "03": "March", "04": "April",
  "05": "May", "06": "June", "07": "July", "08": "August",
  "09": "September", "10": "October", "11": "November", "12": "December"
)

/// The index — all entries, grouped by month.
///
/// We query every `<journal-item>` and list date, title, and
/// page with a dotted line and a clickable link.
/// Put this before your entries — Typst finds them anyway at compile time.
///
/// - config (dictionary): tweak defaults
#let journal-index(config: (:), theme: none) = context {
  let config = theme-config(theme, config: config)
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
