#import "defaults.typ": defaults, merge

/// Breakable explanatory box that retains the surrounding body line rhythm.
/// Pass the document config to share its palette; fill/stroke can override it.
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
