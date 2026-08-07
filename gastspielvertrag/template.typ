// Gastspielvertrag template — guest performance contract with fill-in fields.
//
// Supports three document types: Vertrag (contract), Angebot (offer), Rechnung (invoice).

#import "components.typ": contract_header, paragraph_1, paragraph_2, paragraph_3, paragraph_4, paragraph_5, paragraph_6, paragraph_7, paragraph_8, signature_lines

/// A guest performance contract (Gastspielvertrag) with fill-in fields for the venue.
///
/// Supports three output formats:
/// - `"vertrag"`: full contract with all §§ and signature lines
/// - `"angebot"`: non-binding offer (no signatures, "Kostenvoranschlag" title)
/// - `"rechnung"`: invoice mode (reuses satz invoice components)
///
/// Fill-in blanks are rendered as underlined spaces — the recipient fills them out
/// by hand or in a PDF editor. All artist-side defaults use placeholder values.
///
/// ```example
/// #show: gastspielvertrag.with(
///   dokument: "vertrag",
///   veranstaltung: "Konzert",
///   location: "Club XYZ",
///   datum: "15.03.2026",
///   festgage: 800,
///   transport_km: 120,
/// )
/// ```
///
/// - dokument (str): "vertrag", "angebot", or "rechnung"
/// - veranstaltung (str): Event name
/// - location (str): Venue name
/// - datum (str): Event date
/// - auftrittszeit (str): Performance start time
/// - auftrittsdauer (str): Performance duration
/// - einlass (str): Doors open time
/// - curfew (str): Curfew time
/// - musiker (int): Number of musicians
/// - techniker (bool): Technician present
/// - fotograf (bool): Photographer present
/// - gage_typ (str): "fest" or "prozent"
/// - festgage (int): Fixed fee in EUR
/// - prozentsatz (int): Percentage of ticket sales
/// - mindestgage (int): Minimum guaranteed fee
/// - kleinunternehmer (bool): Show § 19 UStG small business notice
/// - transport_km (int): One-way distance in km (0 = no transport)
/// - transport_satz (float): EUR per km (default 0.30)
/// - techniker_honorar (int): Technician fee (0 = none)
/// - uebernachtung (int): Accommodation costs (0 = none)
/// - sonstiges_text (str): Additional cost description
/// - sonstiges_betrag (int): Additional cost amount
/// - buyout_pro_person (int): Buy-out per person in EUR
/// - kuenstler (str): Artist name
/// - kuenstler_vertreter (str): Artist representative
/// - kuenstler_anschrift (str): Artist address
/// - font (str): Body font. Defaults to "Inter".
/// - body (content): Additional contract text (appended after §8)
#let gastspielvertrag(
  // Document type
  dokument: "vertrag",

  // Artist info
  kuenstler: "Max Mustermann",
  kuenstler_vertreter: "Max Mustermann",
  kuenstler_anschrift: "Musterstraße 1, 12345 Musterstadt",

  // Event
  veranstaltung: "",
  location: "",
  datum: "",
  auftrittszeit: "",
  auftrittsdauer: "",
  einlass: "",
  curfew: "",

  // Personnel
  musiker: 4,
  techniker: true,
  fotograf: false,

  // Fee
  gage_typ: "fest",
  festgage: 0,
  prozentsatz: 80,
  mindestgage: 0,
  kleinunternehmer: true,

  // Transport
  transport_km: 0,
  transport_satz: 0.30,

  // Optional costs
  techniker_honorar: 0,
  uebernachtung: 0,
  sonstiges_text: "",
  sonstiges_betrag: 0,

  // Hospitality
  buyout_pro_person: 15,

  // Styling
  font: "Inter",

  // Extra content
  body,
) = {
  let zeilenabstand = 0.75em

  // Build default gig dict for components (filled from params)
  let g = (
    veranstaltung: veranstaltung,
    location: location,
    datum: datum,
    auftrittszeit: auftrittszeit,
    auftrittsdauer: auftrittsdauer,
    einlass: einlass,
    curfew: curfew,
    musiker: musiker,
    techniker: techniker,
    fotograf: fotograf,
    gage_typ: gage_typ,
    festgage: festgage,
    prozentsatz: prozentsatz,
    mindestgage: mindestgage,
    kleinunternehmer: kleinunternehmer,
    transport_km: transport_km,
    transport_satz: transport_satz,
    techniker_honorar: techniker_honorar,
    uebernachtung: uebernachtung,
    sonstiges_text: sonstiges_text,
    sonstiges_betrag: sonstiges_betrag,
    buyout_pro_person: buyout_pro_person,
    kuenstler: kuenstler,
    kuenstler_vertreter: kuenstler_vertreter,
    kuenstler_anschrift: kuenstler_anschrift,
  )

  // --- Global styles ---
  set text(font: font, size: 11pt, lang: "de", hyphenate: false)
  set page(
    "a4",
    margin: (left: 2.5cm, right: 2cm, top: 2.5cm, bottom: 2.5cm),
    footer: context [
      #set text(size: 8.5pt)
      #align(center)[Seite #counter(page).get().first() von #counter(page).final().last()]
    ],
  )
  set par(justify: true, leading: zeilenabstand)

  // --- Title ---
  let title = if dokument == "angebot" {
    [KOSTENVORANSCHLAG]
  } else if dokument == "rechnung" {
    [RECHNUNG]
  } else {
    [GASTSPIELVERTRAG]
  }
  align(center, text(weight: "bold", size: 14pt)[#title])
  v(2em)

  // --- Contract header ---
  contract_header(g, zeilenabstand)
  v(2em)

  // --- Contract body (full contract mode only) ---
  if dokument != "rechnung" {
    paragraph_1(g)
    v(1.5em)

    paragraph_2(g, zeilenabstand)
    v(1.5em)

    paragraph_3()
    v(1.5em)

    paragraph_4()
    v(1.5em)

    paragraph_5(g)
    v(1.5em)

    paragraph_6(g)
    v(1.5em)

    paragraph_7()
    v(1.5em)

    paragraph_8()
    v(2em)

    // Custom body content (e.g., additional clauses)
    body

    // Signatures (contract mode only)
    if dokument == "vertrag" {
      v(1em)
      text(size: 9pt)[
        #align(center)[
          Ort, Datum: #datetime.today().display("[day].[month].[year]")
        ]
      ]
      signature_lines(g.kuenstler_vertreter)
    }

    // Angebot footer
    if dokument == "angebot" {
      v(2em)
      text(size: 9pt, style: "italic")[
        Dieses Angebot ist unverbindlich und gilt bis zum
        #datetime.today().display("[day].[month].[year]").
      ]
    }
  }
}
