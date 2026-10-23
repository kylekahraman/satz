---
title: "Choose and build a research proposal"
---

Start by matching the template to the call you are preparing. Satz supplies layout structures and planning components; it cannot decide which scheme applies or verify that a proposal meets every funder instruction. These tutorials use the Satz 0.2.0 local package; set it up using [the local package guide](/satz/getting-started/setup/).

## Choose a template

| Use this when | Entry point | What the candidate covers |
| --- | --- | --- |
| You are preparing a DFG research grant | [`dfg-proposal`](/satz/reference/api/#dfg-proposal) | Form 53.01, revision 09/26, with English and German starters and separate page-budget checks for description and supplementary material. |
| You are preparing an NWO Talent Programme application | [`nwo-proposal`](/satz/reference/api/#nwo-proposal) | Source-checked 2026 profiles only. Supported scheme, domain, and stage combinations vary. |
| You need a flexible project or research plan | [`research-proposal`](/satz/reference/api/#research-proposal) | General proposal structure, with optional budget, work package, and timeline components. |

The [template index](/satz/reference/templates/) describes the current scope of each document type.

## Start a general research proposal

Create `proposal.typ` and use `research-proposal` when you need a flexible structure rather than a funder-specific form:

```typst
#import "@local/satz:0.2.0": research-proposal
#show: research-proposal.with(
  title: [Example Project],
  applicants: [Alex Example, Sample University],
  institution: [Sample University],
  date: [October 2026],
  summary: [A short summary of the question, approach, and expected contribution.],
)

= Aims

State the problem and the questions the project will answer.

= Approach

Describe the work packages, methods, and expected outcomes.

= Impact

Explain who can use the results and what the project will make possible.
```

This layout does not enforce a particular funder's headings or page limits. Add planning details with `proposal-budget`, `work-package`, or `proposal-gantt` after checking their exact input shapes in the [API reference](/satz/reference/api/).

## Start a DFG proposal

The DFG template targets form 53.01, revision 09/26. Replace this short draft with the exact sections required by your call; `check-pages: false` below is useful while drafting but should not be used as a final page-limit check:

```typst
#import "@local/satz:0.2.0": dfg-proposal
#show: dfg-proposal.with(
  applicant: [Alex Example, Sample University],
  project: [Example Project],
  language: "english",
  check-pages: false,
)

= State of the art

Summarize the current evidence and identify the open question.

= Objectives and work programme

State the aims, methods, schedule, and responsibilities.

= Project requirements

Describe the resources required by the call.
```

When the proposal includes sections 4 and 5, place `dfg-supplement()` at the boundary described in the [DFG source guide](/satz/guides/proposals/#coverage-and-limitations) and turn page checking back on. Validate the form revision and all formal requirements against the current call.

## Start an NWO Talent Programme proposal

The NWO layout requires an explicitly supported scheme, domain, stage, and year. This example uses a source-checked 2026 Veni Science pre-proposal profile:

```typst
#import "@local/satz:0.2.0": nwo-proposal
#show: nwo-proposal.with(
  scheme: "veni",
  domain: "science",
  stage: "pre",
  year: 2026,
  applicant: [Alex Example],
  title: [Example Project],
)

= Project idea

Describe the question, the approach, and why it matters.

= Research plan

Explain the work and the outcomes expected during the proposed period.
```

If the selected combination is not in the checked profiles, Satz reports an error. Do not substitute a similar scheme or stage and assume that the layout matches. Check the current NWO call and the documented profile coverage before drafting.

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
