# Shareable Satz journal starter

The starter gives new users a ready-to-edit Typst journal with an editable cover, a first entry, and the Satz runtime inside the project. VS Code and Tinymist are the recommended beginner setup; no Bash script, Make, Python, or Satz package cache is needed to edit and preview the generated project.

## For journal authors

1. Install [Visual Studio Code](https://code.visualstudio.com/) and the [Tinymist Typst extension](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist). The starter recommends the extension when VS Code opens the project.
2. Unzip a Satz journal starter shared with you, or have someone create one with `journal init ~/Documents/My-Journal` (use a suitable folder path on Windows). `journal init` remembers the new folder for the short command below.
3. Open the project folder in VS Code, open `main.typ`, and run **Typst: Preview** from the command palette. When the `journal` command opens a new entry, open `main.typ` and run **Typst: Pin Main** if you want the preview to keep showing the complete journal while that entry is active. Tinymist documents this command and its multi-file project behavior in its [VS Code guide](https://myriad-dreamin.github.io/tinymist/frontend/vscode.html).
4. Edit `config.typ` to change the cover title, subtitle, author, theme, cover layout, and paper size. Themes include `neutral`, `soft-jade`, `soft-slate`, `warm-editorial`, `plum`, and `soft-rose`. Add entries under `entries/` and include them in `main.typ` between its entry markers.

The first compile may download Typst preview packages used by the journal. The `_satz/` directory contains the exact Satz source used by this starter, so it builds without requiring a published package or a local package symlink.

## Optional terminal helper

The basic edit-and-preview workflow above has no Python requirement. For the optional `journal` command, install Python 3.10 or newer, then run this from a Satz source checkout:

```text
python -m pip install ./tools/journal
journal init "path/to/My Journal"
journal use "path/to/My Journal"
journal
```

The last command asks for an entry title, type, and keywords, creates the Typst file, adds it to `main.typ`, then opens it with VS Code when the `code` command is available. Set `VISUAL` or `EDITOR` to use another editor, or use `journal new PATH --editor "editor command"`. If no editor can be found, the entry remains saved and the command prints a reminder to open it manually. `journal use PATH` stores the chosen folder in the operating system's user configuration directory; it does not edit shell startup files.

`journal use PATH` switches to another project. `journal update-satz PATH` refreshes the project's `_satz/` directory from the runtime bundled with the installed helper. The builder uses files tracked at the current Git commit and records that revision in `_satz/VERSION.txt`; commit Satz changes before rebuilding if you want to include them. This is an explicit update, so existing journals keep their working version until their author chooses to refresh it.

## Making a starter ZIP

From the repository root, run:

```text
python tools/journal/build_starter.py --zip /path/to/satz-journal-starter.zip
```

The builder includes only committed Typst runtime sources, an MIT license, and a short version/revision record. It does not include untracked drafts, PDFs, tests, personal journal material, or Git metadata. The generated archive is an output artifact and should be hosted separately when the project is ready to share.
