#import "../class.typ": document-class
#import "../defaults.typ": defaults, merge
#import "../themes.typ": theme-config
#import "defaults.typ": defaults as article-defaults

/// An article with a full-width title/author/abstract block and native columns.
///
/// Defaults to two columns, ordinary page numbering, and no automatic front
/// matter. Set `config: (page: (columns: 1))` for a one-column assignment or
/// article. Figures can span both columns with `scope: "parent", placement: top`.
///
/// ```example
/// #show: article.with(
///   title: [A short article],
///   authors: ((name: "Alex Example", affiliations: (1,)),),
///   affiliations: ("Example Institute",),
///   abstract: [We test a small example.],
/// )
/// = Introduction
/// #lorem(80)
/// ```
///
/// - title (str, content, none): article title
/// - authors (dictionary or array): one author record may be passed directly,
///   e.g. `authors: (name: "Alex Example")`; multiple authors use an array of
///   records, e.g. `authors: ((name: "Alex Example"), (name: "Sam Example"))`.
///   Each record has a `name` and optional `affiliations`.
/// - affiliations (array of str, content): displayed in order. Author records
///   reference them with one-based indices, e.g. `affiliations: (1, 2)`.
/// - abstract (content, none): full-width abstract
/// - date (str, content, none): optional date beneath the authors
/// - config (dictionary): nested overrides for shared Satz settings and
///   article-specific settings. Shared sections are `page`, `typography`,
///   `headings`, `journal`, `decorative`, `page-footer`, `line-numbers`, `links`, `tables`,
///   `callouts`, `captions`, `toc`, `lof`, `lot`, `bibliography`, and `colors`.
///   For example, set
///   `typography: (font: "STIX Two Text", math-font: "STIX Two Math")` to
///   choose separate text and math fonts. If you omit `math-font`, Typst uses
///   New Computer Modern Math by default; it is embedded in the Typst CLI.
///   Set `line-numbers: (enabled: true)` for a draft; line numbering is off by
///   default. Its `format`, `scope`, `size`, `color`, and `clearance` are also
///   configurable.
///   Shared defaults are in `defaults.typ`;
///   article defaults are two columns, 10pt text, unnumbered headings, and no
///   automatic contents. Article-specific keys are `article.title-size`
///   (18pt), `author-size` (11pt), `author-gap` (0.8em),
///   `affiliation-size` (8.5pt), `abstract-size` (9pt), `title-gap` (1.2em),
///   and `body-gap` (2.2em). Override them under `article:`, for example
///   `article: (title-size: 16pt)`. Set `toc.depth` above 0 (or to `none`) to
///   insert inline contents after the front matter.
/// - theme (str, none): `neutral` (default), `slate`, `soft-jade`, `soft-slate`,
///   `warm-editorial`, `plum`, or `soft-rose`; explicit `config.colors` wins
/// - body (content): the article
#let article(title: none, authors: (), affiliations: (), abstract: none, date: none, config: (:), theme: "neutral", body) = {
  let authors = if type(authors) == dictionary { (authors,) } else { authors }
  assert(type(authors) == array, message: "article authors must be a record or an array of records.")
  assert(type(affiliations) == array, message: "article affiliations must be an array of strings or content.")
  for (index, affiliation) in affiliations.enumerate() {
    assert(type(affiliation) == str or type(affiliation) == content,
      message: "Article affiliation " + str(index + 1) + " must be a string or content.")
  }
  for (author-index, author) in authors.enumerate() {
    assert(type(author) == dictionary,
      message: "Article author " + str(author-index + 1) + " must be a dictionary with a name field.")
    assert("name" in author and (type(author.name) == str or type(author.name) == content),
      message: "Article author " + str(author-index + 1) + " must have a string or content `name`.")
    let author-affiliations = author.at("affiliations", default: ())
    assert(type(author-affiliations) == array,
      message: "Article author affiliations must be an array of one-based affiliation indices.")
    for index in author-affiliations {
      assert(type(index) == int and index >= 1 and index <= affiliations.len(),
        message: "Author affiliation indices must refer to an entry in affiliations.")
    }
  }
  let config = theme-config(theme, config: config)
  let c = merge(merge(defaults, article-defaults), config)
  let front = [
    #set par(justify: false, first-line-indent: 0pt, spacing: 0.5em)
    #align(center)[
      #set text(hyphenate: false)
      #if title != none { block(below: c.article.title-gap, text(size: c.article.title-size, weight: "bold", title)) }
      #if authors.len() > 0 {
        block(below: c.article.at("author-gap", default: 0.8em), text(size: c.article.author-size,
          authors.map(author => [
            #author.name#if author.at("affiliations", default: ()) != () {
              super(author.affiliations.map(str).join(","))
            }
          ]).join(h(1em))))
      }
      #for (index, affiliation) in affiliations.enumerate() {
        block(above: 0.35em, text(size: c.article.affiliation-size)[#super(str(index + 1)) #affiliation])
      }
      #if date != none { block(above: 0.6em, date) }
    ]
    #if abstract != none {
      block(above: c.article.title-gap, inset: (x: 5%))[
        #set text(size: c.article.abstract-size)
        #set par(justify: true)
        #block(below: 0.5em, text(size: 1.15em, weight: "bold")[Abstract])

        #abstract
      ]
    }
  ]
  document-class(
    kind: "article",
    // Article outlines are inline, rather than report front matter/counter reset.
    config: merge(c, (toc: (depth: 0))),
    footer: context align(center, text(
      size: c.page-footer.size,
      weight: c.page-footer.weight,
      fill: c.colors.brand-primary,
      counter(page).display(c.page-footer.format),
    )),
    [
      #set page(numbering: "1")
      #if title != none or authors.len() > 0 or affiliations.len() > 0 or abstract != none or date != none {
        if c.page.columns > 1 {
          place(top + center, scope: "parent", float: true, clearance: c.article.body-gap, block(width: 100%, front))
        } else {
          block(width: 100%, below: c.article.body-gap, front)
        }
      }
      #if c.toc.depth != 0 {
        outline(title: c.toc.title, depth: c.toc.depth, indent: c.toc.indent)
        v(c.toc.below)
      }
      #body
    ],
  )
}
