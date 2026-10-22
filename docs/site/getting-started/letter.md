---
title: "Write a letter"
---

Create `main.typ` and paste this complete example. The English alias `letter` currently uses German field names for sender, recipient, and subject.

```typst
#import "@preview/satz:0.1.1": letter
#show: letter.with(
  absender: (
    name: "Alex Example",
    strasse: "Example Street 1",
    plz_ort: "12345 Example City",
  ),
  empfaenger: (
    name: "Research Office",
    strasse: "Sample Road 2",
    plz_ort: "54321 Sample City",
  ),
  betreff: "Appointment request",
  lang: "en",
)

Dear Research Office,

Could we arrange an appointment to discuss the project?

Kind regards,

Alex Example
```

Replace the example addresses and subject. Write the salutation, paragraphs, and closing below the show rule. Satz supplies the address layout, date, and subject. `lang: "de"` switches the document labels to German; it does not translate your text.

[Preview or export the letter](/satz/getting-started/setup/) in the same way as a report. The template follows a DIN-style business-letter layout, including space for a window envelope; the top of the page is intentionally different from a report.
