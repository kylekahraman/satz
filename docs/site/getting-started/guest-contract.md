---
title: "Create a guest performance contract"
description: "Fill in the Satz guest performance contract for a concert, choose a fee structure, and review the compiled document."
---

Use `guest-contract()` to create a German document for a performance. It can produce a contract, an offer, or a title-only invoice mode. This guide shows a basic contract with fictional details; review all terms and amounts before sharing or signing it.

## 1. Create a contract

Create `performance.typ` and paste this starter:

```typst
#import "@local/satz:0.2.1": guest-contract
#show: guest-contract.with(
  document-type: "vertrag",
  artist: "Example Band",
  artist-representative: "Alex Example",
  artist-address: "One Street, 12345 Example City",
  event: "Autumn Concert",
  venue: "Example Hall, Sample City",
  date: "15.11.2026",
  performance-time: "20:00",
  performance-duration: "90 minutes",
  doors: "19:00",
  musicians: 4,
  fee-type: "fest",
  fixed-fee: 800,
  travel-km: 120,
)

Add any agreed special conditions here.
```

The function supplies the contract sections and signature lines. The `document-type` option chooses `"vertrag"`, `"angebot"`, or `"rechnung"`. The example uses a fixed fee in euros and a one-way transport distance in kilometres. The output remains German; `gastspielvertrag` and the German field names remain compatibility aliases.

## 2. Choose how the fee is calculated

For a fixed fee, use `fee-type: "fest"` and set `fixed-fee` to the agreed whole-euro amount. For a ticket-sales share, use `fee-type: "prozent"`, then set `percentage` and, if agreed, `minimum-fee`. Do not fill in both fee models unless the agreement calls for both. Optional costs such as `technician-fee`, `accommodation`, and `travel-km` are separate fields; the travel fee uses the round trip.

Options such as `technician`, `photographer`, and `small-business` control related terms. `small-business` defaults to true and prints the § 19 VAT note; set it to false when you charge VAT. Use these options only when they match the agreement. Confirm the event details, amounts, cancellation terms, and tax wording for the parties.

## 3. Compile and review

Run `typst compile --package-path packages performance.typ`. Check the event date and location, performance times, names and addresses, fee mode, all costs, and the signature lines. In `"rechnung"` mode only the title changes: no §§, fee table, body, or signature lines are rendered. Use Satz's `invoice()` for an actual invoice.

The full list of supported fields is in the [`guest-contract` API entry](/satz/reference/api/#guest-contract). This tutorial targets Satz 0.2.0 during usability testing. After publication, change `@local` to `@preview` in the import and keep version `0.2.0`.
