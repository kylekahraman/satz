#import "defaults.typ": merge

// Shared cover page — a composable layout plus ready-to-use title-page styles.

/// Small, paper-friendly palettes for cover pages.
///
/// Each theme keeps the page light and the main text dark. The accent is used
/// sparingly for rules and the optional research-wave motif.
#let cover-themes = (
  neutral: (
    bg-paper: rgb("#FFFFFF"),
    brand-primary: rgb("#202124"),
    brand-accent: rgb("#9AA0A6"),
    text-main: rgb("#202124"),
    text-muted: rgb("#5F6368"),
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

/// Defaults for the cover page.
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

/// Draw a restrained neural-signal motif for the research cover.
#let research-wave(color) = {
  curve(
    stroke: (paint: color, thickness: 1pt, cap: "round", join: "round"),
    curve.move((0pt, 18pt)),
    curve.cubic((28pt, 18pt), (30pt, 5pt), (56pt, 5pt)),
    curve.cubic((84pt, 5pt), (84pt, 31pt), (112pt, 31pt)),
    curve.cubic((140pt, 31pt), (140pt, 8pt), (168pt, 8pt)),
    curve.cubic((198pt, 8pt), (204pt, 18pt), (232pt, 18pt)),
  )
}

/// Build a cover page, either from custom content or from common title fields.
///
/// The default `classic` layout preserves the original slot-based cover.
/// Set `layout` to `"research"` or `"minimal"` and provide `title` to use a
/// ready-made title page. `theme` can be `"neutral"`, `"soft-jade"`,
/// `"soft-slate"`, `"warm-editorial"`, `"plum"`, or `"soft-rose"`.
///
/// - config (dictionary): page, typography, and color overrides
/// - logos (none, content): optional logos at the top left
/// - body (none, content): custom cover body; overrides generated title content
/// - footer (none, content): custom content at the bottom center
/// - footer-left (none, content): custom content at the bottom left
/// - layout (str): `"classic"`, `"research"`, or `"minimal"`
/// - theme (str): one of the built-in cover themes
/// - title (none, str, content): title for a ready-made cover; use `box` to keep a word together
/// - subtitle (none, str): optional subtitle
/// - author (none, str): optional author line
/// - date (none, str): optional date line
/// - keywords (none, str): optional keywords line
/// - supervisors (none, array): optional supervisor names
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
        #v(2.6cm)
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

    // The research motif sits in open space below the title and never carries text.
    #if layout == "research" {
      place(bottom + right, dx: -0.2cm, dy: -3.6cm)[
        #research-wave(c.colors.brand-accent)
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

/// A ready-made research notebook cover with a restrained neural-wave motif.
#let research-cover = cover-page.with(layout: "research")

/// A spare, centered title page for reports, notes, and other short documents.
#let minimal-cover = cover-page.with(layout: "minimal")
