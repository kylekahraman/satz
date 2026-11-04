#import "defaults.typ": merge, validate-config

// Shared cover page — a composable layout plus ready-to-use title-page styles.

/// Built-in cover palettes as a dictionary keyed by palette name:
/// `neutral`, `slate`, `soft-jade`, `soft-slate`, `warm-editorial`, `plum`, and
/// `soft-rose`.
///
/// Each value contains `bg-paper`, `brand-primary`, `brand-accent`, `text-main`,
/// and `text-muted`. Covers keep tinted paper in every palette except neutral.
/// Accents are grayscale, jade, slate, warm brown, plum, and rose. The accent is
/// used sparingly for rules and the optional research-cover illustration.
#let cover-themes = (
  neutral: (
    bg-paper: rgb("#FFFFFF"),
    brand-primary: black,
    brand-accent: black,
    text-main: black,
    text-muted: black,
  ),
  slate: (
    bg-paper: rgb("#f8fafc"),
    brand-primary: rgb("#1d293d"),
    brand-accent: rgb("#0f172b"),
    text-main: rgb("#020618"),
    text-muted: rgb("#90a1b9"),
  ),
  soft-jade: (
    bg-paper: rgb("#FBFAF7"),
    brand-primary: rgb("#355D50"),
    brand-accent: rgb("#B8C9BE"),
    text-main: rgb("#282D29"),
    text-muted: rgb("#59665F"),
  ),
  soft-slate: (
    bg-paper: rgb("#FBFAF7"),
    brand-primary: rgb("#344B55"),
    brand-accent: rgb("#BCC9CC"),
    text-main: rgb("#282B2C"),
    text-muted: rgb("#59636A"),
  ),
  warm-editorial: (
    bg-paper: rgb("#FBF8F2"),
    brand-primary: rgb("#654A3B"),
    brand-accent: rgb("#D8C4B3"),
    text-main: rgb("#2F2A26"),
    text-muted: rgb("#665F58"),
  ),
  plum: (
    bg-paper: rgb("#FBF8FB"),
    brand-primary: rgb("#674666"),
    brand-accent: rgb("#D3C3D4"),
    text-main: rgb("#302A31"),
    text-muted: rgb("#685F69"),
  ),
  soft-rose: (
    bg-paper: rgb("#FCF8F8"),
    brand-primary: rgb("#713C4A"),
    brand-accent: rgb("#D8BEC4"),
    text-main: rgb("#302A2C"),
    text-muted: rgb("#6B5D61"),
  ),
)

/// Baseline values consumed by `cover-page()` before theme and user overrides.
///
/// The cover starts on A4 with 2.5cm margins, Libertinus Serif at 11pt, and the
/// neutral black-on-white palette. Cover `config` is merged on top of these
/// values after the selected theme; only page paper/margins, text font/size, and
/// the five cover colors are consumed by the renderer.
#let cover-defaults = (
  page: (
    paper: "a4",
    margin: (top: 2.5cm, bottom: 2.5cm, left: 2.5cm, right: 2.5cm),
  ),
  typography: (
    font: "Libertinus Serif",
    size: 11pt,
  ),
  colors: cover-themes.neutral,
)

/// Draw the small brain-and-connectome illustration used on research covers.
///
/// The drawing uses vector shapes so it stays crisp in print. The parameters
/// provide its primary ink, secondary accent, and paper colors; no text or
/// labels are included. This is an internal helper for `cover-page()`.
///
/// - ink (color): primary outline and neural paths
/// - accent (color): secondary nodes and connections
/// - paper (color): fill used to separate the brain shape from its background
/// -> content: a compact, right-aligned illustration
#let research-connectome(ink, accent, paper) = {
  let svg = (
    "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"360\" height=\"190\" viewBox=\"0 0 360 190\">" +
    "<path d=\"M77 119 C61 109 55 91 61 75 C67 58 82 46 101 41 C119 29 145 25 166 30 C184 25 204 32 216 44 C236 49 251 63 254 81 C260 97 249 111 233 117 C220 128 201 129 185 122 C170 131 151 129 137 120 C119 130 99 127 88 118 C84 120 80 120 77 119 Z M158 128 C160 144 166 158 173 168 C180 157 184 144 184 128\" fill=\"#ABCDEF\" fill-opacity=\".12\" stroke=\"#123456\" stroke-width=\"2.4\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/>" +
    "<path d=\"M232 109 C243 101 256 105 260 115 C264 125 257 135 247 137 C237 139 229 132 228 122\" fill=\"none\" stroke=\"#123456\" stroke-width=\"2\" stroke-linecap=\"round\"/>" +
    "<g fill=\"none\" stroke=\"#ABCDEF\" stroke-width=\"2\" stroke-linecap=\"round\" opacity=\".92\">" +
    "<path d=\"M91 40 C105 32 117 40 117 51 C117 61 109 67 99 68 M139 25 C130 39 138 49 150 53 C160 57 163 67 155 75 M187 29 C176 40 181 51 191 57 C199 63 198 74 190 81 M239 48 C224 48 218 59 225 69 C231 78 227 87 217 92 M78 83 C93 77 105 84 104 96 C103 106 96 110 89 111 M133 96 C144 84 159 88 161 101 C163 112 155 119 145 121 M202 101 C193 90 179 93 177 105 C175 116 183 123 194 124\"/>" +
    "</g>" +
    "<g fill=\"none\" stroke=\"#123456\" stroke-width=\"1.5\" stroke-linecap=\"round\" opacity=\".76\">" +
    "<path d=\"M86 57L119 43L151 57L184 44L220 58L249 76 M69 88L105 91L139 83L171 94L208 83L246 99 M88 116L121 124L151 108L181 126L213 111L244 128 M86 57L105 91L88 116 M119 43L105 91L139 83L121 124 M151 57L139 83L171 94L151 108 M184 44L171 94L208 83L181 126 M220 58L208 83L246 99L244 128 M139 83L151 108L171 94L181 126 M208 83L213 111\"/>" +
    "</g>" +
    "<g fill=\"#FBFAF7\" stroke=\"#123456\" stroke-width=\"2\">" +
    "<circle cx=\"86\" cy=\"57\" r=\"4.5\"/><circle cx=\"119\" cy=\"43\" r=\"4.5\"/><circle cx=\"151\" cy=\"57\" r=\"4.5\"/><circle cx=\"184\" cy=\"44\" r=\"4.5\"/><circle cx=\"220\" cy=\"58\" r=\"4.5\"/>" +
    "<circle cx=\"69\" cy=\"88\" r=\"4.5\"/><circle cx=\"105\" cy=\"91\" r=\"4.5\"/><circle cx=\"139\" cy=\"83\" r=\"4.5\"/><circle cx=\"171\" cy=\"94\" r=\"4.5\"/><circle cx=\"208\" cy=\"83\" r=\"4.5\"/><circle cx=\"246\" cy=\"99\" r=\"4.5\"/>" +
    "<circle cx=\"88\" cy=\"116\" r=\"4.5\"/><circle cx=\"121\" cy=\"124\" r=\"4.5\"/><circle cx=\"151\" cy=\"108\" r=\"4.5\"/><circle cx=\"181\" cy=\"126\" r=\"4.5\"/><circle cx=\"213\" cy=\"111\" r=\"4.5\"/><circle cx=\"244\" cy=\"128\" r=\"4.5\"/>" +
    "</g></svg>"
  )
  image(
    bytes(svg.replace("#123456", ink.to-hex()).replace("#ABCDEF", accent.to-hex()).replace("#FBFAF7", paper.to-hex())),
    format: "svg",
    width: 8.5cm,
    alt: "Side-view brain illustration with connected neural nodes",
  )
}

/// Build an optional cover page, either from custom content or title fields.
///
/// This is a component, not a document template: place it before `report`, or
/// anywhere else a cover is wanted. It has no implicit connection to another
/// template's `config` or `theme`; pass those values explicitly when the cover
/// should share the document appearance.
///
/// Appearance precedence is cover defaults, then the selected cover `theme`,
/// then `config`. `config` may contain normal shared Satz settings, but the
/// cover consumes only `page.paper`, `page.margin`, `typography.font`,
/// `typography.size`, and `colors.bg-paper`, `brand-primary`, `brand-accent`,
/// `text-main`, and `text-muted`. Other valid shared settings are accepted and
/// ignored. Known config groups are validated for misspelled keys.
///
/// The default `classic` layout preserves the slot-based cover. Set `layout` to
/// `"research"` or `"minimal"` and provide `title` to use a ready-made title page.
/// The generated title sizes are intentionally part of each preset.
///
/// ```typst
/// #let theme = "soft-jade"
/// #let shared = (typography: (font: "EB Garamond"),)
/// #cover-page(layout: "research", title: [Field notes], theme: theme, config: shared)
/// #show: report.with(theme: theme, config: shared)
/// = Introduction
/// ```
///
/// - config (dictionary): nested Satz config. Dictionaries merge recursively.
///   Precedence is cover defaults, selected theme colors, then explicit config.
///   This cover reads only the fields marked **used** below; other valid fields
///   are accepted and ignored. The neutral effective defaults are A4, 2.5cm
///   margins, Libertinus Serif 11pt, white paper, and black for the other four
///   cover colors. A selected non-neutral theme replaces all five colors before
///   config overrides them. Example: `config: (typography: (font: "STIX Two Text"),
///   colors: (brand-primary: blue))`.
///
///   Complete shared schema accepted by this function:
///   - `page.paper` (paper name/custom size; default `"a4"`; **used**);
///     `margin` (dictionary of edge lengths, default 2.5cm each; supports
///     top/bottom/left/right, inside/outside, or x/y; **used**); `binding`
///     (`none`/`left`/`right`, default `none`; ignored); `binding-correction`
///     (length, `0pt`; ignored); `headers` (bool, `false`; ignored); `columns`
///     (positive integer, 1; ignored); `column-gutter` (length, 5mm; ignored);
///     `header-ascent` (length, extra key; ignored).
///   - `typography.font` (font name, `"Libertinus Serif"`; **used**), `size`
///     (length, 11pt; **used**); `math-font`, `mono-font` (font name or `auto`,
///     default `auto`; ignored); `line-spacing` (positive number or `none`,
///     `none`; ignored); `leading` (length, 0.65em; ignored);
///     `paragraph-spacing` (length, 1.2em; ignored); `first-line-indent` (bool,
///     `false`; ignored); `hyphenate` (bool, `false`; ignored); `justify` (bool,
///     `true`; ignored).
///   - `headings.numbering` (Typst numbering pattern/function or `none`,
///     `"1.1"`; ignored); `hyphenate` (bool, `false`; ignored);
///     `h1-pagebreak` (bool, `false`; ignored); `spacing` (`"koma"` or
///     `"native"`, `"koma"`; ignored); `h1-size`–`h4-size` (lengths,
///     14pt/12pt/11pt/11pt; ignored); `h1-above`–`h4-above` and
///     `h1-below`–`h4-below` (`auto` or length, `auto`; ignored);
///     `h1-number-size` (extra length key with no shared default; ignored).
///   - `journal.header-below` (length, 1.5em), `running-gutter` (1em), and
///     `running-leading` (0.35em); all ignored.
///   - `decorative.header-size` (9pt), `footer-size` (10pt), `date-size`
///     (10pt), `keywords-size` (9pt), `list-tight` (bool, false),
///     `list-spacing` (0.9em); all ignored. Extra `list-indent`,
///     `list-body-indent`, and `list-block-spacing` lengths are also ignored.
///   - `page-footer.format` (Typst numbering pattern/function, `"1"`),
///     `size` (10pt), `weight` (Typst font weight, `"regular"`); ignored.
///   - `line-numbers.enabled` (bool, false), `format` (numbering pattern,
///     `"1"`), `scope` (`"document"` or `"page"`, `"document"`), `size`
///     (8pt), `color` (`#64748B`), `clearance` (`auto` or length, `auto`);
///     ignored.
///   - `links.color`, `url-color` (colors, both `#0563C1`); ignored.
///   - `tables.stroke` (0.5pt), `inset` (length or dictionary, `(x: 8pt,
///     y: 4pt)`), `font-size` (10pt), `caption-position` (`top`/`bottom`,
///     `top`), `caption-gap` (6pt); ignored.
///   - `callouts.inset` (9pt), `radius` (3pt), `stroke` (0.8pt), `title-below`
///     (1em), `paragraph-spacing` (1em), `list-spacing` (1.2em); ignored.
///   - `captions.size` (10pt), `weight` (`"regular"`), `alignment` (Typst
///     alignment, `center`), and `label-weight` (`"regular"`); all are ignored.
///   - `toc.depth` (none or nonnegative integer, `none`), `title` (content or
///     none, `[Table of Contents]`), `indent` (auto or length, `auto`),
///     `entry-size` (10pt), `leading` (0.65em), `entry-above` (0.65em),
///     `main-entry-above` (1.25em), `title-below` (1.5em), `below` (2em);
///     ignored.
///   - `lof` and `lot` use the same fields; defaults are depth none, their
///     English list title, auto indent, 10pt entry size, 0.65em leading,
///     0.85em entry gap, 1.5em title gap, 2em below gap, and `compact: false`.
///     `compact` is bool. These fields are ignored by the cover.
///   - `bibliography.style` (CSL style name, `"apa"`); ignored.
///   - `colors.bg-paper`, `bg-subtle`, `brand-primary`, `brand-accent`,
///     `text-main`, `text-muted` (colors; neutral defaults white/white/black/
///     black/black/black; **used**). `bg-subtle` is accepted but ignored; the
///     other five color fields style the cover.
///   Unknown keys inside known shared groups are rejected. Additional
///   template-specific or caller extension groups are accepted and ignored.
/// - logos (none, content): optional logos at the top left
/// - body (none, content): custom cover body; overrides generated title content
/// - footer (none, content): custom content at the bottom center
/// - footer-left (none, content): custom content at the bottom left
/// - layout (str): `"classic"` (default), `"research"`, or `"minimal"`.
///   Classic requires `body`; the generated layouts require `title`.
/// - theme (str): `neutral` (default), `slate`, `soft-jade`, `soft-slate`,
///   `warm-editorial`, `plum`, or `soft-rose`
/// - title (none, str, content): generated-cover title; use `box` to keep a word
///   together. Ignored by classic covers.
/// - subtitle (none, str, content): optional generated-cover subtitle
/// - author (none, str, content): optional generated-cover author line
/// - date (none, str, content): date in the research title block, or at the
///   bottom of a minimal cover when `footer` is absent
/// - keywords (none, str, content): optional keywords in the research title block
/// - supervisors (none, array of str): names printed bottom-left when
///   `footer-left` is absent
/// - body (content, none): classic custom cover body. Supplying it for any
///   layout suppresses all generated title fields.
/// - footer (none, content): bottom-center content; replaces the minimal date
/// - footer-left (none, content): bottom-left content; replaces `supervisors`
#let cover-page(
  config: (:),
  logos: none,
  body: none,
  footer: none,
  footer-left: none,
  layout: "classic",
  theme: "neutral",
  title: none,
  subtitle: none,
  author: none,
  date: none,
  keywords: none,
  supervisors: none,
) = {
  assert(type(config) == dictionary, message: "Cover config must be a dictionary.")
  let _ = validate-config(config)
  assert(type(layout) == str, message: "Cover layout must be a string: classic, research or minimal.")
  assert(type(theme) == str, message: "Cover theme must be a string naming a built-in cover palette.")
  if not ("classic", "research", "minimal").contains(layout) {
    panic("Unknown cover layout '" + layout + "'. Use classic, research, or minimal.")
  }

  let theme-colors = cover-themes.at(theme, default: none)
  if theme-colors == none {
    panic("Unknown cover theme '" + theme + "'. See cover-themes for available themes.")
  }

  let user-colors = config.at("colors", default: (:))
  let colors = (: ..theme-colors, ..user-colors)
  let c = merge(cover-defaults, (: ..config, colors: colors))

  if body == none and title == none {
    panic("Pass either body: [...] or title: \"...\" to cover-page().")
  }
  if body == none and layout == "classic" {
    panic("The generated title-page layouts are research and minimal. For classic, pass body: [...] or choose layout: \"research\" / \"minimal\".")
  }

  let cover-body = if body != none {
    body
  } else if layout == "research" {
    [
      #block(width: 100%)[
        #v(4.5cm)
        #grid(
          columns: (3pt, 1fr),
          column-gutter: 0.7cm,
          align: horizon,
          rect(width: 3pt, height: 4.5cm, fill: c.colors.brand-primary),
          block(width: 100%)[
            #text(size: 18pt, weight: "bold", fill: c.colors.brand-primary)[#title]
            #if subtitle != none [
              #v(0.3cm)
              #text(size: 13pt, style: "italic", fill: c.colors.text-muted)[#subtitle]
            ]
          ],
        )
        #v(1.1cm)
        #if author != none [#text(size: 13pt, weight: "medium", fill: c.colors.text-main)[#author]]
        #if date != none or keywords != none [
          #v(0.35cm)
          #text(size: 9pt, fill: c.colors.text-muted)[
            #if date != none [#date]
            #if date != none and keywords != none [  ·  ]
            #if keywords != none [#keywords]
          ]
        ]
      ]
    ]
  } else {
    [
      #v(8cm)
      #text(size: 25pt, weight: "bold", fill: c.colors.brand-primary)[#title]
      #if subtitle != none [
        #v(0.3cm)
        #text(size: 13pt, style: "italic", fill: c.colors.text-muted)[#subtitle]
      ]
      #if author != none [
        #v(1.2cm)
        #text(size: 13pt, fill: c.colors.text-main)[#author]
      ]
    ]
  }

  page(
    paper: c.page.paper,
    fill: c.colors.bg-paper,
    margin: c.page.margin,
    header: none,
    footer: none,
  )[
    #set text(font: c.typography.font, size: c.typography.size, fill: c.colors.text-main)

    // Logos stay in their original colors and keep their top-left position.
    #if logos != none {
      place(top + left)[#logos]
    }

    // The connectome sits in open space below the title and never carries text.
    #if layout == "research" {
      place(bottom + right, dx: -0.2cm, dy: -2.6cm)[
        #research-connectome(c.colors.brand-primary, c.colors.brand-accent, c.colors.bg-paper)
      ]
    }

    #align(if layout == "research" { left } else { center })[#cover-body]

    #if footer != none {
      place(bottom + center)[#footer]
    } else if date != none and layout == "minimal" {
      place(bottom + center)[#text(size: 9pt, fill: c.colors.text-muted)[#date]]
    }

    #if footer-left != none {
      place(bottom + left, dy: -1.5cm)[#footer-left]
    } else if supervisors != none {
      place(bottom + left, dy: -1.5cm)[
        #text(size: 9pt, fill: c.colors.text-muted)[
          *Supervisors:* \
          #supervisors.join("\n")
        ]
      ]
    }
  ]
}

/// Create a research notebook cover with a neural-connectivity motif.
///
/// Render a research title page with a neural-connectivity illustration. The
/// illustration uses the chosen primary, accent, and paper colors. A following
/// document does not inherit this cover's theme or config; pass matching values
/// to both calls if they should share an appearance.
///
/// ```typst
/// #research-cover(
///   title: [Field notes],
///   author: [Alex Example],
///   date: "2026",
///   theme: "soft-jade",
/// )
/// ```
///
/// - title (content, str): required title; use `box(...)` to keep a word
///   together
/// - subtitle (content, str, none): optional line beneath the title
/// - author (content, str, none): optional author line
/// - date (content, str, none): optional date in the title block
/// - keywords (content, str, none): optional keywords in the title block
/// - supervisors (array of str, none): optional bottom-left names
/// - logos (content, none): optional content at the top left
/// - body (content, none): optional custom cover body; replaces generated fields
/// - footer (content, none): optional bottom-center content
/// - footer-left (content, none): optional bottom-left content; replaces
///   `supervisors`
/// - theme (str): `neutral` (default), `slate`, `soft-jade`, `soft-slate`,
///   `warm-editorial`, `plum`, or `soft-rose`
/// - config (dictionary): nested Satz config. Dictionaries merge recursively.
///   Precedence is cover defaults, selected theme colors, then explicit config.
///   This cover reads only the fields marked **used** below; other valid fields
///   are accepted and ignored. The neutral effective defaults are A4, 2.5cm
///   margins, Libertinus Serif 11pt, white paper, and black for the other four
///   cover colors. A selected non-neutral theme replaces all five colors before
///   config overrides them. Example: `config: (typography: (font: "STIX Two Text"),
///   colors: (brand-primary: blue))`.
///
///   Complete shared schema accepted by this function:
///   - `page.paper` (paper name/custom size; default `"a4"`; **used**);
///     `margin` (dictionary of edge lengths, default 2.5cm each; supports
///     top/bottom/left/right, inside/outside, or x/y; **used**); `binding`
///     (`none`/`left`/`right`, default `none`; ignored); `binding-correction`
///     (length, `0pt`; ignored); `headers` (bool, `false`; ignored); `columns`
///     (positive integer, 1; ignored); `column-gutter` (length, 5mm; ignored);
///     `header-ascent` (length, extra key; ignored).
///   - `typography.font` (font name, `"Libertinus Serif"`; **used**), `size`
///     (length, 11pt; **used**); `math-font`, `mono-font` (font name or `auto`,
///     default `auto`; ignored); `line-spacing` (positive number or `none`,
///     `none`; ignored); `leading` (length, 0.65em; ignored);
///     `paragraph-spacing` (length, 1.2em; ignored); `first-line-indent` (bool,
///     `false`; ignored); `hyphenate` (bool, `false`; ignored); `justify` (bool,
///     `true`; ignored).
///   - `headings.numbering` (Typst numbering pattern/function or `none`,
///     `"1.1"`; ignored); `hyphenate` (bool, `false`; ignored);
///     `h1-pagebreak` (bool, `false`; ignored); `spacing` (`"koma"` or
///     `"native"`, `"koma"`; ignored); `h1-size`–`h4-size` (lengths,
///     14pt/12pt/11pt/11pt; ignored); `h1-above`–`h4-above` and
///     `h1-below`–`h4-below` (`auto` or length, `auto`; ignored);
///     `h1-number-size` (extra length key with no shared default; ignored).
///   - `journal.header-below` (length, 1.5em), `running-gutter` (1em), and
///     `running-leading` (0.35em); all ignored.
///   - `decorative.header-size` (9pt), `footer-size` (10pt), `date-size`
///     (10pt), `keywords-size` (9pt), `list-tight` (bool, false),
///     `list-spacing` (0.9em); all ignored. Extra `list-indent`,
///     `list-body-indent`, and `list-block-spacing` lengths are also ignored.
///   - `page-footer.format` (Typst numbering pattern/function, `"1"`),
///     `size` (10pt), `weight` (Typst font weight, `"regular"`); ignored.
///   - `line-numbers.enabled` (bool, false), `format` (numbering pattern,
///     `"1"`), `scope` (`"document"` or `"page"`, `"document"`), `size`
///     (8pt), `color` (`#64748B`), `clearance` (`auto` or length, `auto`);
///     ignored.
///   - `links.color`, `url-color` (colors, both `#0563C1`); ignored.
///   - `tables.stroke` (0.5pt), `inset` (length or dictionary, `(x: 8pt,
///     y: 4pt)`), `font-size` (10pt), `caption-position` (`top`/`bottom`,
///     `top`), `caption-gap` (6pt); ignored.
///   - `callouts.inset` (9pt), `radius` (3pt), `stroke` (0.8pt), `title-below`
///     (1em), `paragraph-spacing` (1em), `list-spacing` (1.2em); ignored.
///   - `captions.size` (10pt), `weight` (`"regular"`), `alignment` (Typst
///     alignment, `center`), and `label-weight` (`"regular"`); all are ignored.
///   - `toc.depth` (none or nonnegative integer, `none`), `title` (content or
///     none, `[Table of Contents]`), `indent` (auto or length, `auto`),
///     `entry-size` (10pt), `leading` (0.65em), `entry-above` (0.65em),
///     `main-entry-above` (1.25em), `title-below` (1.5em), `below` (2em);
///     ignored.
///   - `lof` and `lot` use the same fields; defaults are depth none, their
///     English list title, auto indent, 10pt entry size, 0.65em leading,
///     0.85em entry gap, 1.5em title gap, 2em below gap, and `compact: false`.
///     `compact` is bool. These fields are ignored by the cover.
///   - `bibliography.style` (CSL style name, `"apa"`); ignored.
///   - `colors.bg-paper`, `bg-subtle`, `brand-primary`, `brand-accent`,
///     `text-main`, `text-muted` (colors; neutral defaults white/white/black/
///     black/black/black; **used**). `bg-subtle` is accepted but ignored; the
///     other five color fields style the cover.
///   Unknown keys inside known shared groups are rejected. Additional
///   template-specific or caller extension groups are accepted and ignored.
/// -> content: a generated research title page
#let research-cover = cover-page.with(layout: "research")

/// Create a spare, centered title page for reports, notes, and short documents.
///
/// Render a minimal centered title page. The required title is centered;
/// optional subtitle and author appear below it. The date is placed at the
/// bottom unless a custom `footer` replaces it. A following document does not
/// inherit this cover's theme or config; pass matching values to both calls if
/// they should share an appearance.
///
/// ```typst
/// #minimal-cover(
///   title: [Project notes],
///   subtitle: [A short working document],
///   date: "2026",
/// )
/// ```
///
/// - title (content, str): required cover title
/// - subtitle, author (content, str, none): optional lines beneath the title
/// - date (content, str, none): optional bottom date unless `footer` is supplied
/// - logos (content, none): optional content at top left
/// - body (content, none): optional custom body; replaces generated fields
/// - footer (content, none): optional bottom-center content; replaces the date
/// - footer-left (content, none): optional bottom-left content
/// - supervisors (array of str, none): optional names at bottom left; replaced
///   by `footer-left` when that is supplied
/// - keywords (content, str, none): accepted but not displayed by this layout
/// - theme (str): `neutral` (default), `slate`, `soft-jade`, `soft-slate`,
///   `warm-editorial`, `plum`, or `soft-rose`
/// - config (dictionary): nested Satz config. Dictionaries merge recursively.
///   Precedence is cover defaults, selected theme colors, then explicit config.
///   This cover reads only the fields marked **used** below; other valid fields
///   are accepted and ignored. The neutral effective defaults are A4, 2.5cm
///   margins, Libertinus Serif 11pt, white paper, and black for the other four
///   cover colors. A selected non-neutral theme replaces all five colors before
///   config overrides them. Example: `config: (typography: (font: "STIX Two Text"),
///   colors: (brand-primary: blue))`.
///
///   Complete shared schema accepted by this function:
///   - `page.paper` (paper name/custom size; default `"a4"`; **used**);
///     `margin` (dictionary of edge lengths, default 2.5cm each; supports
///     top/bottom/left/right, inside/outside, or x/y; **used**); `binding`
///     (`none`/`left`/`right`, default `none`; ignored); `binding-correction`
///     (length, `0pt`; ignored); `headers` (bool, `false`; ignored); `columns`
///     (positive integer, 1; ignored); `column-gutter` (length, 5mm; ignored);
///     `header-ascent` (length, extra key; ignored).
///   - `typography.font` (font name, `"Libertinus Serif"`; **used**), `size`
///     (length, 11pt; **used**); `math-font`, `mono-font` (font name or `auto`,
///     default `auto`; ignored); `line-spacing` (positive number or `none`,
///     `none`; ignored); `leading` (length, 0.65em; ignored);
///     `paragraph-spacing` (length, 1.2em; ignored); `first-line-indent` (bool,
///     `false`; ignored); `hyphenate` (bool, `false`; ignored); `justify` (bool,
///     `true`; ignored).
///   - `headings.numbering` (Typst numbering pattern/function or `none`,
///     `"1.1"`; ignored); `hyphenate` (bool, `false`; ignored);
///     `h1-pagebreak` (bool, `false`; ignored); `spacing` (`"koma"` or
///     `"native"`, `"koma"`; ignored); `h1-size`–`h4-size` (lengths,
///     14pt/12pt/11pt/11pt; ignored); `h1-above`–`h4-above` and
///     `h1-below`–`h4-below` (`auto` or length, `auto`; ignored);
///     `h1-number-size` (extra length key with no shared default; ignored).
///   - `journal.header-below` (length, 1.5em), `running-gutter` (1em), and
///     `running-leading` (0.35em); all ignored.
///   - `decorative.header-size` (9pt), `footer-size` (10pt), `date-size`
///     (10pt), `keywords-size` (9pt), `list-tight` (bool, false),
///     `list-spacing` (0.9em); all ignored. Extra `list-indent`,
///     `list-body-indent`, and `list-block-spacing` lengths are also ignored.
///   - `page-footer.format` (Typst numbering pattern/function, `"1"`),
///     `size` (10pt), `weight` (Typst font weight, `"regular"`); ignored.
///   - `line-numbers.enabled` (bool, false), `format` (numbering pattern,
///     `"1"`), `scope` (`"document"` or `"page"`, `"document"`), `size`
///     (8pt), `color` (`#64748B`), `clearance` (`auto` or length, `auto`);
///     ignored.
///   - `links.color`, `url-color` (colors, both `#0563C1`); ignored.
///   - `tables.stroke` (0.5pt), `inset` (length or dictionary, `(x: 8pt,
///     y: 4pt)`), `font-size` (10pt), `caption-position` (`top`/`bottom`,
///     `top`), `caption-gap` (6pt); ignored.
///   - `callouts.inset` (9pt), `radius` (3pt), `stroke` (0.8pt), `title-below`
///     (1em), `paragraph-spacing` (1em), `list-spacing` (1.2em); ignored.
///   - `captions.size` (10pt), `weight` (`"regular"`), `alignment` (Typst
///     alignment, `center`), and `label-weight` (`"regular"`); all are ignored.
///   - `toc.depth` (none or nonnegative integer, `none`), `title` (content or
///     none, `[Table of Contents]`), `indent` (auto or length, `auto`),
///     `entry-size` (10pt), `leading` (0.65em), `entry-above` (0.65em),
///     `main-entry-above` (1.25em), `title-below` (1.5em), `below` (2em);
///     ignored.
///   - `lof` and `lot` use the same fields; defaults are depth none, their
///     English list title, auto indent, 10pt entry size, 0.65em leading,
///     0.85em entry gap, 1.5em title gap, 2em below gap, and `compact: false`.
///     `compact` is bool. These fields are ignored by the cover.
///   - `bibliography.style` (CSL style name, `"apa"`); ignored.
///   - `colors.bg-paper`, `bg-subtle`, `brand-primary`, `brand-accent`,
///     `text-main`, `text-muted` (colors; neutral defaults white/white/black/
///     black/black/black; **used**). `bg-subtle` is accepted but ignored; the
///     other five color fields style the cover.
///   Unknown keys inside known shared groups are rejected. Additional
///   template-specific or caller extension groups are accepted and ignored.
/// -> content: a generated minimal title page
#let minimal-cover = cover-page.with(layout: "minimal")
