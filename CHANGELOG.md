# Changelog

## 0.0.5 (2026-11-06)

`hazel-lib.js` from hazelgrove/hazel at `6c283c8a9f` ([#2719](https://github.com/hazelgrove/hazel/pull/2719)), built on GitHub's machines by the **Build hazel-lib.js** workflow: the same file, byte for byte, as Hazel's own deploy of that commit ([run 42296395095](https://github.com/hazelgrove/hazel/actions/runs/42296395095)). Since 0.0.4's `1ba138ef28`, the library's one change:

- **An object's keys can be in any order.** A JavaScript object passed to a Hazel function meets the parameter's labeled tuple type by label. Before, it met it by position. With keys in another order than the type's fields, each field met another field's type, and a field whose type was not its own stayed stuck under it, so `p.x` on `{y: [1], x: 5}` for `p : (x = Int, y = [Int])` gave `{hazel: ...}` instead of `5`. Only fields of a list or tuple type showed it: with only numbers, every position wanted the same type. (Hazel's own programs never met it: Hazel puts a program's tuples in their types' order before it runs.)

New in the package:

- **`hazel-listings.js`**, the script that turns each `<pre class="hazel">` on a page into Hazel's own editor, with go to definition from one listing to another and each error under the listing it is in. It is the script [Hazel Listings in an Article](https://matthewhammer.org/hazel/reports/044/) describes, and the one that article and [Scripting a JavaScript App in Hazel](https://matthewhammer.org/hazel/reports/043/) use. From a CDN: `https://cdn.jsdelivr.net/npm/hazeljs@0.0.5/hazel-listings.js`. It brings default styles of its own, with no weight, so a page needs no stylesheet for it and can still style it.

README:

- **Hazel's own editor, beside your page:** how the apps show their Hazel in Hazel's tile editor, a frame per module, and what the page and the frames say to each other; listings in an article, with `hazel-listings.js`; where the frame works, and hosting your own copy elsewhere.
- **Values:** an object's keys can be in any order.
- **Examples:** Messed Up Dress Up and the Petri net simulator ([hazeljs-petri-example](https://github.com/matthewhammer/hazeljs-petri-example)), each with pictures, and the two reports. The Petri net's pictures show it as it is now: the rules beside the net, an error under its rule, and full screen. Its section also links the live site, its versions, and its rule files.
- **Limits:** the editor is not in the package; a page starts one Hazel app per listing.

## 0.0.4 (2026-11-03)

`hazel-lib.js` from hazelgrove/hazel at `1ba138ef28` ([#2719](https://github.com/hazelgrove/hazel/pull/2719)), built on GitHub's machines by the **Build hazel-lib.js** workflow: the same file, byte for byte, as Hazel's own deploy of that commit. Since 0.0.3's `0d66c36618`, the library's one change:

- **`ms` is measured.** `analyzeProgram` and `runProgram` say how long the call took; in 0.0.1 to 0.0.3 `ms` read 0, or a little below, because js_of_ocaml moved the first reading of the clock to after the call.

Also, in the repository but not the package:

- `bench/boundary.mjs` and the **Boundary benchmark** workflow: what a call into Hazel costs, in time and space, for several builds of `hazel-lib.js`.
- `scripts/build.sh` builds `hazel-lib.js` from a hazelgrove/hazel commit and records it in `package.json`; the **Build hazel-lib.js** workflow runs it on GitHub's machines and pushes the result to a branch `build/<commit>`. Neither is in the published package.

## 0.0.3 (2026-11-03)

The same `hazel-lib.js` as 0.0.1 and 0.0.2 (hazelgrove/hazel at `0d66c36618`); what changes is the package's description and its README.

- The tagline, in the README, on GitHub and in `package.json`'s description: "Hazel edit boxes that extend ordinary JavaScript programs with custom behavior."
- README: Errors, holes and unfinished code: Messed Up Dress Up's type error as an example, what `analyzeProgram` reports, how the game shows it, and running anyway. Limits: errors name a term, not a place; a stuck value is a debug printout.
- README, Limits: no undo or redo in the library; the page that holds the text keeps its history.
- README: "Is it really Hazel?": how to check that `hazel-lib.js` is what its commit of hazelgrove/hazel compiles to. `scripts/verify-build.sh` rebuilds it and compares, and the **Verify hazel-lib.js** workflow runs that on GitHub. Neither file is in the published package.

## 0.0.2 (2026-11-03)

The same `hazel-lib.js` as 0.0.1 (hazelgrove/hazel at `0d66c36618`); what changes is the package around it.

- npm's page names the right repository: 0.0.1's `repository` pointed at hazelgrove/hazel, Hazel itself, since this repository did not exist yet.
- The package's source has a home: [hazelgrove/hazeljs](https://github.com/hazelgrove/hazeljs) (`repository` and `bugs` point there now; Hazel itself is still [hazelgrove/hazel](https://github.com/hazelgrove/hazel)).
- `examples/`: Node with `require`, Node with `import`, TypeScript (strict, `tsc --noEmit`) and a plain web page, each written as a user would use the package.
- `scripts/check-examples.sh` packs the package, installs the tarball into a copy of each example and runs them; `scripts/check-browser.py` opens the page in headless Firefox; `.github/workflows/check.yml` runs both on Node 18, 20 and 22. Neither file is in the published package.

## 0.0.1 (2026-11-02)

The first prototype. `hazel-lib.js` is built from hazelgrove/hazel at `0d66c36618` (the `js-library-embed` branch, [#2719](https://github.com/hazelgrove/hazel/pull/2719), stacked on [#2711](https://github.com/hazelgrove/hazel/pull/2711)).

- `Hazel.analyze` and `Hazel.run` for a program's text; `Hazel.analyzeProgram` and `Hazel.runProgram` for a program of named modules.
- Values converted both ways, including Hazel functions as JavaScript functions.
- CommonJS, ES module and browser `<script>` entry points; TypeScript types.

Known issues: `ms` reads 0 under Node; a module of about 150 members overflows Node's default stack; a text only the recovering parser can read prints a `SLOW PARSE` line to the console.
