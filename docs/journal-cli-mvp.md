# Journal CLI MVP

## Goal

Make a polished, dependable journal workflow available as a standalone executable. Start with journals; a general Satz CLI and the executable's final name remain open decisions. Generated journals use Satz 0.2.0 and remain ordinary, editable Typst projects without the CLI.

## User requirements

- Present a coherent, attractive keyboard-accessible terminal interface, with highlighted choices, readable status and errors, and a usable no-color mode. Never rely on color alone.
- On first use offer to create a journal or connect a compatible existing one. Never overwrite a nonempty destination; explain incompatibilities and missing paths.
- Register multiple independent journals. Select the only journal automatically; otherwise offer a chooser, showing the name and path and highlighting the most recently used. Show the selected journal before creating an entry.
- Create a dated entry from a title, meeting/session/notes type, and optional keywords. Never overwrite an existing entry. Register it with the journal, then open the preferred editor or show the saved path if opening fails.
- Place editable entry templates in each journal. Use the local copies for future entries and document their placeholders. Validate them before changing journal files and preserve customization on updates.
- Keep entry registration recoverable if users edit the main document. Validate prerequisites before writing, report actionable errors, and avoid leaving misleading partial results.
- Generate a working journal against a recorded Satz 0.2.0 version, without silent upgrades. Document setup and compilation; users must not need Go to run a released binary.

## Decisions and limits

The entry-list mechanism and recovery path, editable template format, and choice of bundled versus pinned Satz require explicit implementation decisions. Connecting existing journals initially covers supported compatible projects, not arbitrary Typst files. Automatic runtime upgrades, entry counts, last-edited information, other Satz document types, and a GUI are outside the MVP.

## Implementation sequence

Each step is independently reviewed, verified and committed. Add focused regression tests before behavior changes.

1. **Baseline and version** — inspect `tools/journal`, choose and document the 0.2.0 dependency strategy, update the starter and verify a generated journal compiles with `typst compile --root <journal> <journal>/main.typ <temporary-output>`.
2. **Editable templates and safe registration** — update `tools/journal/main.go` and `tools/journal/templates/`; test customization, malformed templates, missing registration links, duplicate names and failed writes with `go test ./...`. Document recovery in `docs/journal-starter.md`.
3. **Journal registry** — replace the single saved path with a compatible multi-journal registry, connect/create flows and missing-path handling; test migrations and isolation with `go test ./...`.
4. **Interactive interface** — implement and test the journal chooser, first-run flow, selection visibility and accessible color behavior. Exercise it in a real terminal, including cancellation and editor failures.
5. **End-to-end prototype** — create and select two journals, customize a meeting template, create entries and compile both journals with Typst. Verify failure recovery and update the user documentation. Package a local executable; public release and platform distribution are separate work.
