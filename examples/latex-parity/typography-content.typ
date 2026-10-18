// Original report typography specimen, MIT, satz contributors (2026).
#let specimen = [
  = A report with a consistent rhythm

  A report should let the reader follow an argument without noticing its layout.
  This specimen uses ordinary prose, four heading levels, and common transitions.
  The author does not insert vertical spacing to make individual sections fit.

  A second paragraph makes the distinction between line spacing and paragraph
  spacing visible. Both paragraphs should form a readable block, with enough
  separation to show where the next thought begins.

  == A section followed by ordinary text

  The heading belongs to this paragraph. Its spacing should be controlled once,
  and should behave in the same way when the section moves to another page.

  === A smaller heading

  Lower levels retain a clear hierarchy without overwhelming the prose.

  ==== A fourth-level heading

  This remains a block heading rather than running into the paragraph.

  == A deliberately long section heading that wraps onto a second line and still stays attached to the text that explains it

  Both lines of the heading belong together. The gap below the final line should
  follow the same rule as the gap below a short heading.

  = Consecutive headings
  == A subsection immediately follows

  There is no intervening prose here. The headings should read as one hierarchy,
  rather than as unrelated blocks with independently accumulated blank space.

  == A heading followed by a list

  - First inspect the hierarchy.
  - Then inspect the transitions.
  - Finally inspect the page breaks.

  == A heading followed by an equation

  $ y = a x + b $

  The same spacing policy also needs to work when the following content is a
  displayed equation. No special adjustment is made for this one location.
]
