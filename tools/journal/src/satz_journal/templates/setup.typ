#import "_satz/lib.typ": journal-entry as base-entry, journal-index as base-index, merge, defaults
#import "config.typ": journal-style

#let config = merge(defaults, (page: (paper: journal-style.paper,)))
#let journal-entry(title: "", date: "", keywords: "", body) = {
  base-entry(title: title, date: date, keywords: keywords, body, config: config, theme: journal-style.theme)
}
#let journal-index() = base-index(config: config, theme: journal-style.theme)
