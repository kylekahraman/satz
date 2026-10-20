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
| DFG proposal | `dfg-proposal` | Work in progress |
| Legal complaint | `klageschrift` | Published |
| Guest performance contract | `gastspielvertrag` | Published |
| Cover page | `cover-page`, `research-cover`, `minimal-cover` | Published |

Import the function you need:

```typst
#import "@preview/satz:0.1.1": report
#show: report.with()
```

Template functions are not all configured in the same way yet. Reports and journals use shared `config`; letters and invoices retain German field names for compatibility. The [API design notes](../maintainers/api-design.md) describe how future interfaces can become more uniform without breaking existing documents.
