#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

"$repo_dir/scripts/package.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT HUP INT TERM

cp "$repo_dir/dist/Docker.zip" "$test_dir/Docker.zip"
cp "$repo_dir/fixtures/valid.md" "$test_dir/valid.md"
cp "$repo_dir/fixtures/invalid.md" "$test_dir/invalid.md"
mkdir -p "$test_dir/.vale/styles"

cat > "$test_dir/.vale.ini" <<EOF
StylesPath = .vale/styles
MinAlertLevel = suggestion
Packages = $test_dir/Docker.zip
[*.md]
BasedOnStyles = Docker
EOF

(
  cd "$test_dir"
  vale --no-global --config=.vale.ini sync
  vale --no-global --config=.vale.ini valid.md

  if vale --no-global --config=.vale.ini invalid.md; then
    echo "Expected invalid.md to produce a Vale error" >&2
    exit 1
  fi
)

test -f "$test_dir/.vale/styles/Docker/Avoid.yml"
test -f "$test_dir/.vale/styles/Docker/Capitalization.yml"
test -f "$test_dir/.vale/styles/Docker/CanonicalNames.yml"
test -f "$test_dir/.vale/styles/Docker/IndustryTerms.yml"
