# First LaTeX reference recreations

These are first iterations through the current public satz API, with explicit
local workarounds. They establish comparison fixtures; they do not claim full
LaTeX parity. No shared rendering defaults or runtime dependencies changed.

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

```sh
python3 examples/latex-parity/build_report.py
```

Requires `pdflatex`, Typst, and PyMuPDF. The command compiles our own TeX source
twice with shell escape disabled, compiles the Typst document and override
variants, checks all twelve physical pages, and renders page PNGs under
`output/`. `header-report.pdf` is the LaTeX reference;
`header-report-satz.pdf` is the Typst result. Assertions cover chapter-opening
suppression, section changes, chapter fallback, an unnumbered chapter, page
numbers/alignment, a same-parity counter reset, custom headers/footers, disabled
headers, and one-sided layout. Internal links and page markers are also checked.
The table and diagram exercise simple top floats and cross-references; this is
not comprehensive float-placement or bibliography coverage.

Before the header fix, the script reproduces five wrong header strings in the
satz version: old section on page 3, nonempty opening pages 5 and 10, stale section
on page 7, and stale section after the unnumbered chapter on page 11. The
configured LaTeX reference and the override variants pass.

Next: remove the inline article title/contents/numbering workarounds through a
small supported article mode, and expand the report with bibliography and
automatic pagination cases.
