# Cover page API — decisions and open questions

Status: 0.2.1 development. 0.2.0 is published.
Written 10 November 2026 after a long design discussion. Read this before
changing `cover.typ` again.

## Current API

```typst
#cover-page(title: ...)                     // generated, research layout (default)
#cover-page(title: ..., layout: "minimal")  // generated, centered
#cover-page(body: ...)                      // you draw the whole cover
```

Exported names: `cover-page` and `cover-themes`. That is all.

`layout` accepts exactly `"research"` or `"minimal"`. The default is
`"research"`. Passing `title:` generates the cover; passing `body:` supplies
your own content and wins over generated fields. Passing neither fails.

Both modes keep the optional slots `logos`, `footer`, and `footer-left`.

## Decisions taken

1. **One public function.** `research-cover` and `minimal-cover` were deleted.
   They were `.with()` wrappers with no extra capability. They added a third
   concept and the docs disagreed about which name was primary.
2. **Names describe purpose, not geometry.** Rejected `layout: "center"` /
   `"left"`. Users choose an outcome ("give me a cover"), not an alignment.
3. **The designed cover is the default.** `research` (left-aligned accent rule)
   is the go-to. `minimal` (centered, spare) is the opt-in. A user who never
   reads the docs gets the good cover.
4. **`classic` is gone as a name.** It was a *mode* ("you draw it") sitting in
   a list of two *styles*. `body:` now expresses that mode. No enum value.
5. **`layout` stays a string enum of two values.** Not inferred from input,
   because `research` vs `minimal` is a real visual choice.

## Why the previous API failed

- The enum mixed a mode with two styles, so three values read as three
  dimensions of confusion.
- The default was `classic`, inherited from the first implementation. It was
  never chosen. `cover-page(title: ...)` therefore failed, and `title:` was
  silently ignored before the panic.
- The error message described the library's rules, not the caller's mistake:
  "the generated title-page layouts are research and minimal…" never said
  "you passed `title:` and classic ignores it".
- Three names for one function; the reference page described `cover-page` only
  as "a composable cover page with body and footer slots", which is true and
  useless.

## Rejected alternatives

| Option | Why rejected |
|---|---|
| `layout: "center"` / `"left"` | Geometry names. They describe what the code does, not what the author wants. |
| Rename to `cover` | No functional gain. `-page` marks "one page you place before a template", not a show rule like `report`. |
| Keep the old aliases | Compatibility sugar that recreates the third-concept problem. |
| One shared theme table | Covers keep tinted paper; document pages stay white. `document-themes` derives from `cover-themes` and overrides `bg-paper`. Keep it. |
| Infer `minimal` from a missing body | Ambiguous, and it would make `body:` and `title:` share one error path. |

## Open questions

1. **The `body:` slots.** `logos`, `footer`, and `footer-left` survive. Decide
   later whether to keep them, or delete them and publish a short `body:`
   recipe instead. Cost of keeping: about 12 lines.
2. **No implicit inheritance.** A cover cannot read a later `report`'s `theme`
   or `config`. Typst state cannot fix this: the cover precedes the state
   update, and `state.get()` reads the value at that point in document order.
   Only a wrapper that renders both, such as `report(cover: ...)`, could. That
   couples the component to one template and loses "cover anywhere".
   Current answer: pass `theme` and `config` explicitly to both.
3. **Global configuration.** `#let shared = (...)` passed to every call is real
   boilerplate. Typst has no global configuration and a package cannot inject
   `set` rules. A `setup` show rule that stores config in state is possible,
   but it conflicts with a cover that must set its own page and it breaks
   `#show` composition. Not scheduled.
4. **Preprint and IEEE presets.** The "arXiv look" is Computer Modern, single
   column, roughly one-inch margins. It is reproducible with
   `article(config: (page: (columns: 1), typography: (font: "New Computer
   Modern")))`. IEEE needs a real template: Times metrics, fixed margins,
   `Abstract—` run-in, Index Terms, Roman-numeral headings, caption rules.
   Build either one only when a document actually needs it.

## Known rough edges

- A cover does not match its report unless both receive the same `theme` and
  the same `config`. A mismatched font or margin is easy to miss.
- `#let shared = (...)` plus `config: (: ..shared, key: ...)` is enough. The
  exported `merge` is not required for the common case.
- `tools/journal/runtime/` is a pinned snapshot with a recorded source revision.
  It still contains the old cover API. Regenerate it or leave it pinned on
  purpose; do not hand-edit it.
- `docs/archive/research-connectome.typ` refers to the old `research-cover` in a
  comment. Archived, ignored.

## Files that describe this API

`cover.typ`, `lib.typ`, `README.md`, `CHANGELOG.md`,
`docs/site/getting-started/cover-page.md`,
`docs/site/reference/api.md`, `docs/site/reference/templates.md`,
`docs/site/reference/configuration.md`, `docs/configuration-reference.md`.

Change one, check the others.
