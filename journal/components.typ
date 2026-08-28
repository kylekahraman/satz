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

/// Inline callout box for things to remember — library quirks, gotchas, insights.
///
/// Renders as a light-blue bordered box inline in the entry body.
/// Usage: #remember[Picard ICA requires non-interpolated raw data.]
#let remember(body) = block(
  fill: rgb("e1f5fe"),
  stroke: 0.5pt + rgb("0288d1"),
  inset: 8pt,
  width: 100%,
  radius: 4pt,
)[
  *📌 TO REMEMBER:* #body
]

/// Inline callout box for unresolved questions.
///
/// Renders as a light-orange bordered box inline in the entry body.
/// Questions stay visible during review — answer them later.
/// Usage: #question[Why did find_bads_eog flag component 3?]
#let question(body) = block(
  fill: rgb("fff3e0"),
  stroke: 0.5pt + rgb("f57c00"),
  inset: 8pt,
  width: 100%,
  radius: 4pt,
)[
  *❓ UNRESOLVED:* #body
]
