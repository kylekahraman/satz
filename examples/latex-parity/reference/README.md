# DFG LaTeX reference

`proposal.cls` is an **unmodified** copy from
[emtpb/proposal_dfg](https://github.com/emtpb/proposal_dfg/blob/40732cd6b528eb732e91e8e6411a1fc7a21f87b8/proposal.cls),
commit `40732cd6b528eb732e91e8e6411a1fc7a21f87b8`.
Its upstream Unlicense is preserved in `LICENSE`. It is a test reference,
not a runtime dependency of Satz.

The paired specimens explicitly select Arial, the official margins and header
revision 09/26. TeX's nominal 11pt class actually selects 10.95 TeX points;
the specimens normalize that to **11 physical PDF points**, keeping its
13.6 TeX-point baseline. They retain the class's heading skips, list setup,
paragraph skips and microtype. This normalization is necessary to compare
spacing at the same font size while retaining the DFG 11pt minimum.

Run `python3 examples/latex-parity/check_proposal_rhythm.py --output /tmp/satz-dfg-comparison`.
The test compiles the independent LaTeX reference and public Typst wrappers,
then compares every text row's vertical bounds (tolerance 0.02pt), header
alignment, rule position, hanging indent and page count. It checks four heading
levels, stacked headings, wrapped headings and a page-start heading.
Text justification, protrusion, font expansion, hyphenation and arbitrary float
pagination can differ between engines; this is **measured layout parity of the
specimens**, not pixel identity for arbitrary manuscripts.
