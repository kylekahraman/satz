#import "../class.typ": document-class
#import "../defaults.typ": defaults, merge
#import "../themes.typ": theme-config
#import "defaults.typ": defaults as article-defaults

/// An article with a full-width title/author/abstract block and native columns.
///
/// Defaults to two columns, ordinary page numbering, and no automatic front matter.
/// Set `config: (page: (columns: 1))` for a one-column assignment or article.
/// Figures can span both columns with `scope: "parent", placement: top`.
///
/// - title (str, content, none): article title
/// - authors (array): dictionaries with `name` and optional `affiliations` indices
/// - affiliations (array): affiliation strings or content, indexed from 1
/// - abstract (content, none): full-width abstract
/// - date (str, content, none): optional date beneath the authors
/// - config (dictionary): shared satz and article style overrides
/// - theme (str, none): `neutral`, `soft-jade`, `soft-slate`, `warm-editorial`,
///   `plum`, or `soft-rose`; explicit config overrides it
/// - body (content): the article
#let article(title: none, authors: (), affiliations: (), abstract: none, date: none, config: (:), theme: none, body) = {
  assert(type(authors) == array, message: "article authors must be an array of records.")
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
        text(size: c.article.author-size,
          authors.map(author => [
            #author.name#if author.at("affiliations", default: ()) != () {
              super(author.affiliations.map(str).join(","))
            }
          ]).join(h(1em)))
      }
      #for (index, affiliation) in affiliations.enumerate() {
        block(above: 0.3em, text(size: c.article.affiliation-size)[#super(str(index + 1)) #affiliation])
      }
      #if date != none { block(above: 0.5em, date) }
    ]
    #if abstract != none {
      block(above: c.article.title-gap, inset: (x: 5%))[
        #set text(size: c.article.abstract-size)
        #set par(justify: true)
        #strong[Abstract]

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
