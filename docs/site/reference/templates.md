---
title: "Choose a template"
---

Choose the template that matches the document's structure. Satz controls the page furniture and common styles; your headings, paragraphs, lists, figures, and tables remain normal Typst content. Each link below opens the matching function in the [API reference](/satz/reference/api/). Its exact signature and source link let you inspect the accepted inputs.

## Published templates

| Document | Entry points | Good starting point |
| --- | --- | --- |
| Report, assignment, or protocol | [`report`](/satz/reference/api/#report) | General documents with numbered headings and contents. Start with [Write your first report](/satz/getting-started/report/). |
| Research journal | [`journal-entry`](/satz/reference/api/#journal-entry), [`journal-index`](/satz/reference/api/#journal-index) | Dated notes, decisions, observations, and next steps. Follow [Keep a research journal](/satz/guides/journals/). |
| DIN-style letter | [`brief`](/satz/reference/api/#brief) / `letter` | German or English template labels with a window-envelope address block. Start with [Write a letter](/satz/getting-started/letter/). |
| Invoice | [`rechnung`](/satz/reference/api/#rechnung) / `invoice` | German invoice layout and item table. |
| Legal complaint | [`klageschrift`](/satz/reference/api/#klageschrift) | German civil complaint document structure. |
| Guest performance contract | [`gastspielvertrag`](/satz/reference/api/#gastspielvertrag) | Contract, offer, or invoice document for a performance. |
| Cover page | [`cover-page`](/satz/reference/api/#cover-page) | A composable cover page with body and footer slots. |

The English names `letter` and `invoice` are aliases of `brief` and `rechnung`, so they use the same fields and output. Read the [API reference](/satz/reference/api/) for their exact signatures and the [configuration reference](/satz/reference/configuration/) for settings and defaults.

## Development and experimental templates

These interfaces are in the 0.2.0 candidate source and are not available from the published `@preview/satz:0.1.1` package. Follow [Development versions](/satz/guides/development/) to compile them.

| Document or component | Entry points | Status and notes |
| --- | --- | --- |
| Research article | [`article`](/satz/reference/api/#article) | Two-column scholarly layout with title, author and affiliation block, and abstract. Development. |
| Book | [`book`](/satz/reference/api/#book) and [`book-contents`](/satz/reference/api/#book-contents) | Experimental structure with front matter, main matter, appendices, and back matter. |
| Teaching material | [`exercise`](/satz/reference/api/#exercise), [`worked-example`](/satz/reference/api/#worked-example), [`analysis-note`](/satz/reference/api/#analysis-note), [`answer-grid`](/satz/reference/api/#answer-grid) | Reusable components for instructional documents. |
| Research proposal | [`research-proposal`](/satz/reference/api/#research-proposal), [`proposal-budget`](/satz/reference/api/#proposal-budget), [`proposal-gantt`](/satz/reference/api/#proposal-gantt) | Flexible proposal cover and planning helpers. See [Proposal guide](/satz/guides/proposals/). |
| DFG proposal | [`dfg-proposal`](/satz/reference/api/#dfg-proposal), [`dfg-supplement`](/satz/reference/api/#dfg-supplement), [`dfg-publications`](/satz/reference/api/#dfg-publications) | Candidate for DFG form 53.01 (09/26), with limited documented scope. |
| NWO Talent Programme | [`nwo-proposal`](/satz/reference/api/#nwo-proposal), [`nwo-profile`](/satz/reference/api/#nwo-profile) | Only source-checked 2026 combinations are represented; consult profile coverage before use. |
| Citations and publications | [`proposal-citations`](/satz/reference/api/#proposal-citations), [`proposal-publications`](/satz/reference/api/#proposal-publications) | Proposal-specific bibliography helpers. |
| Layout helpers | [`callout`](/satz/reference/api/#callout), [`satz-figure`](/satz/reference/api/#satz-figure), [`scientific-table`](/satz/reference/api/#scientific-table), [`placeholder`](/satz/reference/api/#placeholder) | Components used within documents rather than as full document templates. |
| Cover presets | `research-cover`, `minimal-cover` | Presets of `cover-page`; development. |

Candidate support for a funding scheme is not a guarantee that the document meets every call requirement. Check the current funder instructions and the limitations in [Proposal templates and coverage](/satz/guides/proposals/).

## How to read the API and configuration reference

The [API reference](/satz/reference/api/) describes the public function signatures, required content, record shapes, accepted enums, and helper return values. The [configuration reference](/satz/reference/configuration/) describes each shared setting's type, default, and effect, with links to individual fields. For learning the markup language itself, see the [Typst writing tutorial](https://typst.app/docs/tutorial/writing-in-typst/).
