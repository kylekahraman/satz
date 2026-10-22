# First LaTeX reference recreations

These are first iterations through the current public satz API, with explicit
local workarounds. They establish comparison fixtures; they do not claim full
LaTeX parity. The report comparison below subsequently drove a Hydra integration
in the shared class; the original one-page examples retain their rendering.

## Original source and compiled PDFs

Both originals come from Markus Kohm's official
[KOMA-Script sixth-edition examples](https://ctan.org/tex-archive/info/examples/KOMA-Script-6),
version 2018-03-12. The
[complete archive](https://mirrors.ctan.org/info/examples/KOMA-Script-6.zip)
contains the source files and the already compiled reference PDFs.

| Recreation | Original `.tex` inside `KOMA-Script-6/` | Published PDF inside `KOMA-Script-6/` |
|---|---|---|
| `koma-letter.typ` | `Kapitel-4/source/letter-1.tex` | `Kapitel-4/result/letter-1.pdf` |
| `koma-commentary.typ` | `Kapitel-19/source/scrlayer-notecolumn-example.tex` | `Kapitel-19/result/scrlayer-notecolumn-example.pdf` |

After fetching, open the local originals: letter
[TeX](upstream/KOMA-Script-6/Kapitel-4/source/letter-1.tex) /
[PDF](upstream/KOMA-Script-6/Kapitel-4/result/letter-1.pdf), and commentary
[TeX](upstream/KOMA-Script-6/Kapitel-19/source/scrlayer-notecolumn-example.tex) /
[PDF](upstream/KOMA-Script-6/Kapitel-19/result/scrlayer-notecolumn-example.pdf).

The original examples use fictitious correspondents and an invented law.
The article's displayed author is part of that fictional example.

The Typst adaptations are renamed derived works maintained by the satz
contributors. Original copyright: Markus Kohm, 2008 for the letter and
2013–2017 for the commentary. These adaptations are distributed under LPPL 1.3c
(letter: or later), rather than the repository's general MIT license. The
unchanged license is included as `LPPL-1.3c.txt`. The complete original work
remains available through the archive above and is preserved locally by the
fetch command. Original TeX files are never overwritten or executed.

Changes: translated TeX markup to Typst; substituted New Computer Modern and
Libertinus Sans for the original fonts; expressed geometry through satz config;
implemented title/contents/notes locally where satz lacks a direct facility.
The letter date is fixed to the date in its published PDF, since its TeX source
uses the compilation date. The source wording, including typos, is preserved.

## Reproduce

From the repository root, with Typst, curl, and Python's `pymupdf` installed
(verified with Typst 0.15.0 and PyMuPDF 1.26.5):

```sh
python3 examples/latex-parity/build.py --fetch
```

Subsequent offline builds:

```sh
python3 examples/latex-parity/build.py
```

The fetch checks the complete archive's SHA-256 before extracting. If CTAN
changes it, review the replacement before updating the checksum. Reference
sources/PDFs live under `upstream/KOMA-Script-6/`; recreations, page previews, and
`checks.json` live under `output/`. Both folders are ignored in Git, and this
comparison collection is excluded from the published Typst package.

Build checks cover successful compilation, one-page output for each pair,
representative content, normalized alphanumeric character inventories, and text
inside page bounds. Character inventories check content coverage, not reading
order or spelling in isolation. PNGs support human layout review; a successful
build alone does not establish typographic equivalence.

## First visual comparison

Both recreations were rendered and inspected alongside the published originals.
Both preserve the one-page structure and all normalized alphanumeric content.
The commentary's inline contents has two working internal links, and its footer
displays page 1. Remaining differences are intentionally recorded:

| Area | Current recreation and next improvement |
|---|---|
| Letter date | Suppress the satz date block and manually emit a full-size, unlabeled date. A supported date style would remove this workaround. |
| Address/body alignment | The source recipient starts 6.25mm left of the body. Satz currently places them at the same left edge; its fixed 11pt recipient text also differs from the source's 12pt. |
| Letter spacing | Body leading is close after calibration; salutation/closing gaps and fold-mark lengths still differ. |
| Inline article title | Title, author, date, and their gaps are composed locally. An article entry point should provide these defaults. |
| Contents | Suppress the report front matter and insert `outline` inline. Satz's outline uses a different type style, dot leaders, and tighter entry spacing than this reference. |
| Paragraph/heading rhythm | Paragraph settings are local. Heading wrappers and contents spacing put body headings higher than in the reference; review as a coordinated article preset rather than adding arbitrary vertical gaps. |
| Numbering | Override report numbering and restore the automatic footer. An article should start at 1 without needing to understand the report's offset. |
| Commentary notes | A two-row grid reproduces the finite content, but cannot replace flowing, collision-aware margin notes. Trial Marginalia against a longer example before promising that behavior. |

## Multi-page running-header comparison

`header-report.tex` and `header-report.typ` are original MIT-licensed fixtures,
not downloaded examples. They contain the same fictional report material and
explicit page breaks. The LaTeX version uses KOMA-Script `scrreprt` and
`scrlayer-scrpage`, configured to match satz's intended header policy, including
chapter fallback and the existing page-number offset. This is a behavioral
comparison, not an assertion that their typography or default settings match.
The reference explicitly uses `\rightbotmark` for the last section on a page;
KOMA-Script's usual `\rightmark` would use the first section mark instead.

```sh
python3 examples/latex-parity/build_report.py
```

Requires `pdflatex`, Typst, and PyMuPDF. The command compiles our own TeX source
twice with shell escape disabled, compiles the Typst document and override
variants, checks all twelve physical pages, and renders page PNGs under
`output/`. `header-report.pdf` is the LaTeX reference;
`header-report-satz.pdf` is the Typst result. Assertions cover chapter-opening
suppression, section changes (including two sections on one page), chapter fallback, an unnumbered chapter, page
numbers/alignment, a same-parity counter reset, custom headers/footers, disabled
headers, non-outlined local headings, and one-sided layout. Internal links and
page markers are also checked.
The table and diagram exercise simple top floats and cross-references; this is
not comprehensive float-placement or bibliography coverage.

Before the header fix, the script reproduces five wrong header strings in the
satz version: old section on page 3, nonempty opening pages 5 and 10, stale section
on page 7, and stale section after the unnumbered chapter on page 11. The
configured LaTeX reference and the override variants pass.

After integrating Hydra 0.6.3 into `class.typ`, all cases pass. Chapter-opening
suppression is explicit rather than relying on a heading's top-margin position;
last-on-page heading selection comes from Hydra. Including chapter headings in
the section-side selector gives a fresh fallback at every chapter. `outlined:
false` headings are excluded, so TOC titles and local non-outline headings do not
become running heads. The original letter, commentary, and a five-page consuming
journal were also recompiled: their rendered page hashes match the pre-fix
versions. Header tests are behavioral; they do not establish identical LaTeX
line breaking or page design.

## Heading and paragraph typography

`typography.typ`, `typography-content.typ`, and `typography.tex` are original
MIT-licensed specimens. They show all four configured heading levels, paragraphs,
consecutive headings, a wrapped heading, a list, and an equation. The KOMA
reference uses `scrartcl` with half-line paragraph separation and a block-style
fourth-level heading. Font metrics and page counts can differ; it supplies a
visual reference rather than an exact spacing target.

```sh
python3 examples/latex-parity/check_typography.py
```

The script produces `output/typography-report.pdf`, an equivalent native Typst
control, and `output/typography.pdf` from LaTeX. It checks native heading geometry,
multiline/consecutive headings, eight small-page attachment cases, and the
geometry of paragraph spacing and indentation overrides. Before the change,
the level-one heading had an extra 7pt page-start offset, and the paragraph
config keys were ignored. The page-edge probes already passed; no orphan-heading
bug was established.

The shared class now uses native heading styling and roomier below-spacing.
Paragraph defaults retain the prior native behavior, with explicit config keys.
Journal titles retain their small-caps presentation. The existing five-page
journal example was compiled through local satz and visually inspected, along
with the report and prior reference examples. These are intentional typography
changes and may reflow documents; old `em` below-spacing values now resolve in
the native heading context.

## Draft figure placeholders

`examples/placeholders.typ` demonstrates the public `placeholder()` helper in a
normal figure and in `satz-figure`. Run
`python3 examples/latex-parity/check_placeholders.py` to compile the example and
check label centering, physical dimensions, figure references, short/long
captions, and the List of Figures. The helper draws a native rectangle and label;
it does not create a nested figure or require a package.

Next: improve general report structure and title/contents authoring, and extend
the report with bibliography and automatic pagination cases. Reports and
journals take priority over further letter parity work.

## Article layout checks

Run `python3 examples/latex-parity/check_article.py` from the repository root.
This compiles the public article example and checks column/figure widths,
footnotes, cross-references, numbering, single-column/inline-contents options,
full-width report contents, and author affiliation validation. The example uses
an explicit page break before the wide float to preserve figure order.

## Outline and list checks

Run `python3 examples/latex-parity/check_outlines.py`. The public specimen is
`examples/outline.typ`; compile it with `--input compact=true` for caption-free
figure/table lists. The checks cover section numbers, wrapped entry indents,
title/row/section spacing, neutral outline links, captioned tables, custom
figure/table numbering, Roman page numbers, independently enabled lists, empty
and excluded lists, bullet/numbered item spacing, and theme overrides. Temporary
PDFs are removed after checking. Report page parity is checked separately by
`build_report.py`, using painted glyph positions to handle PDF ActualText spans.
