#import "cover.typ": cover-themes
#import "defaults.typ": merge

/// The cover palettes adapted for document pages: white paper, subtle panels,
/// dark body text, and optional heading accents. Neutral is strictly grayscale.
#let document-themes = cover-themes.pairs().map(((name, colors)) => (
  name,
  if name == "neutral" {
    (
      bg-paper: white,
      bg-subtle: luma(96%),
      brand-primary: black,
      brand-accent: luma(60%),
      text-main: black,
      text-muted: luma(40%),
    )
  } else {
    (: ..colors, bg-paper: white, bg-subtle: colors.brand-primary.lighten(94%))
  },
)).to-dict()

/// Select a document palette for any Satz template accepting config.
/// Explicit nested config overrides win; none retains the template's defaults.
#let theme-config(name, config: (:)) = {
  if name == none { return config }
  let colors = document-themes.at(name, default: none)
  assert(colors != none, message: "Unknown document theme: " + repr(name) + ". See document-themes for available palettes.")
  merge((
    colors: colors,
    links: (color: colors.brand-primary, url-color: colors.brand-primary),
  ), config)
}
