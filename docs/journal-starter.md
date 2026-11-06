# Satz journal starter

The starter is a normal Typst project: a cover, editable identity and style settings, an example entry, and a copy of the Satz source it uses. It does not install a Typst package or require Python, Go, Bash, or Make to edit the journal.

## Start a journal

Install [Visual Studio Code](https://code.visualstudio.com/) and the [Tinymist Typst extension](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist). Unzip the journal starter, open its folder in VS Code, then open `main.typ` and run **Typst: Preview** from the command palette. The project recommends Tinymist when VS Code opens it.

Edit `config.typ` to change the cover title, subtitle, author, theme, cover layout, and paper size. The default `neutral` theme is black on white; `slate` preserves Satz's former blue-gray palette, and optional palettes include `soft-jade`, `soft-slate`, `warm-editorial`, `plum`, and `soft-rose`. Add entries under `entries/` and include them in `journal-entries.typ` above the end marker. Each journal lives in its own folder; you can make as many independent journals as you need.

`main.typ` includes `journal-entries.typ` where the entries appear. If that line is removed, restore `#include "journal-entries.typ"` in `main.typ`. If the end marker is removed from `journal-entries.typ`, restore `// --- end entries ---` on a separate line after the entry includes. The helper stops with an error instead of creating an unregistered entry. Older journals with their entry list directly in `main.typ` remain supported.

The `_satz/` folder contains the Satz source bundled with the starter, so the project does not need a published package or local package cache. To keep the full journal visible while editing an individual entry, open `main.typ` and use Tinymist's **Typst: Pin Main** command. See the [Tinymist VS Code guide](https://myriad-dreamin.github.io/tinymist/frontend/vscode.html).

## Optional `journal` command

The optional helper is a small standalone Go program. End users do not need Go installed to run a prebuilt helper. The helper has not been published or installed globally by this project; use a locally built executable you trust, or continue editing the starter without it. The basic journal workflow does not require downloading an executable.

The helper can create starter projects, remember journals, and add meeting/session/note entries. To build it yourself, install Go from [go.dev](https://go.dev/dl/) and, from the repository root, run:

```sh
cd tools/journal
GOENV=off GOTOOLCHAIN=local GOCACHE=/tmp/satz-journal-go-cache go test
GOENV=off GOTOOLCHAIN=local GOCACHE=/tmp/satz-journal-go-cache go build -o journal .
```

Then use the executable directly:

```text
journal init "path/to/My Journal"
journal use "path/to/My Journal"
journal
```

The last command selects a registered journal, asks for an entry title, type, and optional keywords, adds the new Typst file to its entry list, and opens the chosen editor. With several registered journals, choose a number; Enter selects the most recently used. With none, the command offers to create or connect one. Use `journal init PATH` or `journal use PATH` to add another journal directly. Entry types accept `meeting`/`m`, `session`/`s`, or `notes`/`n`. The helper never edits shell startup files. If no editor is available, the entry remains saved and the helper tells you where to find it. VS Code is detected automatically; set `VISUAL` or `EDITOR` to choose another editor.

If a registered journal moves, choose `r` in the journal chooser and enter its new folder, or run `journal reconnect OLD_PATH NEW_PATH`. The new location must be a compatible journal; reconnecting updates the existing registration without touching the journal files or other registered projects. Connecting an existing folder checks for the journal's setup and entry-registration files; arbitrary Typst projects are not imported automatically.

New journals include editable `templates/meeting.typ`, `templates/session.typ`, and `templates/notes.typ` files. Edit their headings and text to change future entries; the helper supplies the title, date, and keywords separately. Templates contain Typst content inside an entry's content block, so invalid Typst or unbalanced brackets can prevent compilation. The helper checks for missing or empty templates but does not yet validate Typst syntax. Existing journals without a `templates/` folder continue to use the built-in scaffolds.

Existing journals retain their bundled Satz source. Runtime updates are disabled until a safe backup and recovery workflow is available. `journal starter-zip OUTPUT.zip` is a maintainer command for building the editable starter archive from the embedded files.

## Maintainer builds

Go is needed only to build the helper. From `tools/journal`, `./build-release.sh` creates ZIPs for Windows, macOS, and Linux (amd64 and arm64), plus a `SHA256SUMS` file. It uses the standard Go toolchain and no third-party modules.

These development builds are unsigned. Windows and Linux binaries cross-compiled on macOS have not been run natively; verify them on their target systems before distributing them. Do not treat an archive or executable as an official release unless Satz publishes it through a trusted release channel.
