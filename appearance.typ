#import "defaults.typ": merge
#import "themes.typ": theme-config

// The postal templates share palette and core typography controls while
// retaining their own page geometry and rendering.
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
