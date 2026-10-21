#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
output_dir=${1:-"$script_dir/dist"}
case "$output_dir" in
	/*) ;;
	*) output_dir=$(pwd)/$output_dir ;;
esac
mkdir -p "$output_dir"
cache_dir=${TMPDIR:-/tmp}/satz-journal-go-cache

build_one() {
	goos=$1
	goarch=$2
	name="journal-$goos-$goarch"
	file=journal
	if [ "$goos" = windows ]; then file=journal.exe; fi
	stage=$(mktemp -d "${TMPDIR:-/tmp}/satz-journal-release.XXXXXX")
	trap 'rm -rf "$stage"' EXIT HUP INT TERM
	(
		cd "$script_dir"
		CGO_ENABLED=0 GOOS="$goos" GOARCH="$goarch" GOENV=off GOTOOLCHAIN=local GOCACHE="$cache_dir" go build -trimpath -o "$stage/$file" .
	)
	(
		cd "$stage"
		zip -q "$output_dir/$name.zip" "$file"
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
