---
title: "Write a letter"
---

This example creates a DIN-style business letter using the published package. It fills in the sender, recipient, subject, and language, then leaves the letter body for you to write.

## 1. Create the document

Create `main.typ` and paste this complete example:

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

The import makes `letter` available. The show rule applies the letter layout to the content below it. `absender` and `empfaenger` are dictionaries: each contains the person's or organization's name, street, and postal code/city. Replace the example values with your own. `betreff` is the subject line. The content after the closing parenthesis is the letter body.

## 2. Compile and check the page

Preview the file in the Typst web app or Tinymist, or run `typst compile main.typ` from the document folder. Check the address block and subject in the PDF, especially when the recipient address must show through a window envelope. The layout reserves space for the address and follows a DIN-style business-letter structure, so the top of the page intentionally differs from a report.

## 3. Choose the label language

Set `lang: "de"` for German labels or `lang: "en"` for English labels. This changes labels supplied by the template; it does not translate your own salutation, body, or closing. The English alias still accepts the established German field names for compatibility. See the [API reference](/satz/reference/api/#brief) for every argument and [configuration reference](/satz/reference/configuration/#template-specific-appearance-defaults) for supported appearance settings.

## 4. Add optional fields

The letter can include a date, reference line, enclosures, attachments, signature addition, and postal mark. Only add fields that belong in this letter. For example, place `datum: "23 October 2026"` inside the `letter.with(...)` call to provide a date. The accepted arguments and their defaults are listed in the [letter API entry](/satz/reference/api/#brief).

## If you need a different page design

Use the report template for a report or assignment, and native Typst content for the letter's paragraphs and lists. If you need to alter margins, text size, or line spacing, first check the precise value type in [Configuration](/satz/reference/configuration/). The [template index](/satz/reference/templates/) shows which templates are published and which are still under development.
