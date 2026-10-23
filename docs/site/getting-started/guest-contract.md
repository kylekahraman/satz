---
title: "Create a guest performance contract"
description: "Fill in the Satz guest performance contract for a concert, choose a fee structure, and review the compiled document."
---

Use `gastspielvertrag()` to create a German document for a performance. It can produce a contract, an offer, or an invoice. This guide shows a basic contract with fictional details; review all terms and amounts before sharing or signing it.

## 1. Create a contract

Create `performance.typ` and paste this starter:

```typst
#import "@local/satz:0.2.0": gastspielvertrag
#show: gastspielvertrag.with(
  dokument: "vertrag",
  kuenstler: "Example Band",
  kuenstler_vertreter: "Alex Example",
  kuenstler_anschrift: "One Street, 12345 Example City",
  veranstaltung: "Autumn Concert",
  location: "Example Hall, Sample City",
  datum: "15.11.2026",
  auftrittszeit: "20:00",
  auftrittsdauer: "90 minutes",
  einlass: "19:00",
  musiker: 4,
  gage_typ: "fest",
  festgage: 800,
  transport_km: 120,
)

Add any agreed special conditions here.
```

The function supplies the contract sections and signature lines. The `dokument` option chooses the output mode: `"vertrag"`, `"angebot"`, or `"rechnung"`. The example uses a fixed fee in euros and a one-way transport distance in kilometres.

## 2. Choose how the fee is calculated

For a fixed fee, use `gage_typ: "fest"` and set `festgage` to the agreed whole-euro amount. For a ticket-sales share, use `gage_typ: "prozent"`, then set `prozentsatz` and, if agreed, `mindestgage`. Do not fill in both fee models unless the agreement calls for both. Optional costs such as technician fees, accommodation, and transport are separate fields.

Options such as `techniker`, `fotograf`, and `kleinunternehmer` control whether related terms appear. Use them only when they match the agreement. Confirm that the event details, amounts, cancellation terms, and any tax wording are correct for the parties.

## 3. Compile and review

Run `typst compile --package-path packages performance.typ`. Check the event date and location, performance times, names and addresses, fee mode, all costs, and the signature lines. `"angebot"` and `"rechnung"` modes change the document wording; choose the mode before sending it.

The full list of supported fields is in the [`gastspielvertrag` API entry](/satz/reference/api/#gastspielvertrag). This tutorial targets Satz 0.2.0 during usability testing. After publication, change `@local` to `@preview` in the import and keep version `0.2.0`.
