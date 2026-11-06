# Starting a journal entry

## User story

As a researcher, I want to start a journal entry quickly in my preferred editor,
so I can record work, decisions and questions without managing files manually.
The journal can also be used for teaching, personal notes or any other purpose.

## Everyday experience

The user starts `journal` from anywhere, or opens a shortcut for the same action.
With one registered journal, it is selected automatically. With several, a short
chooser shows their names, with the most recently used highlighted. The selected
journal is visible before an entry is created.

The user enters a title, optionally chooses meeting, work session or blank notes,
and adds keywords if useful. The entry opens in their preferred editor. Dates,
filenames, folders and the main document's include list are handled for them.

## First use and ownership

On first use, the launcher offers to create a journal or connect an existing
one. Creating a journal copies the clean starter into a chosen folder, with a
cover, editable settings, index and first example entry. It never copies another
person's research notes. Journals in different folders stay independent.

The cover, colors, paper and entry structure are customizable. The settings
contain deliberate overrides, so Satz can supply updated defaults. Journal
content remains ordinary local Typst files, usable without the launcher and
suitable for normal backup, version control and sharing.

## Acceptance criteria

- Starting an entry never requires navigating to a project folder first.
- Creating a second journal never overwrites the first journal or its settings.
- The selected journal is clear before the file is created.
- Meeting and session scaffolds are useful, and blank notes remain available.
- New entries get a date, a safe filename and a main-document include automatically.
- The editor opens the new entry in the context of the whole journal project.
- Existing files are never overwritten by a new-entry action.
- Basic use requires no Python, Node or Go installation.
- Users can keep writing if the launcher is removed.

## Implementation boundary

The journal CLI prototype creates and connects journals, keeps a local registry,
offers a keyboard-accessible multi-journal chooser, and creates entries from
editable per-journal scaffolds. It can run from anywhere and includes commands
to reconnect a moved journal or remove a registration without deleting files.
Graphical shortcuts remain a possible later addition.

The first sharing artifact is a plain starter ZIP. Public executable downloads
need clear versioned releases from the project's repository; unsigned development
builds are review artifacts rather than a finished public installer.

## One-file-first Satz onboarding

The agreed direction is a simple package API and one editable Typst file first.
A CLI should scaffold a working example; a beginner should not have to create
separate config, setup, cover and main files. Larger projects may split their
content and settings later using ordinary Typst imports.

The current executable focuses on journals. A general entry point such as
`satz new report` or `satz new letter` remains a later design option, not an
implemented or committed interface.

The journal starter is a modular project because entries are separate files. The
CLI creates those files and the entry list; a writer can start without setting
up the structure themselves. The one-file-first direction remains relevant to
general Satz onboarding, without being a prerequisite for this journal MVP.
