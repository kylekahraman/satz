# Typography, letter coverage, and authoring priorities

## Assessment

Satz should make ordinary writing quick and produce a coherent document without
requiring authors to tune each heading. Current comparisons establish selected
behaviors, not complete KOMA-Script parity. The next core task is heading and
paragraph rhythm, followed by a richer letter comparison and simpler document
entry points. Further template-file/interface work is deferred for discussion.

## Dependency opportunities

| Roadmap item | Candidate | Current decision |
|---|---|---|
| Running headers | Hydra | Integrated and checked against a configured 12-page KOMA-Script fixture. |
| Abbreviations/glossary | Glossarium | Integrated as an optional namespace; five-page example checks first/repeated use, links, unused terms, and coexistence with figures/captions. |
| API manual | Tidy | Next small tooling trial; adapt doc-comment syntax and generate a manual. Keep it outside ordinary document compilation. |
| Scientific tables | Zero, optionally Pillar | Useful trial, not a complete table-design solution. Compare decimal/uncertainty alignment and authoring effort before exposing a supported interface. |
| Margin notes | Marginalia | Relevant to the commentary reference, but test collisions, binding, and page breaks before promising support. |
| Page proportions | Tschich | Opt-in layout candidate, not a substitute for coordinated heading/paragraph spacing or KOMA type-area calculations. |
| Figures and technical diagrams | Subpar, Fletcher | Useful when the next reference needs subfigures or repeated diagram work; not required for basic figures. |
| Ordinary heading spacing | Native Typst | No new package needed to start. Satz needs to coordinate the controls it already uses. |

Versions, licenses, and source links are in the
[initial review](package-research.md) and [additional review](additional-packages.md).
The broader package survey is complete; each integration is a separate task.

## Heading and paragraph rhythm: next core increment

In `class.typ`, level-one headings have both an outer block and an internal
`v(0.5em)`; all four levels wrap the native heading. Below-spacing is configurable,
while paragraph spacing/indentation are inherited rather than exposed in the
shared config. Above-spacing options were deliberately removed in `97f7809`.
These are design facts, not proof that every current gap is wrong.

Typst has native [paragraph leading/spacing](https://typst.app/docs/reference/model/par/)
and [block above/below spacing and stickiness](https://typst.app/docs/reference/layout/block/).
Adjacent block gaps collapse; leading is not a LaTeX baseline multiplier. A
package cannot pick a coherent document rhythm for us without design choices.

Build one compact paired specimen containing all four heading levels, ordinary
paragraphs, two consecutive headings, a multiline heading, a list and equation
after headings, and headings near a page boundary. Compare current satz, plain
Typst, and KOMA-Script using comparable fonts and content. Measure baseline and
heading/body distances where useful, then refine the native heading styling.

Acceptance criteria:

- Headings stay attached to following content and do not leave an isolated
  heading at a page bottom.
- Page starts, consecutive headings, and multiline headings retain a clear
  hierarchy without accidental extra gaps.
- Paragraph separation, first-line indentation, and heading spacing work as one
  policy; do not merely add more independent knobs.
- Ordinary authoring needs no manual `v()` calls. Preserve existing overrides
  where practical and document any intentional default changes.
- Recompile the report, journal, and letter consumers and inspect their pages.
  Keep the Hydra checks green while changing heading layout.

## What the letter comparison establishes

| Capability | Current evidence |
|---|---|
| Basic one-page letter | Recreated one official `scrlttr2` source/PDF with public configuration plus a local date workaround. |
| Sender/recipient, subject, contact fields, reference fields | Implemented in the template; not comprehensively compared against KOMA letter examples. |
| Language and postal/digital switches | German/English labels and low-level visibility switches exist. Digital setup currently requires several options. |
| Named enclosures | A missing implementation was reproduced and fixed: `anlagenverzeichnis` now prints without attempting to open its strings as files. |
| Date and address typography | Differences remain: full-size unlabeled date needs a workaround, recipient text is fixed at 11pt, and address/body horizontal offsets differ. |
| Physical envelope geometry | Not validated. Flowing sender content and gaps influence address position; source comments and a visually similar page do not establish envelope fit. |
| Multi-page continuation | A page-number footer exists, but a rich two-page comparison and a deliberate continuation-page layout remain unverified. |
| Closing/signature | A signature-line helper exists. A unified closing/signature block that reliably stays together across page breaks has not been demonstrated. |
| Broader correspondence | Copy-recipient/PS helpers, reusable letterhead profiles, and alternate postal layouts are not established by the current comparison. |

Do not describe the current letter as a complete `scrlttr2` replacement or
claim verified DIN compliance. Next, adapt a richer official letter with
reference fields and enclosures, then extend it to two pages. Test the everyday
workflow before deciding which extra KOMA features are useful to support.

## Usability target

The README now contains a complete one-file letter. Users already need only an
import, a show rule with their details, and their text; they do not need to copy
the implementation or maintain a separate config file. That is the current
starting point, not the finished interface.

For the next letter API pass, test two short tasks: write a postal letter and
write a digital letter. Count required options and remove unnecessary decisions.
Keep advanced layout controls available without making them part of the quick
start. The English `letter` alias still accepts German field names; resolve
that inconsistency deliberately while preserving existing documents. Opening,
closing, signatures, and reusable sender details deserve a coherent interface
rather than a longer starter file. Defer a new scaffolder or template system
until that interface discussion.
