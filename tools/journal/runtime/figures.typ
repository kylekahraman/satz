// Small figure-authoring components shared by reports and journals.
#import "defaults.typ": defaults, merge

/// An empty labeled box for a figure that has not been drawn yet.
///
/// Use inside `figure` or `satz-figure` for a caption, numbering, and references.
/// The box itself does not create a figure or a List of Figures entry.
///
/// - width (relative): box width, defaults to the available width
/// - height (length): box height, defaults to 4cm
/// - label (content, str): centered text, defaults to "Placeholder"
/// - config (dictionary): optional satz color/caption-style overrides
///
/// ```example
/// #figure(
///   placeholder(width: 80%, height: 4cm, label: [Planned result plot]),
///   caption: [Results will be inserted here.],
/// ) <fig:planned>
/// ```
#let placeholder(width: 100%, height: 4cm, label: [Placeholder], config: (:)) = {
  let c = merge(defaults, config)
  rect(
    width: width,
    height: height,
    inset: 8pt,
    fill: c.colors.bg-subtle,
    stroke: (paint: c.colors.text-muted, thickness: 0.5pt, dash: "dashed"),
    align(center + horizon, text(size: c.captions.size, fill: c.colors.brand-primary, label)),
  )
}
