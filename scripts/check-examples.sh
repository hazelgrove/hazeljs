#!/bin/sh
# Pack the package as npm would publish it, install the tarball into a copy of each example as a
# user would, and run them: Node with require and with import, and the TypeScript declarations
# under tsc --noEmit. The browser page is left installed for a browser to open (the workflow opens
# it in headless Firefox). TSC: a tsc to use (default: npx tsc).
set -e
root=$(cd "$(dirname "$0")/.." && pwd)
work=$(mktemp -d)
tgz=$(cd "$root" && npm pack --silent --pack-destination "$work")
for ex in node-require node-import typescript browser; do
  cp -r "$root/examples/$ex" "$work/$ex"
  (cd "$work/$ex" && npm install --no-audit --no-fund --no-save --offline "$work/$tgz" > /dev/null)
done
(cd "$work/node-require" && node index.js)
(cd "$work/node-import" && node index.mjs)
(cd "$work/typescript" && ${TSC:-npx tsc} -p . && echo "typescript: ok")
echo "browser: $work/browser/index.html"
