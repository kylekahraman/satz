#import "_satz/lib.typ": journal-entry as base-entry, journal-index as base-index, merge
#import "config.typ": journal-style, journal-overrides

#let config = merge((page: (paper: journal-style.paper,)), journal-overrides)
#let journal-entry(title: "", date: "", keywords: "", body) = {
  base-entry(title: title, date: date, keywords: keywords, body, config: config, theme: journal-style.theme)
}
#let journal-index() = base-index(config: config, theme: journal-style.theme)
