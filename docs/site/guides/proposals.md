---
title: "Choose and build a research proposal"
---

Start by matching the template to the call you are preparing. Satz supplies layout structures and planning components; it cannot decide which scheme applies or verify that a proposal meets every funder instruction. The proposal templates below are candidate features from the 0.2.0 source and require [development setup](/satz/guides/development/).

## Choose a template

| Use this when | Entry point | What the candidate covers |
| --- | --- | --- |
| You are preparing a DFG research grant | [`dfg-proposal`](/satz/reference/api/#dfg-proposal) | Form 53.01, revision 09/26, with English and German starters and separate page-budget checks for description and supplementary material. |
| You are preparing an NWO Talent Programme application | [`nwo-proposal`](/satz/reference/api/#nwo-proposal) | Source-checked 2026 profiles only. Supported scheme, domain, and stage combinations vary. |
| You need a flexible project or research plan | [`research-proposal`](/satz/reference/api/#research-proposal) | General proposal structure, with optional budget, work package, and timeline components. |

The [template index](/satz/reference/templates/) separates development templates from those available in the published package.

## Before you write

1. Read the funder's current call text and identify the exact scheme, stage, year, language, and page limit.
2. Check that the selected candidate profile matches all of those values. For NWO, do not infer support from a similar scheme name: the combination must be present in the documented coverage.
3. Create a source-based project using [Development versions](/satz/guides/development/), then copy the matching starter from the repository documentation.
4. Keep scientific content in the document body and use the helpers only for structure, formatting, and planning data.
5. Compile and inspect the complete PDF, including page counts, headings, tables, and references.

## Add planning information

The general proposal components can represent budget items, work packages, milestones, and a Gantt-style timeline. See the [proposal planning guide](https://github.com/kylekahraman/satz/blob/main/docs/proposal-planning.md) for the record shapes and complete examples. Use the [`proposal-budget`](/satz/reference/api/#proposal-budget), [`work-package`](/satz/reference/api/#work-package), and [`proposal-gantt`](/satz/reference/api/#proposal-gantt) API entries to check the exact arguments.

Proposal-specific citation helpers are documented as [`proposal-citations`](/satz/reference/api/#proposal-citations) and [`proposal-publications`](/satz/reference/api/#proposal-publications). For these, bibliography keys need to exist in the supplied BibTeX source. Follow the cited source guide for each template rather than assuming that DFG, NWO, and general proposals use identical fields.

## Coverage and limitations

- [DFG proposal guide and starter notes](https://github.com/kylekahraman/satz/blob/main/docs/proposals.md)
- [NWO profile combinations and source references](https://github.com/kylekahraman/satz/blob/main/docs/nwo-proposals.md)
- [Planning components](https://github.com/kylekahraman/satz/blob/main/docs/proposal-planning.md)

The NWO candidate does not cover every NWO form. The source-checked profiles cover Veni/Vidi pre-proposals across four domains, Vici pre-proposals in Science, SSH, and AES, and full Vici across four domains. Full Veni/Vidi and the unavailable ZonMw Vici pre-proposal are not represented. The DFG implementation targets form 53.01 (09/26); it is not a universal DFG form generator. Confirm your exact call's rules before submission and manually review the output against those rules.
