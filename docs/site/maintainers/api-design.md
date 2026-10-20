# API design and maintenance

Satz aims to make common document decisions coherent across templates while leaving Typst's native elements and upstream packages available. It is inspired by KOMA-Script; it does not promise a copy of every KOMA class or option.

## Conventions for new APIs

1. **Use semantic template arguments for document identity.** A title, author, recipient, date, or abstract describes the document and belongs in the template function's named arguments.
2. **Use shared `config` for cross-document appearance.** Page geometry, typography, headings, colors, captions, and lists should have one predictable home wherever templates share the document class.
3. **Use component arguments for local choices.** A short caption or callout title belongs on that component, not in a global switch.
4. **Keep native Typst escape hatches.** Do not wrap native figures, tables, headings, or layouts unless Satz adds a useful default or coordinates document behavior.
5. **Document every public export.** Give each argument a type, default, and small example. Keep examples compiling against the version they name.
6. **Treat dependencies as implementation choices.** Pin versions and expose an upstream namespace when a wrapper adds no value. Add a Satz wrapper when it supplies shared defaults or solves integration work.

## Existing differences to resolve carefully

- `report` and `journal-entry` use shared `config`; `article` combines document fields and shared config; `book` offers common style arguments plus advanced config.
- `letter` and `invoice` retain German argument names. Their English aliases do not translate those arguments.
- Some functions take content directly; others use `#show: function.with(...)` to style following document content.
- Template readiness varies. The book and article APIs are still developing, and DFG proposal remains work in progress.

Do not perform a broad rename in a patch release. For 0.2.0, review signatures as a group, identify breaking changes explicitly, and preserve compatibility aliases or provide migration examples where practical.

## When a control belongs in the API

- A real document needs it more than once, or it serves a clear common use case.
- The default is sensible for most users.
- The setting has one clear meaning and does not duplicate a native Typst option.
- It can be documented with an example and checked in a consuming document.

Before adding a key, decide whether it belongs in shared `config`, a template's semantic arguments, a component's local options, or an upstream package. Keep the public surface small enough that a new user can get a good result without reading the full reference.

## Release review

Before release, reconcile the roadmap and changelog, compile documented examples against the release candidate, exercise a report and journal from a fresh project, and visually inspect representative output. Check breaking API changes and dependency versions. Keep generated PDFs and private research documents out of the package.
