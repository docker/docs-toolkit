#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
dist_dir="$repo_dir/dist"
mkdir -p "$dist_dir"
stage_dir=$(mktemp -d "$dist_dir/package.XXXXXX")
trap 'rm -rf "$stage_dir"' EXIT HUP INT TERM
package_dir="$stage_dir/Docker"

mkdir -p "$package_dir/styles"
cp -R "$repo_dir/styles/Docker" "$package_dir/styles/Docker"

if command -v zip >/dev/null 2>&1; then
  (cd "$stage_dir" && zip -q -r "$dist_dir/Docker.zip" Docker)
elif command -v jar >/dev/null 2>&1; then
  jar --create --file "$dist_dir/Docker.zip" --no-manifest \
    -C "$stage_dir" Docker
else
  echo "Building the package requires zip or jar" >&2
  exit 1
fi

printf 'Created %s\n' "$dist_dir/Docker.zip"
