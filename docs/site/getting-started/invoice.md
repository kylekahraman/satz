---
title: "Create an invoice"
description: "Build and check a German invoice with Satz, including sender and recipient details and line items."
---

This tutorial starts with a blank file and builds a German invoice with Satz 0.2.0. It explains which information goes into structured fields and which belongs in the message body. The example uses fictional details and disables the payment QR code; replace every value with verified information before you use an invoice.

## 1. Create `main.typ`

Paste this complete example into a new Typst project:

```typst
#import "@local/satz:0.2.1": invoice
#invoice(
  sender: (
    name: "Example Studio",
    street: "Sample Street 1",
    postal-code-city: "12345 Sample City",
    tax-number: "000/000/00000",
    iban: "DE00 0000 0000 0000 0000 00",
    bank: "Example Bank",
    account-holder: "Example Studio",
  ),
  recipient: (
    name: "Example Client",
    street: "Market Street 2",
    postal-code-city: "54321 Example Town",
  ),
  date: "23.10.2026",
  invoice-number: "2026-001",
  service-date: "21.10.2026",
  subject: "Design services",
  items: (
    ("Design consultation", 2, 85.00),
    ("Preparation of materials", 1, 120.00),
  ),
  qr: false,
)[
  Thank you for commissioning this work. Please contact me if you have a
  question about this invoice.
]
```

The import loads `invoice`, the English alias for `rechnung`, from Satz 0.2.0. `#invoice(...)` creates one invoice from the structured fields, and the square-bracket content at the end is the message body. This function call is different from the report and letter show rules. The template's labels and output remain German; the input names are English. German input names from 0.1.1 remain aliases.

## 2. Replace the example values

The `sender` and `recipient` values are dictionaries. Each contains the name, street, and postal-code/city (`street` and `postal-code-city`). The sender also supplies the tax number, IBAN, and bank name. The optional account holder defaults to the sender name. `date`, `invoice-number`, `service-date`, and `subject` provide the corresponding invoice fields; they are strings in this interface.

Each item in `items` is a three-value tuple: description, quantity, unit price. Descriptions may be strings or Typst content. Quantity must be a positive number; unit price must be a nonnegative number. Item records with `description`, `quantity`, and `unit-price` are also accepted; see the [`invoice` API entry](/satz/reference/api/#invoice) for the full input contract.

## 3. Decide whether to include payment details

The example sets `qr: false`, so it does not add a payment QR code. The default is `true`; with valid bank details, the template can generate an EPC payment QR code. Replace the placeholder bank details before enabling it. Optional `qr-amount` lets you supply an amount explicitly; otherwise the template totals the items. `qr-purpose` sets the payment note.

`small-business: true` enables the template's small-business notice. Use this option only when it matches your actual situation. A document template cannot determine which fields, wording, taxes, or statutory information your circumstances require; check the current rules that apply to you before issuing an invoice.

## 4. Preview and inspect the invoice

Run `typst compile --package-path packages main.typ` in the project folder. Read the resulting PDF carefully. Confirm the sender and recipient address, invoice number, service date, line-item quantities and amounts, total, bank details, and any optional notice. Check that the address block works with the envelope or delivery method you use.

If you change typography or page appearance, pass `config` with only the documented appearance keys. Unknown groups or keys are rejected. See [Invoice appearance defaults](/satz/reference/configuration/#template-specific-appearance-defaults). For a new Typst project, editor setup, and the compile command, see [Set up and write](/satz/getting-started/setup/).

## 5. Keep an editable copy

Save `main.typ` with the final PDF and keep the package version explicit in the import. The `.typ` file lets you correct a detail and compile a replacement later. The PDF is the copy to send. Do not reuse this fictional example without replacing and checking every field.

To make a letter instead, follow [Write a letter](/satz/getting-started/letter/). For other document structures, browse [Choose a template](/satz/reference/templates/) and the full [API reference](/satz/reference/api/).
