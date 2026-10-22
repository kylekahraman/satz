# Choose a template

Use a document-level function for the overall structure, and native Typst elements for content inside it.

| Document | Entry point | Status |
| --- | --- | --- |
| General report, assignment, or thesis | `report` | Published |
| Research journal entry and index | `journal-entry`, `journal-index` | Published |
| DIN-style letter | `letter` / `brief` | Published |
| Invoice | `invoice` / `rechnung` | Published |
| Two-column article | `article` | Development |
| Book with exercises | `book` | Experimental |
| DFG proposal | `dfg-proposal`, `dfg-supplement`, `dfg-publications` | 53.01 (09/26), bilingual starters and separate 17/8-page checks (unreleased) |
| Research/project proposal | `research-proposal`, `project-proposal`, `proposal-budget` | Inline title/summary, current/total page headers and exact budgets (unreleased) |
| NWO Talent Programme | `nwo-proposal`, `nwo-profile` | Veni/Vidi/Vici 2026 profiles and starters; see coverage and limitations (unreleased) |
| Legal complaint | `klageschrift` | Published |
| Guest performance contract | `gastspielvertrag` | Published |
| Cover page | `cover-page` | Published; research/minimal presets: development |

Import the function you need:

```typst
#import "@preview/satz:0.1.1": report
#show: report.with()
```

Template functions are not all configured in the same way yet. Reports and journals use shared `config`; letters and invoices retain German field names for compatibility. The [API design notes](../maintainers/api-design.md) describe how future interfaces can become more uniform without breaking existing documents.

For the complete proposal API and bilingual DFG starters, see the
[proposal guide](https://github.com/kylekahraman/satz/blob/main/docs/proposals.md).
