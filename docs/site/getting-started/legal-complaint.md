---
title: "Prepare a legal complaint document"
description: "Use the Satz Klageschrift structure, fill in its party and court fields, and compile a draft for review."
---

`complaint()` provides a German civil-complaint document structure with fields for the court, parties, amount in dispute, claims, reasoning, and exhibits. This tutorial shows how to populate the layout. The output remains German; `klageschrift` and the German field names remain compatibility aliases. The template does not determine whether a claim is legally sound or whether the document meets court requirements; have the contents checked by a qualified person before filing.

## 1. Create a draft

Create `klage.typ` and start with fictional placeholder details:

```typst
#import "@local/satz:0.2.1": complaint
#show: complaint.with(
  court: "Amtsgericht Musterstadt",
  court-address: "Gerichtsstraße 1, 12345 Musterstadt",
  plaintiff: "Alex Example",
  plaintiff-street: "Example Street 1",
  plaintiff-postal-code-city: "12345 Example City",
  defendant: "Robin Sample",
  defendant-street: "Sample Road 2",
  defendant-postal-code-city: "54321 Sample City",
  amount-in-dispute: "1.000,00 EUR",
  date: "27.10.2026",
  plaintiff-designation: "Kläger",
  exhibits: (
    "Anlage K 1: Vereinbarung",
    "Anlage K 2: Schriftwechsel",
  ),
)

= Anträge

Replace this placeholder with the claims in the wording checked for your case.

= Sachverhalt

Set out the relevant events in chronological order and identify the supporting
documents.

= Begründung

Add the reasoning for each claim and refer to the relevant exhibits.
```

The settings in `complaint.with(...)` populate the court and party blocks. The headings and text below the show rule form the body. `date` is explicit in the example; omit it and the compilation date is used. `plaintiff-designation` sets the role under the signature. Replace every fictional value and placeholder before using the document.

## 2. Attach exhibits

List each exhibit in `exhibits` using the label you use in the document, for example `"Anlage K 1: Vereinbarung"`. The template displays the list; it does not verify that each exhibit supports the statement beside it. If you need to append pages from a PDF, the API also accepts `exhibits-pdf` and `exhibit-page-limit`. The page limit is not a truncation setting: it must not exceed the PDF's actual page count, or compilation fails. Keep any file path relative to the project and verify the resulting PDF.

## 3. Compile and check

Run `typst compile --package-path packages klage.typ`. Inspect the court and party details, every claim and exhibit label, page numbering, and all page breaks. The template uses a wider right margin for court-file binding. It cannot check filing deadlines, jurisdiction, required statements, service rules, or the legal sufficiency of the draft.

This tutorial targets Satz 0.2.0 during usability testing. After publication, change `@local` to `@preview` in the import and keep version `0.2.0`.
