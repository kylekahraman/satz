#import "../../lib.typ": report, chapter-numbering, callout
#show: report.with(config: (
  toc: (depth: 0), lof: (depth: 0), lot: (depth: 0),
  typography: (font: "STIX Two Text", math-font: "STIX Two Math"),
  page: (paper: "a5", margin: 15mm),
))
#chapter-numbering(chapter: 2)[
  = Matching text and mathematics
  Inline mathematics: $theta in {0, pi / 6, pi / 3}$ and a confidence interval
  $[-0.01377, +0.05563]$ keep the same type family as the surrounding text.

  $ W = (X^T X + alpha I)^(-1) X^T Y $ <matrix>

  #callout(title: [A mathematical explanation])[
    The subscripts in $mu_(A,i)$ and $sigma^2$ should remain readable.

    #set math.equation(numbering: none)
    $ d = sqrt((x - mu)^T Sigma^(-1) (x - mu)) $
  ]
  A reference still uses the original equation prefix: @matrix.
]
