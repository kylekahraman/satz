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
./journal init "path/to/My Journal"
./journal use "path/to/My Journal"
./journal
```

These examples run the local executable from `tools/journal` on macOS or Linux. If you install it on your PATH, use `journal` from any folder. On Windows, build or use `journal.exe` and run it from its folder or add that folder to your PATH.

In an interactive terminal the last command offers **New entry** (Enter), **Manage journals** (`m`), **Help** (`h`), or **Quit** (`q`). New entry selects a registered journal, asks for a title, type, and optional keywords, adds the file to its entry list, and opens the chosen editor. With several registered journals, use the arrow keys and Enter in an interactive terminal, or choose a number in plain or piped input. Enter selects the most recently used. With none, the command offers to create or connect one. Use `journal init PATH` or `journal use PATH` to add another journal directly. Entry types accept `meeting`/`m`, `session`/`s`, or `notes`/`n`. Set `NO_COLOR` to disable color. The helper never edits shell startup files. If no editor is available, the entry remains saved and the helper tells you where to find it. VS Code is detected automatically; set `VISUAL` or `EDITOR` to choose another editor.

Use `journal editor "COMMAND"` to save an editor command, `journal editor` to see it, and `journal editor --clear` to return to environment-based selection. An explicit `journal new --editor "COMMAND"` takes precedence, followed by the saved preference, `VISUAL`, `EDITOR`, and automatic VS Code detection. Quote paths containing spaces inside the command, for example `journal editor '"/path with spaces/editor" --wait'`.

Entries with the same title on the same day get distinct filenames (for example, `-2.typ`); an existing entry is never overwritten.

The helper uses a small `.satz-journal.lock` file to coordinate simultaneous entry creation. The operating system releases the lock if the helper exits; the file itself may remain and is safe to leave in place. Do not delete it while journal commands are running. New starters exclude it from Git.

If a registered journal moves, choose `r` in the journal chooser and enter its new folder, or run `journal reconnect OLD_PATH NEW_PATH`. The new location must be a compatible journal; reconnecting updates the existing registration without touching the journal files or other registered projects. Connecting an existing folder checks for the journal's setup and entry-registration files; arbitrary Typst projects are not imported automatically.

Run `journal journals` to manage the list even if only one journal is registered. Choose `f` to remove a journal from the list, or use `journal forget PATH`; both leave its files untouched. You can connect it again later.

`journal journals --details` also scans each journal's `entries/` folder and shows its entry count and most recently modified date. The ordinary chooser does not perform this scan. Counts include non-hidden `.typ` files whether or not they are included in the main document; dates are filesystem modification dates.

Use `journal rename PATH "DISPLAY NAME"` to change a journal's name in the chooser. This does not rename or move the journal folder, and the display name is retained when the journal is selected or reconnected.

Run `journal check PATH` for a read-only check of the journal's entry-list connection and template files. Omitting the path checks the journal containing the current directory, or the most recently selected journal. This checks the file structure; it does not compile the journal or validate Typst syntax.

New journals include editable `templates/meeting.typ`, `templates/session.typ`, and `templates/notes.typ` files. Edit their headings and text to change future entries; the helper supplies the title, date, and keywords separately, so there are no placeholders to maintain. Templates contain Typst content inside an entry's content block. Before using a customized template, the helper compiles a temporary entry and reports any error without creating or registering the final entry. If a reference is unresolved in the entry alone, it retries with the whole journal so references to other entries can resolve. Each check is limited to 30 seconds. This check requires the [Typst CLI](https://typst.app/open-source/#download) on your PATH; the original templates do not require it. Existing journals without a `templates/` folder continue to use the built-in scaffolds.

Run `journal open [PATH]` to open a journal folder, or `journal template meeting [PATH]` to open a template (also accepts `session` and `notes`). `journal template-default meeting [PATH]` creates `templates/meeting.default.typ` as a separate reference copy. It never replaces an existing copy or customized template; compare and copy the parts you want manually.

`journal entries [PATH]` lists `.typ` files in `entries/` by modification time, `journal search "TEXT" [PATH]` finds case-insensitive matches in filenames or file contents, and `journal recent [PATH]` opens the most recently modified entry. These commands examine files in the folder, including entries that may not be included in the main document. Hidden temporary files are excluded; modification times reflect the filesystem, not necessarily when an entry was written.

To create an optional launcher, run `journal shortcut OUTPUT`, choosing a new filename ending in `.command` on macOS, `.desktop` on Linux, or `.cmd` on Windows. The launcher starts the journal chooser in a terminal and points to the current executable, so recreate it if the executable moves. Desktop environments may require marking a downloaded or newly created launcher as trusted before opening it. Existing files are never overwritten.

Existing journals retain their bundled Satz source. Runtime updates are disabled until a safe backup and recovery workflow is available. `journal starter-zip OUTPUT.zip` is a maintainer command for building the editable starter archive from the embedded files.

## Maintainer builds

Go is needed only to build the helper. From `tools/journal`, `./build-release.sh VERSION [OUTPUT_DIR]` creates versioned ZIPs for Windows, macOS, and Linux (amd64 and arm64), plus a `SHA256SUMS` file. Each archive includes the guide and dependency licenses. The output directory must be empty. The build uses the Go terminal libraries specified in `go.mod`; `journal version` displays the embedded version.

These development builds are unsigned. Windows and Linux binaries cross-compiled on macOS have not been run natively; verify them on their target systems before distributing them. Do not treat an archive or executable as an official release unless Satz publishes it through a trusted release channel.
