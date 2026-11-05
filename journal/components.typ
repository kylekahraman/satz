#import "../defaults.typ": defaults, merge

/// Record one journal entry for `journal-index`.
///
/// The metadata is attached to a `<journal-item>` label at the call location.
/// The index reads its title and date from that metadata and resolves the
/// location to obtain the page number. This helper has no customization
/// arguments and emits no visible page content.
///
/// - title (str, content): title stored for the index
/// - date (str): original date string stored for parsing and display
/// - keywords (str): keyword string stored with the entry; the index does not
///   display it
#let journal-metadata-entry(title, date, keywords) = {
  [#metadata((title: title, date: date, keywords: keywords)) <journal-item>]
}

/// Draw the date and keywords row under a journal entry heading.
///
/// The two columns are equal width. Date and keywords are aligned to the left
/// and right edges respectively. This helper uses the given configuration
/// directly and does not apply a theme or validate config keys.
///
/// - date (content, str): date shown in the left column
/// - keywords (content, str): keywords shown in the right column
/// - config (dictionary): values are merged over the shared defaults. Only
///   `journal.date-size` (length, default `10pt`),
///   `journal.keywords-size` (length, default `9pt`), and
///   `colors.text-muted` (color, default black) affect this row. All other
///   fields are ignored. A caller may pass the already resolved document
///   config to make the colors match its theme.
///   The complete shared schema is page (paper, margin, binding,
///   binding-correction, headers, columns, column-gutter), typography (font,
///   math-font, mono-font, size, line-spacing, leading, paragraph-spacing,
///   first-line-indent, hyphenate, justify), headings (numbering, hyphenate,
///   h1-pagebreak, spacing, h1-h4 size/above/below), journal (header-below,
///   running-gutter, running-leading, running-header-size, date-size,
///   keywords-size), decorative (header-size,
///   footer-size, date-size, keywords-size),
///   page-footer (format, size, weight), line-numbers (enabled, format, scope,
///   size, color, clearance), links (color, url-color), tables (stroke, inset,
///   font-size, caption-position, caption-gap), callouts (inset, radius,
///   stroke, title-below, paragraph-spacing, list-spacing), captions (size,
///   weight, alignment, label-weight), toc (depth, title, indent, entry-size,
///   leading, entry-above, main-entry-above, title-below, below), lof and lot
///   (depth, title, indent, entry-size, leading, entry-above, title-below,
///   below, compact), bibliography (style), and colors (bg-paper, bg-subtle,
///   brand-primary, brand-accent, text-main, text-muted). Values have the
///   types accepted by the shared defaults, but this helper does not validate
///   them. Unknown group names and additional fields are also merged and
///   ignored unless one of the three consumed fields above reads them.
///   Shared-baseline types/defaults are: page.paper (paper name, a4),
///   margin (edge dictionary using top/bottom/left/right or inside/outside,
///   with x/y shorthands; 2.5cm each edge), binding (alignment or none,
///   none), binding-correction (length, 0pt), headers (bool, false), columns
///   (positive int, 1), column-gutter (length, 5mm); typography.font (font
///   name, Libertinus Serif), math-font/mono-font (font name or auto, auto),
///   size (length, 11pt), line-spacing (positive number or none, none), leading
///   (length, 0.65em), list-spacing (non-negative number, 0.5; additional item
///   gap as a fraction of calculated baseline distance, following line-spacing
///   or font metrics and leading; 0 adds no extra gap), paragraph-spacing
///   (length, 1.2em), first-line-indent/
///   hyphenate/justify (bool, false/false/true); headings.numbering (pattern
///   or none, "1.1"), hyphenate/h1-pagebreak (bool, false), spacing ("koma" or
///   "native", "koma"), h1-h4-size (lengths, 14pt/12pt/11pt/11pt), h1-h4-above
///   and h1-h4-below (auto or length, auto); journal.header-below/
///   running-gutter/running-leading (lengths, 1.5em/1em/0.35em),
///   running-header-size/date-size/keywords-size (lengths, 9pt/10pt/9pt); decorative
///   header-size/footer-size/date-size/keywords-size (lengths,
///   9pt/10pt/10pt/9pt); page-footer.format (numbering pattern, "1"), size (length, 10pt),
///   weight (font weight, regular); line-numbers.enabled (bool, false),
///   format (numbering pattern, "1"), scope (document or page, document), size
///   (length, 8pt), color (#64748B), clearance (auto or length, auto);
///   links.color/url-color (#0563C1); tables.stroke (length, 0.5pt), inset
///   (length or x/y dictionary, x=8pt and y=4pt), font-size (length, 10pt),
///   caption-position (top or bottom, top), caption-gap (length, 6pt);
///   callouts.inset/radius/stroke/title-below/paragraph-spacing/list-spacing
///   (lengths, 9pt/3pt/0.8pt/1em/1em/1.2em); captions.size (length, 10pt),
///   weight/label-weight (font weights, regular), alignment (left), hanging (true);
///   toc.depth (none or nonnegative int, none), title (content or none, Table
///   of Contents), indent (auto or length, auto), entry-size (length, 10pt),
///   leading/entry-above (lengths, 0.65em), main-entry-above (length, 1.25em),
///   title-below (length, 1.5em), below (length, 2em); lof/lot use the same
///   types and defaults as toc except for their own default titles,
///   entry-above 0.85em, and compact (bool, false);
///   bibliography.style (CSL name, apa); colors.bg-paper/bg-subtle/
///   brand-primary/brand-accent/text-main/text-muted (colors,
///   white/white/black/black/black/black). In a resolved journal config, page
///   defaults to ISO B5 with 2cm horizontal and 2.5cm vertical margins, body
///   text to Libertinus Serif 11pt, the shared list-spacing default of 0.5,
///   and muted text to #5e5e5a; an explicit theme may alter colors. Shared extension
///   fields page.header-ascent, headings.h1-number-size, and decorative
///   list-indent/list-body-indent/list-block-spacing are lengths when another
///   template supports them; this helper also merges and ignores them.
#let journal-date-keywords(date, keywords, config: (:)) = {
  let c = merge(defaults, config)
  grid(
    columns: (1fr, 1fr),
    align(left)[#text(size: c.journal.date-size, style: "italic", fill: c.colors.text-muted)[#date]],
    align(right)[#text(size: c.journal.keywords-size, fill: c.colors.text-muted, weight: "medium")[#keywords]]
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
