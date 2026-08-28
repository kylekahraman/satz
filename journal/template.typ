#import "@preview/cheq:0.4.0": checklist
#import "../class.typ": personal
#import "../defaults.typ": defaults, merge
#import "components.typ": journal-metadata-entry, journal-date-keywords, remember, question

/// Tracks whether a journal entry has started (used for page breaks).
#let journal-entry-state = state("entry-start", true)

/// Holds the current journal entry metadata for running headers.
///
/// Updated by each `journal-entry` call with title, date, and starting page.
/// Used by the page header to show the current entry's info on subsequent pages.
#let journal-state = state("journal-entry-state", (
  title: "",
  date: "",
  page: 0,
))

/// A single journal entry with title, date, keywords, and running headers.
///
/// Creates a self-contained diary/logbook page. The entry title appears
/// as a level-1 heading, followed by date and keyword badges.
/// Subsequent pages of the same entry show the title and date in the header.
/// Checklist syntax (`- [ ]` and `- [x]`) is enabled via the `cheq` package.
///
/// - title (str): Entry title
/// - date (str): Date string (e.g. "Mon 03/03/2026")
/// - keywords (str): Comma-separated keywords
/// - body (content): Entry body content
/// - config (dictionary): Overrides for satz defaults (colors, typography, etc.)
#let journal-entry(
  title: "",
  date: "",
  keywords: "",
  body,
  config: (:)
) = {
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

  personal(
    kind: "journal",
    config: config,
    header: context {
      let entry = journal-state.get()
      if entry != none and counter(page).get().first() != entry.page [
        #set text(size: c.decorative.header-size, fill: c.colors.text-muted)
        #grid(
          columns: (1fr, auto),
          align(left)[#text(weight: "medium")[#entry.title]],
          align(right)[#entry.date]
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
      #journal-metadata-entry(title, date, keywords)
      #heading(level: 1)[#title]
      #journal-date-keywords(date, keywords, config: c)
      #v(0.5em)
      #body
    ],
  )
}

/// Month name lookup for the journal index.
///
/// Maps two-digit month codes ("01"–"12") to English month names.
#let month-names = (
  "01": "January", "02": "February", "03": "March", "04": "April",
  "05": "May", "06": "June", "07": "July", "08": "August",
  "09": "September", "10": "October", "11": "November", "12": "December"
)

/// Auto-generated monthly index of all journal entries.
///
/// Queries all `<journal-item>` labels in the document and builds a table of
/// contents grouped by month. Each entry shows the date, title, and page
/// number with clickable links. Uses dot leaders between title and page number.
///
/// Place this at the beginning of your document (before any `journal-entry` calls)
/// so the index appears first. The query runs at compile time and finds all
/// entries regardless of position.
///
/// - config (dictionary): Overrides for satz defaults
#let journal-index(config: (:)) = context {
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

  let entries = query(<journal-item>)

  // Detect whether entries span multiple years.
  // If yes, append the year to month group headings.
  let years = ()
  for entry in entries {
    let data = entry.value
    let date-parts = data.date.split(", ")
    let clean-date = if date-parts.len() > 1 { date-parts.at(1) } else { data.date }
    let clean-date-parts = clean-date.split("/")
    if clean-date-parts.len() > 2 {
      let y = clean-date-parts.at(2)
      if not years.contains(y) {
        years.push(y)
      }
    }
  }
  let multi-year = years.len() > 1

  let current-month = ""
  let current-year = ""

  for entry in entries {
    let data = entry.value
    let page-num = entry.location().page()

    let date-parts = data.date.split(", ")
    let clean-date = if date-parts.len() > 1 { date-parts.at(1) } else { data.date }

    let clean-date-parts = clean-date.split("/")
    let year = if clean-date-parts.len() > 2 {
      let y = clean-date-parts.at(2)
      if y.len() == 2 { "20" + y } else { y }
    } else {
      ""
    }
    let month-code = if clean-date-parts.len() > 1 { clean-date-parts.at(1) } else { "" }
    let month-name = month-names.at(month-code, default: "Unknown Month")

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
