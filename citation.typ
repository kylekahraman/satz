/// Cite without parentheses — `author year` instead of `(Author, Year)`.
///
/// Normal `@key` / `#cite(<key>)` renders as "(Author, Year)" with parentheses
/// and year-only red coloring. `citepre` renders the same citation as
/// "Author Year" (no parens), optionally preceded by `pre` content
/// (e.g. `pre: [see ]` → "see Author Year").
///
/// - key (label): Bibliography key (e.g. `<smith2020>`)
/// - pre (none, content): Optional prefix content placed before the citation
#let citepre(key, pre: none) = {
  let c = [#cite(key, form: "author"), #cite(key, form: "year")]
  if pre != none {
    [#pre #c]
  } else {
    c
  }
}
