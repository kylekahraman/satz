---
title: "Write your first letter"
description: "Create, format, and compile a complete DIN-style letter with Satz, starting from one file."
---

This is the first tutorial to try when you need a letter. You will fill in the sender, recipient, date, and subject, write the message, and compile a PDF. You do not need to configure fonts or margins to get started.

## 1. Create a file and paste this letter

Create a blank Typst file named `main.typ`. Make sure your Typst setup can find the local Satz 0.2.0 package as described in [Set up the local 0.2.0 package](/satz/getting-started/setup/). Copy the complete example below. The names and addresses are fictional; replace them with your own.

```typst
#import "@local/satz:0.2.0": letter
#show: letter.with(
  sender: (
    name: "Alex Example",
    street: "Example Street 1",
    postal-code-city: "12345 Example City",
    email: "alex@example.org",
  ),
  recipient: (
    name: "Research Office",
    street: "Sample Road 2",
    postal-code-city: "54321 Sample City",
  ),
  date: "23 October 2026",
  subject: "Appointment request",
  language: "en",
)

Dear Research Office,

Could we arrange an appointment to discuss the project? I am available next
week and can adapt to a time that works for your team.

Please let me know what dates would suit you.

Kind regards,

Alex Example
```

`letter` is the English name for Satz's letter template. The `#show` line applies the letter layout to the content below it. The text after the show rule is the message itself: write normal paragraphs, lists, emphasis, and links there.

## 2. Replace the address and letter details

The `sender` dictionary contains your details; `recipient` contains the recipient's details. Both need a name, street, and postal code/city. Keep the exact field names shown above. Add optional contact information such as `phone` or `email` to the sender if you want it printed.

Change `date` to the date you want on the letter, and replace `subject` with a short description of its purpose. These values go in the `letter.with(...)` settings above the message. Keep the message, greeting, and closing below the settings block.

## 3. Compile the letter

From a terminal in the folder containing `main.typ`, run:

```sh
typst compile --package-path packages main.typ
```

Typst creates `main.pdf`. Read the page and check the spelling, addresses, date, subject, and signature. The default layout reserves space for a window-envelope address and includes fold and punch marks. Those are expected on a postal letter.

## 4. Add the details you need

Put optional fields inside `letter.with(...)`, after `subject`. For example, this adds a reference line and a list of enclosures:

```typst
  reference-line: (("Your reference", "ABC-123"),),
  enclosure-list: ("Project outline", "Budget"),
```

The names before each colon are settings; keep the trailing commas when adding more than one setting. To remove the physical signature area from a digitally signed PDF, add `signatur: false`. To see every accepted argument, open the [`letter` API entry](/satz/reference/api/#brief).

## 5. Make a digital PDF letter

For a PDF that will be read on screen rather than put in a window envelope, use the digital sender block and turn off the address window and postal marks:

```typst
#show: letter.with(
  // Keep your sender, recipient, date, and subject fields here.
  digitaler_absender: true,
  adressfenster: false,
  falzmarken: false,
)
```

Copy only these three settings into the existing `letter.with(...)` call; do not add a second show rule. Add a logo with `logo: image("logo.png", width: 3cm)` inside the `sender` dictionary, and keep `logo.png` beside `main.typ`.

## Language and version

`language: "de"` selects German template labels and `language: "en"` selects English labels. This setting does not translate the message you write. The postal switches in step 5 keep their German names because those are the argument names currently exposed by the letter API.

All examples on this site use the Satz 0.2.0 API. While 0.2.0 is under usability review, import it from the local package as shown. After the release is published to Typst Universe, change only the package namespace from `@local` to `@preview`; keep version `0.2.0`.

You can write this letter without opening the [configuration reference](/satz/reference/configuration/). For an assignment or research report, continue with [Write your first report](/satz/getting-started/report/). For a dated research diary, follow [Keep a research journal](/satz/guides/journals/). For a longer thesis or book, see [Typeset a thesis or book](/satz/getting-started/thesis-book/).
