#import "cover.typ": cover-themes
#import "defaults.typ": merge

/// Built-in palettes for document pages. Available names are `neutral`,
/// `soft-jade`, `soft-slate`, `warm-editorial`, `plum`, and `soft-rose`.
/// `neutral` is strictly grayscale; the other palettes use muted jade, slate,
/// warm brown, plum, and rose accents. Use `theme-config(name)` to apply one.
#let document-themes = cover-themes.pairs().map(((name, colors)) => (
  name,
  if name == "neutral" {
    (
      bg-paper: white,
      bg-subtle: white,
      brand-primary: black,
      brand-accent: black,
      text-main: black,
      text-muted: black,
    )
  } else {
    (: ..colors, bg-paper: white, bg-subtle: colors.brand-primary.lighten(94%))
  },
)).to-dict()

/// Select a document palette for any Satz template accepting `config`.
/// `name` must be `neutral`, `soft-jade`, `soft-slate`, `warm-editorial`,
/// `plum`, or `soft-rose`; pass `none` to retain the template defaults.
/// Explicit nested config overrides win over the selected palette.
///
/// ```typst
/// #let config = theme-config("soft-jade", config: (typography: (size: 11pt)))
/// ```
#let theme-config(name, config: (:)) = {
  if name == none { return config }
  let colors = document-themes.at(name, default: none)
  assert(colors != none, message: "Unknown document theme: " + repr(name) + ". See document-themes for available palettes.")
  merge((
    colors: colors,
    links: (color: colors.brand-primary, url-color: colors.brand-primary),
  ), config)
}
