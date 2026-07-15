// Shared cover page — handles page setup, logos, centered body, footer.
// Used by journal, report, thesis templates.

/// Default configuration for the cover page component.
///
/// Separate from the main `defaults` because covers often use different
/// styling (white background, different margins, etc.).
#let cover-defaults = (
  page: (
    paper: "a4",
    margin: (top: 2.5cm, bottom: 2.5cm, left: 2.5cm, right: 2.5cm),
  ),
  typography: (
    font: "Libertinus Serif",
    size: 11pt,
  ),
  colors: (
    bg-paper: rgb("#FFFFFF"),
    brand-primary: rgb("#111110"),
    text-main: rgb("#242422"),
    text-muted: rgb("#5e5e5a"),
  ),
)

/// Shallow merge for cover defaults.
///
/// - base (dictionary): Cover defaults
/// - overrides (dictionary): User overrides
/// -> dictionary
#let merge(base, overrides) = {
  let result = base
  for (k, v) in overrides {
    result.insert(k, v)
  }
  result
}

/// A centered cover page with optional logos and footer.
///
/// Renders a single standalone page (no header, no page numbering).
/// The body is centered vertically and horizontally.
/// Optional elements: top-left logos, bottom-center footer, bottom-left footer.
///
/// - config (dictionary): Overrides for cover defaults
/// - logos (none, content): Logo(s) placed top-left
/// - body (content): Centered body content (title, author, etc.)
/// - footer (none, content): Footer placed bottom-center
/// - footer-left (none, content): Footer placed bottom-left (e.g. supervisors)
#let cover-page(
  config: (:),
  logos: none,
  body,
  footer: none,
  footer-left: none,
) = {
  let c = merge(cover-defaults, config)

  page(
    paper: c.page.paper,
    fill: c.colors.bg-paper,
    margin: c.page.margin,
    header: none,
    footer: none,
  )[
    #set text(font: c.typography.font, size: c.typography.size, fill: c.colors.text-main)

    // --- Logos top-left ---
    #if logos != none {
      place(top + left)[#logos]
    }

    // --- Centered body (title, author, etc.) ---
    #align(center)[#body]

    // --- Footer bottom-center ---
    #if footer != none {
      place(bottom + center)[#footer]
    }

    // --- Footer bottom-left (e.g., supervisors) ---
    #if footer-left != none {
      place(bottom + left, dy: -1.5cm)[#footer-left]
    }
  ]
}
