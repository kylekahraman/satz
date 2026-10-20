# Research report parity audit — 20 October 2026

**Status: useful improvements, not 1:1 parity.** This comparison concerns the
71-page decoding/RSA research report in ncwm-dcm: LaTeX `scrreprt`, STIX text
and maths in the Typst port. It is distinct from the Georgia maths workbook
used for the experimental `book` API in [the book review](book-workbook-parity.md).
Research content, PDFs and participant data remain outside this repository.

## Fixes incorporated into Satz

| Behavior | Shared implementation | Real-document evidence |
| --- | --- | --- |
| Heading before-spacing | Native show-set rules; `h1-above` through `h4-above`, omitted for `auto` | Section/subsection gaps calibrated against LaTeX; 21 same-page heading grouping checks pass. |
| Callout paragraph/code rhythm | Public `callout`, inherited body leading, separate paragraph/list spacing, code line-height safeguard | All 14 callouts use it; 16 page fragments stay within the text area. Replacing the corrected local implementation produced identical rendered pixels on all 71 pages. |
| Scientific table rules | Public `scientific-table`, native header/footer rules and repeated headings | Applied to all 20 main-text tables; 45 appendix tables retain existing rules. All 19 changed pages compared with LaTeX. |
| Table configuration | `tables.font-size` and `tables.inset` honored by the document class | Focused PDF checks verify actual font sizes, padding and local overrides. |

The oversized results table continues across physical pages 46–47, repeats its
column headings and contains all 35 mean/SEM rows. Rules and repeated headings
are checked on every fragment of a separate 60-row regression fixture, including
a spanning cell. The workbook's ordinary leading, heading grouping, callout
bounds and folios still pass after the table changes. Neither these checks nor
the matching 71-page counts prove complete conversion accuracy.

## Document settings that should not become universal defaults

- STIX font choices, the KOMA reference's page geometry and its chapter sizes.
- The particular section/subsection above/below values in the
  [typography guide](typography.md).
- Blue/yellow callout colors, 9pt code and 9pt table text.
- Hidden folios on four front-matter pages, then visible body numbering from 1.
- The decision to make the long table's enclosing figure breakable. A breakable
  native table cannot escape an enclosing unbreakable figure.

The report carries a vendored snapshot. Only the relevant shared files have
been synchronized; it is not identical to the package working tree. In
particular, ongoing outline/theme/list work must be evaluated before adopting
it. Otherwise a stale vendored class can silently ignore a new config key.

## Remaining differences, in priority order

| Priority | Difference observed against LaTeX | Next action / owner |
| --- | --- | --- |
| 1 | Converted tables 9.1/9.2 have empty Verdict cells where LaTeX contains Positive/Null labels. Other source verdict macros also need a prose audit. | Restore source macros in the conversion and verify every occurrence. This is a document-content loss, not table styling. |
| 1 | Related test/CI tables are often separate numbered figures in Typst where LaTeX groups them under one caption. | Restore the intended grouping and references; test long grouped tables without overflowing. |
| 1 | Captions are generally below the main-text tables in the port; the source places them above. Several converted captions are repeated across related tables. | Reconcile caption placement, shared captions and table numbering before tuning fine spacing. |
| 2 | Many short tables use intrinsic width in Typst while LaTeX stretches them across the text width. Dense tables wrap headings and labels differently. | Choose explicit column widths per table family, keeping numeric values readable; consider decimal/uncertainty alignment packages only after a focused trial. |
| 2 | Row groups rely on labels/empty cells; the source also uses deliberate extra group spacing. | Restore meaningful group separation; the helper already permits native `table.hline` separators. |
| 2 | Figure placement and page distribution differ substantially. Equal page counts hide different content per page. | Compare by figure/section identity, not physical page number alone; evaluate float policies on a representative chapter. |
| 2 | Some diagram assets remain pre-rendered PDFs and the source typography differs from body text. | Decide which diagrams merit native reconstruction; preserve vector output and legible labels. |
| 2 | Formula numbering differs: the port numbers a displayed callout formula as 8.1 where the LaTeX reference is unnumbered. | Audit numbered versus unnumbered equations and cross-references before changing the shared numbering API. |
| 2 | Callout titles still differ in color/weight treatment from LaTeX. | Agree a reusable title treatment after inspecting short and split callouts; do not solve it with arbitrary paragraph spacers. |
| 3 | Cover, contents typography/wrapping and chapter openings still differ. | Review final integrated outline changes against the source and retain easy user configuration. |
| 3 | Journal consumers and two-column scientific layouts do not have equivalent coverage to this report. | Verify journal rhythm and mixed-width floats separately before claiming general document parity. |

The page comparisons show a safer, more legible port, not identical text
distribution. Missing macros must take precedence over cosmetic refinements.
Do not silently infer scientific verdicts from a p-value: copy the source's
actual labels, including any inconsistencies, and flag discrepancies separately.

## Dependencies and scope

The source's scientific-table rules come from `booktabs`; explanatory boxes and
math support also belong to the wider LaTeX ecosystem, not `scrreprt` alone.
Native Typst provides the rules, repeatable headers/footers and breakable blocks
needed for the fixes above, so these do not need another dependency. Hydra and
Glossarium already address separate concerns. Subfigure work remains shelved.

## Repeatable checks

```sh
python3 examples/latex-parity/check_typography.py
python3 examples/latex-parity/check_callouts.py
python3 examples/latex-parity/check_tables.py
python3 examples/latex-parity/check_scientific_tables.py
typst compile --root . examples/scientific-table.typ /tmp/scientific-table.pdf
```

Report and journal example consumers were also compiled against an isolated
committed checkout, substituting their published-package imports with the
checkout's `lib.typ` for the check. Compiling an example's unchanged
`@preview/satz:0.1.1` import alone tests the published package, not these fixes.
The report example requests unavailable EB Garamond on this host and falls back;
the actual research report uses installed STIX fonts for visual comparison.

The real report stores sources, output and layout-review backups together under
its permanent `typst/` directory. Its saved review script checks 14 callouts,
16 fragments, 21 heading gaps, body baseline candidates, front/body folios and
the 35-row long table. Review images and PDFs stay outside Git. No version bump,
tag, release or package publication accompanies this work.
