// Typst adaptation of letter-1.tex, Copyright 2008 Markus Kohm.
// Derived work maintained by the satz contributors, 2026.
// Distributed under LPPL 1.3c or later; see LPPL-1.3c.txt and README.md.
// The original source and compiled reference are available in the linked archive.

#import "../../lib.typ": letter

#show: letter.with(
  recipient: (
    name: "Petra Mustermann",
    street: "Vor dem Berg 1",
    postal-code-city: "12345 Musterhausen",
  ),
  // The source uses today's date; freeze the date printed in the reference PDF.
  date: "16. Februar 2018",
  show-date: false,
  show-sender: false,
  show-subject: false,
  signature: false,
  font: "New Computer Modern",
  justify: true,
  font-size: 12pt,
  line-spacing: 6.2pt,
  // Reference geometry, expressed through existing public configuration.
  margins: (left: 26.25mm, right: 26.25mm, top: 63.5mm),
  block-spacing: ("recipient-body": 20mm),
)

// Workaround: satz's date block always adds a label and uses 9pt text.
#align(right, text("16. Februar 2018"))
#v(5mm)
Liebe Vereinsvorsitzende,

seit einem Jahr gab es keine Mitgliederversammlung
mehr. Ich erinnere daran, dass unsere Satzung eine
solche jedes halbe Jahr vorsieht. Ich fordere den
Vorstand daher auf, umgehend eine solche in
Angriff zu nehmen.

In Erwartung einer Einladung
