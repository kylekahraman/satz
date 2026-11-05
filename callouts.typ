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
/// - config (dictionary): nested overrides merged over Satz's shared defaults.
///   Omitted values retain the defaults listed here. `merge` does not validate
///   keys or values; unknown entries are retained but ignored by this callout.
///   Full shared schema (all keys are nested in their named group):
///   - `page`: `paper` (paper name/custom size; `"a4"`), `margin` (length or
///     edge dictionary, 2.5cm; edges `top`/`bottom`/`left`/`right` plus
///     `inside`/`outside`/`x`/`y`), `binding` (none/left/right; none),
///     `binding-correction` (length; 0pt), `headers` (bool; false), `columns`
///     (positive int; 1), `column-gutter` (length; 5mm). DFG-only
///     `header-ascent` is a length; its DFG default is 24.442pt.
///   - `typography`: `font` (name; Libertinus Serif), `math-font` and
///     `mono-font` (name or auto; auto), `size` (11pt), `line-spacing`
///     (positive baseline multiple or none; none), `leading` (0.65em),
///     `paragraph-spacing` (1.2em), `first-line-indent` (bool; false),
///     `hyphenate` (bool; false), `justify` (bool; true). A set line-spacing
///     overrides leading; true first-line-indent is one em.
///   - `typography.list-spacing` (non-negative number; `0.5`): additional gap
///     between document list items as a fraction of the calculated body
///     baseline distance. It follows `typography.line-spacing` when set, or
///     font metrics and `typography.leading` otherwise; `0` adds no extra gap.
///     This callout uses `callouts.list-spacing` instead, so this field has no
///     effect inside the callout.
///   - `headings`: `numbering` (pattern/function/none; `"1.1"`), `hyphenate`
///     (bool; false), `h1-pagebreak` (bool; false), `spacing` (koma/native;
///     koma), `h1-size`–`h4-size` (14pt/12pt/11pt/11pt), and each level's
///     `*-above`/`*-below` (length/auto; auto). Book-only `h1-number-size` is a
///     length with a 25pt book default.
///   - `journal`: `header-below` (1.5em), `running-gutter` (1em),
///     `running-leading` (0.35em), all lengths.
///   - `decorative`: `header-size` (9pt), `footer-size` (10pt), `date-size` (10pt),
///     `keywords-size` (9pt), plus DFG-only `list-indent` (17.9669pt),
///     `list-body-indent` (5.475 × 72 ÷ 72.27pt), and `list-block-spacing`
///     (measured baseline + paragraph skip - cap height + 3 × 72 ÷ 72.27pt).
///     `list-body-indent` (5.475 × 72 ÷ 72.27pt), and `list-block-spacing`
///     (measured baseline + paragraph skip - cap height + 3 × 72 ÷ 72.27pt)
///     are lengths.
///   - `page-footer`: `format` (numbering pattern/function; `"1"`), `size`
///     (10pt), `weight` (font weight; regular).
///   - `line-numbers`: `enabled` (bool; false), `format` (pattern; `"1"`),
///     `scope` (document/page; document), `size` (8pt), `color` (`#64748B`),
///     `clearance` (length/auto; auto).
///   - `links`: `color` and `url-color` (colors; `#0563C1`).
///   - `tables`: `stroke` (0.5pt), `inset` (length or x/y dictionary;
///     `(x: 8pt, y: 4pt)`), `font-size` (10pt), `caption-position` (top/bottom;
///     top), `caption-gap` (6pt).
///   - `callouts`: `inset` (9pt), `radius` (3pt), `stroke` (0.8pt),
///     `title-below` (1em), `paragraph-spacing` (1em), `list-spacing` (1.2em).
///   - `captions`: `size` (10pt), `weight`/`label-weight` (regular),
///     `alignment` (left), `hanging` (true).
///   - Each of `toc`, `lof`, and `lot`: `depth` (none/non-negative int; none),
///     `title` (content/none; `[Table of Contents]`, `[List of Figures]`, or
///     `[List of Tables]`, respectively),
///     `indent` (length/auto; auto), `entry-size` (10pt), `leading` (0.65em),
///     `entry-above` (0.65em for toc, 0.85em for lof/lot), `title-below` (1.5em),
///     `below` (2em). TOC also has `main-entry-above` (1.25em); LoF/LoT have
///     `compact` (bool; false). `bibliography.style` (CSL name; `"apa"`)
///     selects bibliography style.
///   - `colors`: `bg-paper`, `bg-subtle`, `brand-primary`, `brand-accent`,
///     `text-main`, `text-muted` (colors; shared defaults white, white, black,
///     black, black, black).
///   This function consumes only `colors.bg-subtle`, `colors.brand-primary`,
///   and `callouts.inset`, `radius`, `stroke`, `title-below`,
///   `paragraph-spacing`, `list-spacing`. These control fill, border, padding,
///   corner radius, title gap, paragraph gap, and list-item gap. Other listed
///   DFG/book extension keys and other top-level extension groups are also
///   accepted by this unvalidated merge but do not affect this component.
///   Example: `config: (callouts: (inset: 12pt, list-spacing: 0.6em), colors: (bg-subtle: rgb("#F8FAFC")))`.
/// - fill (color, auto): box fill. `auto` uses `config.colors.bg-subtle`.
/// - stroke (color, dictionary, none, auto): border. `auto` uses
///   `config.colors.brand-primary` with the configured `callouts.stroke`;
///   `none` removes the border; a color or stroke dictionary sets it directly.
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
