# Journal CLI post-MVP roadmap

The journal helper remains a separate executable in the Satz repository. The general Satz CLI remains an open future decision. Journal files stay usable without the executable.

## Implemented

- Home screen, highlighted keyboard chooser, plain-input fallback, no-color mode and entry-prompt cancellation.
- Multiple registered journals, reconnecting, list-only rename and removal, read-only setup check, and editor preferences.
- Open journal and template shortcuts; a separate default template copy that never overwrites a customization.
- List, search and reopen entry files; optional chooser counts and filesystem modification dates; optional platform launcher generation.
- Versioned development archives with checksums, documentation and dependency licenses. Automatic replacement of a journal's bundled Satz runtime remains disabled until a separate safe-update design exists.

See [the starter guide](journal-starter.md) for commands and their limitations.

## Verification and release gates

- The Go suite includes customized-template compilation, cross-entry references, concurrent writes, editor preference, entry discovery, and a subprocess executable workflow. Run `cd tools/journal && go test -count=1 ./...` and `go vet ./...`.
- Run `go test -race -count=1 ./...` on a supported local toolchain.
- Exercise the terminal interface, cancellation and a generated launcher on macOS. The most recent local macOS arm64 run passed; rerun against the final build before release.
- Build versioned archives with `tools/journal/build-release.sh VERSION OUTPUT_DIR` and verify every file with `shasum -a 256 -c SHA256SUMS` or `sha256sum -c SHA256SUMS`.
- Local verification on macOS arm64: the Go suite and race checks passed, the chooser scrolled and cancelled in a 40-by-10 pseudo-terminal with 20 journals, and all six `0.2.0-dev4` archive checksums passed. The extracted macOS arm64 binary reported its embedded version. These archives are unsigned development artifacts.
- **Outstanding:** execute the native test matrix on Linux and Windows as well as macOS and inspect the results. `.github/workflows/journal-cli.yml` is prepared for that purpose, but has not been run merely by creating it locally. Cross-compilation is not native verification.
- **Outstanding for public release:** review installation/signing and release versioning, then publish through the repository's trusted release channel after the native checks pass. No public release has been made by this work.
