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
/// - config (dictionary): nested overrides, deep-merged so omitted fields
///   retain these effective article defaults. Known shared groups reject
///   unknown field names; unknown top-level groups such as `article` are
///   allowed. Theme colors are applied first, then config overrides them.
///   Supported fields and defaults:
///   - `page.paper` (paper name/custom size; `"a4"`), `page.margin` (length or
///     edge-to-length dictionary; 2.5cm each; accepts `top`, `bottom`, `left`,
///     `right`, `x`, `y`, `inside`, `outside`), `page.binding`
///     (`none`/`left`/`right`; `none`),
///     `page.binding-correction` (length; `0pt`), `page.headers` (bool;
///     `false`), `page.columns` (positive int; `2`), and
///     `page.column-gutter` (length; `5mm`) control page geometry and columns.
///   - `typography.font` (font name; `"Libertinus Serif"`), `math-font` and
///     `mono-font` (font name or `auto`; `auto`), `size` (length; `10pt`),
///     `line-spacing` (positive multiple or `none`; `none`), `leading` (length;
///     `0.65em`), `paragraph-spacing` (length; `1.2em`),
///     `first-line-indent` (bool; `false`), `hyphenate` (bool; `true`), and
///     `justify` (bool; `true`) control body typography. `line-spacing`, when
///     set, overrides `leading`; `first-line-indent: true` uses a one-em
///     horizontal indent.
///   - `typography.list-spacing` (non-negative number; `0.5`): additional gap
///     between list items as a fraction of the calculated body baseline
///     distance. It follows `typography.line-spacing` when set, or font
///     metrics and `typography.leading` otherwise. Use `0` for no extra gap.
///   - `headings.numbering` (pattern/function or `none`; `none`),
///     `hyphenate` (bool; `false`), `h1-pagebreak` (bool; `false`),
///     `spacing` (`"koma"`/`"native"`; `"koma"`), `h1-size`–`h4-size`
///     (lengths; 12pt, 10.5pt, 10pt, 10pt), and each level's `*-above` and
///     `*-below` (length or `auto`; `auto`) control heading formatting.
///   - `journal.header-below` (1.5em), `running-gutter` (1em),
///     `running-leading` (0.35em), `running-header-size` (9pt), `date-size`
///     (10pt), and `keywords-size` (9pt): journal furniture settings; article
///     does not use them.
///   - `decorative.header-size` (9pt), `footer-size` (10pt), `date-size`
///     (10pt), and `keywords-size` (9pt): shared text furniture settings.
///   - `page-footer.format` (numbering pattern/function; `"1"`), `size`
///     (length; `10pt`), and `weight` (font weight; `"regular"`) configure
///     page numbers.
///   - `line-numbers.enabled` (bool; `false`), `format` (pattern; `"1"`),
///     `scope` (`"document"`/`"page"`; `"document"`), `size` (length; `8pt`),
///     `color` (color; `#64748B`), and `clearance` (length or `auto`; `auto`)
///     configure draft line numbering. Article enables it only when requested.
///   - `links.color` and `url-color` (colors; neutral `#0563C1`) set internal
///     and external link colors.
///   - `tables.stroke` (length; `0.5pt`), `inset` (length or x/y dictionary;
///     `(x: 8pt, y: 4pt)`), `font-size` (length; `10pt`),
///     `caption-position` (`top`/`bottom`; `top`), and `caption-gap` (length;
///     `6pt`) configure shared table helpers.
///   - `callouts.inset` (9pt), `radius` (3pt), `stroke` (0.8pt),
///     `title-below` (1em), `paragraph-spacing` (1em), and `list-spacing`
///     (1.2em) are lengths controlling callout geometry and content gaps.
///   - `captions.size` (10pt), `weight` (`"regular"`), `alignment` (`left`),
///     `label-weight` (`"regular"`), and `hanging` (`true`) style captions.
///   - `toc` defaults: `depth` (none or non-negative int; article overrides to
///     0), `title` (content or none; `[Table of Contents]`), `indent`
///     (length or auto; auto), `entry-size` (10pt), `leading` (0.65em),
///     `entry-above` (0.65em), `main-entry-above` (1.25em), `title-below`
///     (1.5em), and `below` (2em). `lof`/`lot` have the same fields except
///     `main-entry-above`, with titles `[List of Figures]`/`[List of Tables]`,
///     depth none (article overrides to 0), and `entry-above` 0.85em. They also
///     accept `compact` (bool; false), which omits captions from that list.
///     Article sets all list depths to 0; `toc.depth` above 0 or `none` enables
///     inline contents after the title block.
///   - `bibliography.style` (CSL style name; `"apa"`) selects bibliography
///     style where supported.
///   - `colors.bg-paper`, `bg-subtle`, `brand-primary`, `brand-accent`,
///     `text-main`, and `text-muted` (colors; neutral article defaults are
///     white paper/subtle fill and black text/accent) set page and text colors.
///   - Article-only `article.title-size` (18pt), `author-size` (11pt),
///     `author-gap` (0.8em), `affiliation-size` (8.5pt), `abstract-size`
///     (9pt), `title-gap` (1.2em), and `body-gap` (2.2em) are lengths for the
///     metadata block and body start.
///   Article applies page and typography fields, heading fields, list
///   spacing, page-footer format/size/weight, line-number and link settings,
///   table inset/font size, caption fields, bibliography style, and
///   `colors.bg-paper`, `brand-primary`, `text-main`, and `text-muted`.
///   `page.headers` applies only with two-sided binding. Inline contents use
///   `toc.depth`, `title`, `indent`, and `below`; `entry-size`, `leading`,
///   `entry-above`, `main-entry-above`, and `title-below` are accepted but do
///   not style that native outline. The article accepts but does not render
///   `lof.*`, `lot.*`, `journal.*`, `callouts.*`, decorative date/keyword/footer
///   sizes, `tables.stroke`/`caption-position`/`caption-gap`, or
///   `colors.bg-subtle`/`brand-accent`. Pass component-only settings directly
///   to the matching component. Other template extension groups are not
///   applied to an article.
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
