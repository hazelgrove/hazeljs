#!/usr/bin/env bash
# Is the package's hazel-lib.js really Hazel, built from the commit it names?
#
#   scripts/verify-build.sh HAZEL_CHECKOUT
#
# HAZEL_CHECKOUT is a clone of hazelgrove/hazel with its toolchain set up (see its README).
# The script checks out the commit package.json names (its "hazel" field), builds
# hazel-lib.js there in the release profile with GITHUB_SHA set to that commit, as Hazel's
# own Deploy workflow does, and compares the result with the package's hazel-lib.js.
#
# The comparison skips one line: js_of_ocaml's "//# buildInfo:" comment, which names the
# compiler's version label ("5.9.1" from one install, "5.9.1+5.9.1" from Hazel's opam lock
# file) and nothing about the code. Every other byte must match. Exits 1 if they don't.
set -euo pipefail

pkg="$(cd "$(dirname "$0")/.." && pwd)"
hazel="$(cd "${1:?usage: $0 HAZEL_CHECKOUT}" && pwd)"
commit="$(node -p "require('$pkg/package.json').hazel.commit")"

cd "$hazel"
git cat-file -e "$commit^{commit}" 2>/dev/null || git fetch --quiet origin "$commit"
git checkout --quiet --detach "$commit"
make setup-zarith
if command -v dune >/dev/null; then dune=(dune); else dune=(opam exec -- dune); fi
GITHUB_SHA="$commit" "${dune[@]}" build src/web/www/hazel-lib.js --profile release

built="$hazel/_build/default/src/web/www/hazel-lib.js"
digest() { grep -v '^//# buildInfo:' "$1" | sha256sum | cut -d' ' -f1; }
ours="$(digest "$pkg/hazel-lib.js")"
theirs="$(digest "$built")"

echo "hazelgrove/hazel at $commit"
echo "  the package's hazel-lib.js:  $ours"
echo "  built from that commit:      $theirs"
echo "  (both without their buildInfo line:"
echo "     package: $(grep '^//# buildInfo:' "$pkg/hazel-lib.js")"
echo "     built:   $(grep '^//# buildInfo:' "$built"))"
if [ "$ours" = "$theirs" ]; then
  echo "The same: the package's hazel-lib.js is that commit of Hazel, compiled."
else
  echo "DIFFERENT: the package's hazel-lib.js is not what that commit compiles to."
  exit 1
fi
