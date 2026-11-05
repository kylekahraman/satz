#import "defaults.typ": merge
#import "themes.typ": theme-config

/// Resolve the appearance config used by the letter and invoice templates.
///
/// Starts from the template-specific defaults, applies a named palette, then
/// applies direct template arguments and finally the nested config, so
/// explicit config values have highest precedence. Only the closed appearance
/// groups and keys listed below are accepted; unsupported groups or keys fail
/// with an assertion.
///
/// - template-defaults (dictionary): complete template appearance defaults
/// - theme (str, none): palette name accepted by theme-config; none keeps
///   the defaults' colors
/// - direct (dictionary): normalized direct appearance arguments, such as
///   paper, margins, font, font size, leading, and justification
/// - config (dictionary): nested overrides. page accepts paper and margin;
///   typography accepts font, size, leading, justify, and hyphenate; colors
///   accepts bg-paper, brand-primary, and text-main; links accepts color and
///   url-color. Every group value must be a dictionary.
///   These postal templates accept only those fields and reject all other
///   shared or extension fields; none are silently ignored. For clarity, the
///   full shared schema includes page (paper, margin, binding,
///   binding-correction, headers, columns, column-gutter), typography (font,
///   math-font, mono-font, size, line-spacing, leading, list-spacing, paragraph-spacing,
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
///   brand-primary, brand-accent, text-main, text-muted). Shared extension
///   fields such as page.header-ascent, headings.h1-number-size, and
///   decorative list-indent/list-body-indent/list-block-spacing are also
///   rejected. Accepted postal config values override direct arguments and
///   themed values; direct arguments override the selected theme and template
///   defaults. Accepted fields are all consumed by the postal templates.
///   Shared field types and baseline defaults are: page.paper (paper name,
///   a4), page.margin (edge-to-length dictionary using top/bottom/left/right or
///   inside/outside, with x/y shorthands; 2.5cm each edge),
///   page.binding (alignment or none, none), page.binding-correction (length,
///   0pt), page.headers (bool, false), page.columns (positive int, 1),
///   page.column-gutter (length, 5mm); typography.font (font name,
///   Libertinus Serif), math-font and mono-font (font name or auto, auto),
///   size (length, 11pt), line-spacing (positive number or none, none),
///   leading (length, 0.65em), list-spacing (non-negative number, 0.5; extra
///   list-item gap as a fraction of calculated body baseline distance, following
///   line-spacing or font metrics plus leading; 0 adds no extra gap),
///   paragraph-spacing (length, 1.2em),
///   first-line-indent, hyphenate, and justify (bool, false, false, true);
///   headings.numbering (pattern/function or none, "1.1"), hyphenate and h1-pagebreak
///   (bool, false), spacing ("koma" or "native", "koma"), h1-h4-size (lengths,
///   14pt/12pt/11pt/11pt), h1-h4-above and h1-h4-below (auto or length, auto);
///   journal.header-below/running-gutter/running-leading (lengths,
///   1.5em/1em/0.35em), running-header-size/date-size/keywords-size (lengths,
///   9pt/10pt/9pt);
///   decorative.header-size/footer-size/date-size/keywords-size (lengths,
///   9pt/10pt/10pt/9pt); page-footer.format (numbering pattern, "1"), size (length, 10pt),
///   weight (font weight, regular); line-numbers.enabled (bool, false),
///   format (numbering pattern, "1"), scope ("document" or "page", document),
///   size (length, 8pt), color (#64748B), clearance (auto or length, auto);
///   links.color/url-color (#0563C1); tables.stroke (length, 0.5pt), inset
///   (length or x/y dictionary, x=8pt and y=4pt), font-size (length, 10pt),
///   caption-position (top or bottom, top), caption-gap (length, 6pt);
///   callouts.inset/radius/stroke/title-below/paragraph-spacing/list-spacing
///   (lengths, 9pt/3pt/0.8pt/1em/1em/1.2em); captions.size (length, 10pt),
///   weight and label-weight (font weights, regular), alignment (alignment,
///   left), hanging (boolean, true); toc.depth (none or nonnegative int, none), title (content or
///   none, Table of Contents), indent (auto or length, auto), entry-size
///   (length, 10pt), leading/entry-above (lengths, 0.65em), main-entry-above
///   (length, 1.25em), title-below (length, 1.5em), below (length, 2em);
///   lof/lot use the same types, with List of Figures/List of Tables titles,
///   entry-above 0.85em, and compact (bool, false); bibliography.style (CSL
///   name, apa); colors.bg-paper/bg-subtle/brand-primary/brand-accent/
///   text-main/text-muted (colors, white/white/black/black/black/black).
///   Template-specific extension fields have no shared baseline default:
///   page.header-ascent, headings.h1-number-size, and the three decorative
///   list geometry fields are lengths when supported by another template.
/// -> dictionary: merged appearance settings; the inputs are not mutated
#let resolve-postal-appearance(template-defaults, theme, direct, config) = {
  let supported = (
    page: ("paper", "margin"),
    typography: ("font", "size", "leading", "justify", "hyphenate"),
    colors: ("bg-paper", "brand-primary", "text-main"),
    links: ("color", "url-color"),
  )
  for (group, options) in config {
    assert(group in supported,
      message: "Unsupported appearance config group `" + group + "`. Supported groups are page, typography, colors, and links.")
    assert(type(options) == dictionary,
      message: "Appearance config `" + group + "` must be a dictionary.")
    for (key, _) in options {
      assert(key in supported.at(group),
        message: "Unsupported appearance setting `" + group + "." + key + "` for letters and invoices.")
    }
  }
  let themed = merge(template-defaults, theme-config(theme))
  merge(merge(themed, direct), config)
}
