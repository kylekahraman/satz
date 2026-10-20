// Optional CSL processor. Imported only when the opt-in authoring API is used.

/// Initialize citations from BibTeX text (pass read("references.bib")).
/// Selected keys are rendered in bold in proposal-publications().
/// Ordinary @key citations remain available; the .bib file is never rewritten.
/// Supply CSL XML text with style: read("custom.csl") to replace the bundled
/// author-date style. This is an opt-in alternative to native bibliography().
#let proposal-citations(bib, highlight: (), style: none, body) = {
  import "@preview/citrus:0.2.1": init-csl
  import "@preview/citegeist:0.2.1": load-bibliography
  assert(type(bib) == str, message: "Pass BibTeX text using read(\"references.bib\").")
  assert(type(highlight) == array and highlight.all(k => type(k) == str),
    message: "highlight must be an array of BibTeX key strings.")
  assert(highlight.dedup().len() == highlight.len(), message: "Duplicate highlighted publication key.")
  let entries = load-bibliography(bib)
  for key in highlight {
    assert(key in entries, message: "Unknown highlighted publication key: " + key)
  }
  let csl = if style == none { read("styles/author-date.csl") } else { style }
  [#metadata(highlight) <satz-publication-highlights>]
  init-csl(bib, csl, body)
}

/// Print the opt-in CSL bibliography, automatically bolding selected entries.
/// Preserves processor-generated bibliography labels and citation hyperlinks.
/// max-highlight limits the number of highlighted entries actually printed.
/// Use citrus.nocite to include uncited entries when using the CSL backend.
#let proposal-publications(size: 11pt, max-highlight: none) = context {
  import "@preview/citrus:0.2.1": csl-bibliography
  let selections = query(<satz-publication-highlights>)
  assert(selections.len() == 1, message: "Use one proposal-citations show rule before printing publications.")
  let selected = selections.first().value
  set text(size: size)
  csl-bibliography(title: none, full-control: entries => {
    let count = entries.filter(e => e.key in selected).len()
    if max-highlight != none {
      assert(count <= max-highlight, message: "At most " + str(max-highlight) + " highlighted publications may be printed.")
    }
    set par(first-line-indent: 0pt, hanging-indent: 1.5em, spacing: 0.65em)
    for entry in entries {
      // Individual CSL nodes can set weight: normal, so apply a local show rule
      // to all text in a selected entry, including italic journal names.
      let doi = entry.fields.at("doi", default: "")
      let url = entry.fields.at("url", default: "")
      let destination = if doi != "" {
        if doi.starts-with("https://") or doi.starts-with("http://") { doi } else { "https://doi.org/" + doi }
      } else if url != "" { url } else { none }
      let rendered = if destination == none { entry.rendered } else { link(destination, entry.rendered) }
      if entry.key in selected {
        show text: set text(weight: "bold")
        [#rendered #entry.ref-label]
      } else {
        [#rendered #entry.ref-label]
      }
      parbreak()
    }
  })
}
