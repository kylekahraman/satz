# Research and grant proposals

The development version of Satz provides a DFG 53.01 project-description layout
and a separate general research/project proposal layout. Both use the shared
`personal()` class and deep configuration merge. These changes are unreleased;
the package manifest remains 0.1.1.

## DFG 53.01: start with the complete form

Copy [the English starter](../dfg-proposal/example.typ) or
[the German starter](../dfg-proposal/example-de.typ). Each contains all five
sections and the nested headings from the official **09/26** form, including
fourth-level safety and funding headings. Replace the relative import with your
installed development package import when using the file outside this repo:

```typst
#import "@local/satz:0.1.1": dfg-proposal, dfg-supplement, dfg-publications, proposal-budget
#show: dfg-proposal.with(
  applicant: [Example Applicant, Example University, Example City],
  project: [Project title],
  language: "english", // or "german"
)

= Starting Point
*State of the art and preliminary work*
Your text.

= Objectives and work programme
// Keep all subsections from the complete starter.

= Project- and subject-related list of publications
// #dfg-publications("references.bib", size: 9pt)

#dfg-supplement()
= Supplementary information on the research context
// Keep all subsections from the complete starter.

= Requested modules
// Keep all subsections from the complete starter.
```

Use ordinary headings without typing section numbers. The shared heading
counter supplies `1`, `2.1`, `4.1.4.1` and `5.1.3.2`. For additional text headings
inside a prescribed section, use bold text or
`#heading(numbering: none, outlined: false)[Your heading]` so the form's numbers
remain intact. In particular, “State of the art and preliminary work” is an
unnumbered prompt, not section 1.1.

Insert `dfg-supplement()` **exactly once, immediately before section 4**.
It starts a fresh page and resets the page counter to 1 while heading numbering
continues. Headers display `page N of max. 17` for the first part and
`page N of max. 8` for the second part, localized in German. The header uses
physical page locations relative to the part boundary: a page-start header
cannot accidentally read the counter before the body's reset. Do not add manual
page-counter resets. Ordinary `pagebreak()` calls are supported.

The first part is limited to 17 pages and the second to 8. Compilation fails
when a limit is exceeded. Pass `check-pages: false` for an overlength working
draft; the header still displays the applicable limit. The legacy `max-pages`
argument changes the first-part allowance only; keep its default for DFG 53.01.
A document containing only the research part can omit `dfg-supplement()`.

Defaults use A4, Arial 11pt, 25mm left/top, 20mm right and 15mm bottom margins,
black text on white, no cover, no contents, no footer, and 0.5em leading.
Arial must be installed: Typst can otherwise substitute a font and issue a
warning. The regression fixture rejects compiler warnings. Tables and captions
also default to 11pt. Shared `config` overrides remain available, but changing
these values does not imply that the resulting document retains DFG formatting.

`dfg-publications("references.bib", size: 9pt, style: "apa")` renders the
bibliography without adding a second heading. Place it under section 3. Sizes
below 9pt are rejected. Native citation styles and bibliography arguments remain
available, including `full: true`. Cite works in sections 1–2 using ordinary
Typst citations. Automatic highlighting of selected bibliography entries is not
provided; the DFG maximum of ten highlighted own works remains an author check.

## Budgets

The shared `proposal-budget` helper replaces LaTeX's `funds`, `position` and
`positionmul` arithmetic with explicit rows and an exact total:

```typst
#proposal-budget((
  (description: [Research associate], unit-cost: 500000, quantity: 12),
  (description: [Travel], unit-cost: 125000, quantity: 2),
  (description: [Materials], unit-cost: 75000),
), language: "english")
```

Prices are **integer euro cents**: `500000` means €5,000.00. Quantity defaults
to 1 and must be a positive integer. Negative or fractional-cent prices are
rejected. Rows show quantity × price, the subtotal, and the grand total; `language:
"german"` switches labels and the decimal separator. `total-label:` supplies a
custom final label. Totals are local to each table, with no shared mutable state.

## General research/project proposal

Use `research-proposal` or its alias `project-proposal` for a proposal without a
prescribed funder form:

```typst
#import "@local/satz:0.1.1": research-proposal
#show: research-proposal.with(
  title: [A reproducible measurement platform],
  short-title: [Measurement platform],
  applicants: [Dr. Example Author],
  institution: [Example University],
  summary: [The research question, approach and expected contribution.],
)

= Motivation and research question
Your text.

= Objectives
Your text.
```

The title and optional summary appear inline. Pages start at 1 and the header
shows current/total pages throughout. Use `short-title` when the full title is
too long for the header. Optional `date:` accepts content. Shared `config:`
settings control typography, margins and headings; `language: "german"` localizes
the summary and page label. No mandatory section list or page allowance is
imposed. [The complete example](../proposal/example.typ) includes objectives,
work packages, milestones, feasibility, risks, ethics/data, a budget and outputs.

## Sources, verification and scope

Authoritative sources checked on 20 October 2026:

- [DFG 53.01 form page, revision 09/26](https://www.dfg.de/de/formulare-53-01-elan-246768),
  with [English RTF](https://www.dfg.de/resource/blob/168206/53-01-en-elan.rtf)
  and [German RTF](https://www.dfg.de/resource/blob/168204/53-01-de-elan.rtf).
  Heading text and page geometry were checked against both downloaded forms.
- [DFG 54.01 preparation instructions, revision 09/26](https://www.dfg.de/resource/blob/168314/5344518bed1e420aebded6e5b1f3e857/54-01-en-data.pdf):
  17/8-page limits, minimum body/publication text sizes and line spacing.
- [emtpb/proposal_dfg](https://github.com/emtpb/proposal_dfg), the primary LaTeX
  reference: bilingual title/header, four-level numbering, separate page counts,
  bibliography sizing and itemized fund calculations.
- [klb2/dfg-proposal-template](https://github.com/klb2/dfg-proposal-template),
  a secondary feature/layout reference. Satz uses an independent native Typst
  implementation; it does not incorporate that repository's GPL class code.

This implements the **53.01 project-description workflow**, not every form
handled by emtpb's class. Forms 53.02, 53.20 and 53.200, clinical variants,
CVs, optional decorative title pages and LaTeX-specific macros are outside this
implementation. It is not a pixel-for-pixel reproduction of LaTeX or an official
DFG product. Proposal content, required attachments and current call-specific
requirements still need checking before submission.

Run `python3 examples/latex-parity/check_proposals.py` with `typst`, Arial and
`pdfplumber` installed. It checks both complete starters, every header in a
25-page boundary fixture, overflow rejection, draft mode, duplicate part breaks,
fonts/margins, four-level numbering, bibliography sizes, the existing DFG
consumer, the general template, and exact budget arithmetic. Rendered English,
German and general-proposal PDFs are also reviewed visually. Generated PDFs are
not committed. A real invoice consumer also compiled against the package, with
an existing optional-content warning from its PDF logo. A legacy journal's
cover call uses an incompatible older API, so its full-document check could
not complete; that consumer was left unchanged. The focused proposal suite also
passes against a clean staged snapshot without unrelated workspace edits.

## Later: NWO

The supplied [MMMPeeters1981/NWO_LaTeX_Template](https://github.com/MMMPeeters1981/NWO_LaTeX_Template)
is recorded as the starting reference for future NWO work. Its Veni/Vidi/Vici
layout must be checked against the chosen scheme's current official call and
Word form before implementation. No NWO submission layout is exposed yet.
