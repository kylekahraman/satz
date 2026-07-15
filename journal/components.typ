#import "../defaults.typ": defaults, merge

#let journal-metadata-entry(title, date, keywords) = {
  [#metadata((title: title, date: date, keywords: keywords)) <journal-item>]
}

#let journal-date-keywords(date, keywords, config: (:)) = {
  let c = merge(defaults, config)
  grid(
    columns: (1fr, 1fr),
    align(left)[#text(size: c.decorative.date-size, style: "italic", fill: c.colors.text-muted)[#date]],
    align(right)[#text(size: c.decorative.keywords-size, fill: c.colors.text-muted, weight: "medium")[#keywords]]
  )
}
