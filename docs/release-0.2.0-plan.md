# Satz 0.2.0 release plan

Status: proposed release scope, based on the 22 October 2026 interface audit.
The package remains at 0.1.1. This plan does not authorize a version bump,
Typst Universe submission, or public CLI executable release.

## Product decision

Prepare a coherent document API and accurate reference before building the
multi-template CLI. A beginner starts with one editable Typst file. Splitting
configuration, cover and chapters into files remains optional. The CLI will
create those same documented starters, rather than maintain another set.

## 1. Establish the release candidate

- Review and either finish or deliberately defer the existing uncommitted
  report, outline, list and palette changes. Preserve unrelated document work.
- Reconcile the changelog and roadmap with the implemented journal, proposal,
  heading, theme and documentation work. Mark experimental APIs explicitly.
- Keep the current supported scope explicit: DFG 53.01 (09/26), represented
  NWO 2026 profiles, and experimental book support do not mean every form or
  arbitrary LaTeX parity is supported.
- Record intentional visual-default changes and provide migration examples.

Acceptance: a clean, identified candidate commit with a truthful changelog.

## 2. English interfaces without breaking German documents

`letter` and `invoice` are currently aliases of `brief` and `rechnung`; their
fields are still German. Add English input support to the familiar public
entry points, while continuing to accept existing German calls. Preserve the
German entry points as well.

Normalize both spellings once into one representation before rendering.
Translate nested records too: adding `sender` without English street/address
fields leaves the interface half translated. If a caller supplies both names
for the same field, report a clear conflict instead of silently choosing one.
Do not implement two separate letter or invoice layouts.

Document spelling separately from output language. English field names must
also be usable for German letters. Invoice output is currently hard-coded to
German; English input aliases alone must not be advertised as English invoice
localization. Decide and document that scope explicitly.

Acceptance: old German examples and new English examples compile; equivalent
inputs produce equivalent document content/layout; conflicts identify the field.

## 3. Resolve appearance consistently

Status: implemented in the 0.2.0 development source; focused precedence tests
pass in `examples/latex-parity/check_appearance_precedence.py`.

Separate document content (sender, recipient, title, date, invoice items) from
appearance (`config`, theme, page geometry, typography). Keep specialized DIN
letter geometry and grant-form requirements; they need not use identical layout
implementations to offer a coherent interface.

Adopt and document one precedence policy for appearance:

1. Shared defaults.
2. Template-specific defaults.
3. Selected theme or preset.
4. Explicit direct appearance arguments retained for convenience/compatibility.
5. Explicit nested `config` overrides.

Merge nested dictionaries deeply; replace arrays and scalar values. Resolve
appearance once and make rendering read the resolved values. Fix the observed
book case where raw `accent`/`math-font` arguments can bypass merged config.
Reuse `theme-config` for the shared palette selection; avoid another palette
copy or a second merge implementation.

For letter/invoice, introduce common appearance options through an adapter;
do not force their postal layout into the report renderer. Clearly state which
shared settings each template supports and reject unsupported new options.

Acceptance: minimal overrides retain unrelated defaults, explicit overrides win
consistently, and themes apply predictably across representative templates.

## 4. Configuration reference with actual value contracts

Status: shared `personal(config:)` defaults and candidate value contracts are
drafted in `docs/configuration-reference.md`; template-specific argument and
record contracts remain to be audited.

The current public reference names groups but does not fully describe the
interface. Each public field needs:

- Full key path or function argument.
- Type, including unions such as `none | alignment`.
- Default, with template-specific differences.
- Exhaustive keywords for enums, or representative examples plus a link to the
  native Typst contract for open-ended values.
- Required/optional status; accepted nested record keys and array element shapes.
- Meaning, units, constraints and template scope.
- Effect of `auto`, `none`, omission, and explicit overrides where applicable.
- One compiling example and version availability.

Examples of the level of detail needed for the development API:

| Setting | Type / values | Current default | Meaning |
| --- | --- | --- | --- |
| `typography.size` | Typst length, e.g. `11pt`, `12pt` | `11pt` shared; article overrides | Body text size |
| `typography.leading` | Typst length, e.g. `0.65em`, `8pt` | `0.65em` shared | Space between line bounds, not a LaTeX multiplier |
| `headings.spacing` | `"koma"` or `"native"` | `"koma"` shared | Heading spacing policy |
| `headings.h1-above` | `auto` or Typst length | `auto` shared | Policy-derived gap or explicit override |
| `toc.depth` | `none` or non-negative integer | `none` shared; article overrides to `0` | `0` disables contents; other behavior is template-specific |
| `theme` | `none` or one of six named palettes | Template-specific | Palette selection; availability differs by entry point |

These rows describe development behavior, not a claim that all options exist
in the published 0.1.1 release. Theme names are `neutral`, `soft-jade`,
`soft-slate`, `warm-editorial`, `plum`, and `soft-rose`.

Provide a short, annotated starter config containing only useful overrides, plus
a complete versioned default-config reference. Do not teach users to copy or
merge the complete defaults into their overrides: that freezes inherited values
and can mask future improvements.

Keep executable defaults authoritative. Generate reference tables/default
examples from defaults plus explicit documentation metadata where useful;
default values alone cannot describe enum choices, semantics or constraints.
Validate documentation metadata against the supported fields to detect drift.
A large runtime schema framework is not a prerequisite.

Acceptance: every stable public option has a documented value contract;
versioned examples compile against the version they name.

## 5. Helpful validation, proportionate to compatibility

Validate high-impact values and record shapes at public entry points: palette
names, heading policy, cover layout, proposal language, author/affiliation
records, addresses, and supported journal date formats. Errors should name the
field and explain accepted values.

The generic deep-merge helper currently accepts unknown keys, so a typo such as
`typography.leadng` can be silently unused. Keep `merge` generic. Add validation
at the configuration interface, with a documented compatibility policy for old
configs and extension dictionaries; do not abruptly reject all custom keys.
Do not duplicate upstream Typst validation for every native option.

Acceptance: common malformed inputs produce actionable diagnostics, while
existing supported configurations continue to work.

## 6. Verify the exact package that will ship

- Compile documented starters against both their declared published version
  and the candidate where appropriate. A local `@preview` symlink must not
  substitute development source during a published-package check.
- Automate representative compile checks in CI: report, article, journal,
  letter, invoice, cover and supported proposal starters.
- Retain focused PDF checks for heading flow, wrapped journal headers, counters,
  outlines, selected publications and proposal page limits.
- Compile and inspect real consuming reports and journals; do not require every
  unrelated manuscript conversion to achieve arbitrary pixel parity.
- Inspect the actual distributable file list and compile from a staged package.
  Exclude the CLI, its vendored runtime and binary archives (`tools/**`), local
  workbook conversions, generated build directories and website dependencies.
- Record the source commit/version embedded in a CLI runtime; update it
  deliberately. Its stale snapshot must not ship as a second Typst package.
- Check fresh installation without developer symlinks, links in docs, declared
  minimum Typst version, dependency pins, license and example privacy.

Acceptance: reproducible candidate checks, a clean package, and a migration guide.
Then prepare the version bump/tag/Universe submission as a separate release step.

## After the package release: general Satz CLI

Use one CLI for document creation: proposed commands are `satz new journal`,
`satz new letter`, `satz new report`, and `satz new proposal`. Names remain
proposals until implemented and tested. Keep optional `journal` daily-entry
workflow, multiple named journals and preferred-editor opening in that tool.

Use versioned starters shared with the documentation. Creating a project should
not require creating config/setup/cover/main files manually. Preserve ordinary
Typst ownership: projects remain usable without the CLI. Let users choose
reproducible pinned versions; reserve a live source checkout for explicit
advanced use. Avoid silently changing the package on every launch.

Ship normal versioned Windows/macOS/Linux downloads with checksums and clear
installation instructions. Continue from the existing standalone Go helper;
end users do not need Go or Python installed. Signing and the distribution
experience belong to CLI release work.

## Defer

Do not gate this release on all NWO schemes, a universal renderer, wholesale
internal renaming, a plugin system, a GUI, arbitrary LaTeX pixel parity, or
turning all native Typst options into Satz-specific wrappers.

Top recommendation: resolve the config/alias contract first, document it next,
and build starters/CLI on that stable interface.
