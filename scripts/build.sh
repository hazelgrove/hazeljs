#!/usr/bin/env bash
# Build the package's hazel-lib.js from a commit of hazelgrove/hazel.
#
#   scripts/build.sh HAZEL_CHECKOUT COMMIT [BRANCH] [PR_URL]
#
# HAZEL_CHECKOUT is a clone of hazelgrove/hazel with its toolchain set up (see its README).
# The script checks out COMMIT, builds hazel-lib.js there in the release profile with
# GITHUB_SHA set to the commit, as Hazel's own Deploy workflow does (so Hazel.build names it),
# copies it into this package, and records the commit, its branch and its pull request in
# package.json's "hazel" field, which scripts/verify-build.sh and the README's
# "Is it really Hazel?" read. The "Build hazel-lib.js" workflow runs it on GitHub's machines.
set -euo pipefail

pkg="$(cd "$(dirname "$0")/.." && pwd)"
hazel="$(cd "${1:?usage: $0 HAZEL_CHECKOUT COMMIT [BRANCH] [PR_URL]}" && pwd)"
commit="${2:?usage: $0 HAZEL_CHECKOUT COMMIT [BRANCH] [PR_URL]}"
branch="${3:-}"
pr="${4:-}"

cd "$hazel"
git cat-file -e "$commit^{commit}" 2>/dev/null || git fetch --quiet origin "$commit"
commit="$(git rev-parse "$commit^{commit}")"
git checkout --quiet --detach "$commit"
make setup-zarith
if command -v dune >/dev/null; then dune=(dune); else dune=(opam exec -- dune); fi
GITHUB_SHA="$commit" "${dune[@]}" build src/web/www/hazel-lib.js --profile release

cp "$hazel/_build/default/src/web/www/hazel-lib.js" "$pkg/hazel-lib.js"
chmod 644 "$pkg/hazel-lib.js"
COMMIT="$commit" BRANCH="$branch" PR="$pr" PKG="$pkg/package.json" node -e '
  const fs = require("fs"), p = JSON.parse(fs.readFileSync(process.env.PKG, "utf8"));
  const was = p.hazel || {};
  p.hazel = { commit: process.env.COMMIT, branch: process.env.BRANCH || was.branch, pr: process.env.PR || was.pr };
  fs.writeFileSync(process.env.PKG, JSON.stringify(p, null, 2) + "\n");'

echo "hazel-lib.js built from hazelgrove/hazel at $commit"
echo "  size:    $(wc -c < "$pkg/hazel-lib.js") bytes"
echo "  sha256 without the buildInfo line: $(grep -v '^//# buildInfo:' "$pkg/hazel-lib.js" | sha256sum | cut -d' ' -f1)"
echo "  package.json's hazel field: $(node -p "JSON.stringify(require('$pkg/package.json').hazel)")"
