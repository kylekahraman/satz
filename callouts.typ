#import "defaults.typ": defaults, merge

/// Breakable explanatory box that retains the surrounding body line rhythm.
///
/// ```example
/// #callout(title: [Note])[
///   This paragraph keeps the document's baseline rhythm.
/// ]
/// ```
///
/// - body (content): box content
/// - title (content, none): optional bold heading inside the box
/// - config (dictionary): shared Satz config plus `callouts.*`. For example,
///   set `colors: (bg-subtle: rgb("#F8FAFC"))` to change the automatic fill,
///   or `callouts: (inset: 12pt, radius: 4pt)` for box geometry. Callout
///   defaults are inset 9pt, radius 3pt, 0.8pt stroke, and 1em title gap;
///   shared color defaults are in `defaults.typ`.
/// - fill (color, auto): box fill. `auto` uses `colors.bg-subtle`.
/// - stroke (color, dictionary, none, auto): border. `auto` uses
///   `colors.brand-primary` at `callouts.stroke`; `none` removes it
#let callout(body, title: none, config: (:), fill: auto, stroke: auto) = context {
  let c = merge(defaults, config)
  let style = c.callouts
  set align(left)
  // A line containing only smaller code must keep the body's cap-height.
  let body-top = measure([H]).height
  show raw: set text(top-edge: body-top, bottom-edge: 0pt)
  set text(hyphenate: false)
  set par(justify: false, spacing: style.paragraph-spacing)
  set list(tight: false, spacing: style.list-spacing)
  set enum(tight: false, spacing: style.list-spacing)
  block(
    width: 100%,
    breakable: true,
    inset: style.inset,
    radius: style.radius,
    fill: if fill == auto { c.colors.bg-subtle } else { fill },
    stroke: if stroke == auto {
      (paint: c.colors.brand-primary, thickness: style.stroke)
    } else { stroke },
    {
      if title != none {
        block(sticky: true, below: style.title-below,
          text(weight: "bold", fill: c.colors.brand-primary, title))
      }
      body
    },
  )
}
