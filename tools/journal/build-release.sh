#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
version=${1:?usage: build-release.sh VERSION [OUTPUT_DIR]}
case "$version" in *[!a-zA-Z0-9._-]*|'') printf 'Invalid version: %s\n' "$version" >&2; exit 1;; esac
output_dir=${2:-"$script_dir/dist/release-$version"}
case "$output_dir" in
	/*) ;;
	*) output_dir=$(pwd)/$output_dir ;;
esac
mkdir -p "$output_dir"
if [ -n "$(ls -A "$output_dir")" ]; then
	printf 'Output directory is not empty: %s\n' "$output_dir" >&2
	exit 1
fi
cache_dir=${TMPDIR:-/tmp}/satz-journal-go-cache
term_dir=$(cd "$script_dir" && GOENV=off GOTOOLCHAIN=local go list -f '{{.Module.Dir}}' golang.org/x/term)
sys_dir=$(cd "$script_dir" && GOENV=off GOTOOLCHAIN=local go list -f '{{.Module.Dir}}' golang.org/x/sys/unix)

build_one() {
	goos=$1
	goarch=$2
	name="journal-$version-$goos-$goarch"
	file=journal
	if [ "$goos" = windows ]; then file=journal.exe; fi
	stage=$(mktemp -d "${TMPDIR:-/tmp}/satz-journal-release.XXXXXX")
	trap 'rm -rf "$stage"' EXIT HUP INT TERM
	(
		cd "$script_dir"
		CGO_ENABLED=0 GOOS="$goos" GOARCH="$goarch" GOENV=off GOTOOLCHAIN=local GOCACHE="$cache_dir" go build -trimpath -ldflags "-X main.version=$version" -o "$stage/$file" .
	)
	cp "$script_dir/../../LICENSE" "$stage/LICENSE"
	cp "$term_dir/LICENSE" "$stage/LICENSE-golang-term"
	cp "$sys_dir/LICENSE" "$stage/LICENSE-golang-sys"
	cp "$script_dir/../../docs/journal-starter.md" "$stage/journal-starter.md"
	cat > "$stage/README.txt" <<'EOF'
Satz Journal

Run journal from a terminal to create or connect a journal. On macOS and
Linux, run ./journal from this folder; on Windows, run journal.exe. To use
it from any folder, place the executable in a directory on your PATH.

Run journal help for commands and journal version for the build version.
See journal-starter.md for the complete guide and template requirements.
This is a development build; verify it on its target platform before sharing.
EOF
	(
		cd "$stage"
		zip -q "$output_dir/$name.zip" "$file" README.txt journal-starter.md LICENSE LICENSE-golang-term LICENSE-golang-sys
	)
	rm -rf "$stage"
	trap - EXIT HUP INT TERM
}

for target in "windows amd64" "windows arm64" "darwin amd64" "darwin arm64" "linux amd64" "linux arm64"; do
	# Intentional word splitting: each fixed target is two safe identifiers.
	set -- $target
	build_one "$1" "$2"
done

if command -v shasum >/dev/null 2>&1; then
	(cd "$output_dir" && shasum -a 256 *.zip > SHA256SUMS)
else
	(cd "$output_dir" && sha256sum *.zip > SHA256SUMS)
fi
printf 'Created platform archives and SHA256SUMS in %s\n' "$output_dir"
