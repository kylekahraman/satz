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
- Native Linux, Windows and macOS tests passed in [CI run 42295544505](https://github.com/kylekahraman/satz/actions/runs/42295544505) for source `f3ca453e82d24dcad1b7332d7228033f8cc14800`. Windows additionally repeated the concurrent-entry checks five times. The `0.2.0-dev6` archives were built locally from that exact commit and their six checksums verified; they remain unsigned development artifacts.

## Public distribution review

The development ZIPs contain an executable, installation guide, source revision, and licenses. `journal version` reports the CLI build version; the journal's `_satz/VERSION.txt` separately records its bundled Satz snapshot. For an eventual release, select a CLI version and build from its clean, reviewed source commit; keep the development suffix for prereleases. Publish checksums alongside the artifacts, but do not treat checksums alone as proof of publisher identity.

For macOS distribution outside the App Store, plan for Developer ID signing and Apple's notarization process as described in [Apple's notarization guide](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution). On Windows, evaluate a code-signing certificate and use the Windows SDK's [SignTool](https://learn.microsoft.com/windows/win32/seccrypto/signtool) to sign, timestamp and verify executables. Credentials and signing infrastructure have not been configured; the current archives may trigger operating-system warnings. Linux archives are also unsigned.

Public publication, signing credentials and an official version are decisions for a release. No public release or automatic runtime update has been made by this work.
