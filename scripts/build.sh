#!/usr/bin/env bash
# Build the package's hazel-lib.js from a commit of hazelgrove/hazel.
#
#   scripts/build.sh HAZEL_CHECKOUT COMMIT [BRANCH] [PR_URL]
#   EDITOR=1 scripts/build.sh ...    and Hazel's editor too, into editor/ (hazelgrove/hazeljs#2)
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
# (hazelgrove/hazeljs#2) Hazel's editor from the same commit: its whole app, as Hazel's own Deploy workflow builds it, for
# hazel-listings.js to frame from the package. The app's files, less the library (the package's own hazel-lib.js).
if [ "${EDITOR:-}" = 1 ]; then
  GITHUB_SHA="$commit" "${dune[@]}" build src --profile release
fi

cp "$hazel/_build/default/src/web/www/hazel-lib.js" "$pkg/hazel-lib.js"
chmod 644 "$pkg/hazel-lib.js"
if [ "${EDITOR:-}" = 1 ]; then
  rm -rf "$pkg/editor"
  cp -rL "$hazel/_build/default/src/web/www" "$pkg/editor"
  # (dune's build outputs are read-only, and so is a copy of them)
  chmod -R u+w "$pkg/editor"
  rm -f "$pkg/editor/hazel-lib.js"
  # (what a frame never loads: the build's own files, the bundler's input, a style note, and the tutorial's intro video)
  rm -f "$pkg/editor/dune" "$pkg/editor/prebundle.js" "$pkg/editor/style/README.md" "$pkg/editor/img/hazel-probes-intro.mp4"
  # (hazelgrove/hazeljs#2: nothing from anywhere else) the page's one outside load is Google's Material Icons stylesheet, for
  # the command palette, which embed mode never shows: take it out, then fail the build if the page or a stylesheet still
  # names an outside address (comments aside)
  node -e '
    const fs = require("fs"), path = require("path"), dir = process.argv[1], page = path.join(dir, "index.html");
    const was = fs.readFileSync(page, "utf8");
    const s = was.replace(/\s*<link rel="preconnect" href="https:\/\/fonts\.gstatic\.com\/"[^>]*>/, "")
         .replace(/\s*<link\s+href="https:\/\/fonts\.googleapis\.com\/[^"]*"\s+rel="stylesheet"\s*\/?>/, "");
    if (s !== was) fs.writeFileSync(page, s);
    const outside = f => /(?:src|href)\s*=\s*["\x27]?https?:|url\(\s*["\x27]?https?:|@import\s+(?:url\()?["\x27]?https?:/i
      .test(fs.readFileSync(f, "utf8").replace(/<!--[\s\S]*?-->|\/\*[\s\S]*?\*\//g, ""));
    const walk = d => fs.readdirSync(d, { withFileTypes: true }).flatMap(e => e.isDirectory() ? walk(path.join(d, e.name)) : [path.join(d, e.name)]);
    const bad = walk(dir).filter(f => /\.(html|css)$/.test(f)).filter(outside);
    if (bad.length) { console.error("the editor still loads from outside the package: " + bad.join(", ")); process.exit(1); }
  ' "$pkg/editor"
  chmod -R u+w,go-w "$pkg/editor"
fi
COMMIT="$commit" BRANCH="$branch" PR="$pr" PKG="$pkg/package.json" node -e '
  const fs = require("fs"), p = JSON.parse(fs.readFileSync(process.env.PKG, "utf8"));
  const was = p.hazel || {};
  p.hazel = { commit: process.env.COMMIT, branch: process.env.BRANCH || was.branch, pr: process.env.PR || was.pr };
  fs.writeFileSync(process.env.PKG, JSON.stringify(p, null, 2) + "\n");'

echo "hazel-lib.js built from hazelgrove/hazel at $commit"
echo "  size:    $(wc -c < "$pkg/hazel-lib.js") bytes"
echo "  sha256 without the buildInfo line: $(grep -v '^//# buildInfo:' "$pkg/hazel-lib.js" | sha256sum | cut -d' ' -f1)"
if [ -d "$pkg/editor" ]; then
  echo "  editor/: $(find "$pkg/editor" -type f | wc -l) files, $(du -sb "$pkg/editor" | cut -f1) bytes, from the same commit"
fi
echo "  package.json's hazel field: $(node -p "JSON.stringify(require('$pkg/package.json').hazel)")"
