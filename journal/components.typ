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

/// A blue box for things you want to keep in mind.
///
/// The label and colors are fixed for now, so the box is not theme-aware.
///
/// ```example
/// #remember[ICA needs raw, non-interpolated data.]
/// ```
///
/// - body (content): the note to retain
#let remember(body) = block(
  fill: rgb("e1f5fe"),
  stroke: 0.5pt + rgb("0288d1"),
  inset: 8pt,
  width: 100%,
  radius: 4pt,
)[
  *📌 TO REMEMBER:* #body
]

/// An orange box for open questions.
///
/// The label and colors are fixed for now, so the box is not theme-aware. Use it
/// to keep unresolved questions visible during review.
///
/// ```example
/// #question[Why did the EOG check flag component 3?]
/// ```
///
/// - body (content): the unresolved question
#let question(body) = block(
  fill: rgb("fff3e0"),
  stroke: 0.5pt + rgb("f57c00"),
  inset: 8pt,
  width: 100%,
  radius: 4pt,
)[
  *❓ UNRESOLVED:* #body
]
