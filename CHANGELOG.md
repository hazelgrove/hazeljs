# Changelog

## 0.0.14 (2026-11-25)

**Published to npm**, the first version there since 0.0.8, so it brings 0.0.9 through 0.0.13 with it: Hazel's editor in the package, `Hazel.jit` and `Hazel.compile`, the converters by declared type, records as plain objects in compiled code, and `Hazel.development` (Matthew, 2026-11-25: "Build and publish", then "I'm ready to release a new npm package, post merge").

**hazel-jit's output, as ReScript and Melange write theirs** (hazelgrove/hazel#2859; Matthew, 2026-11-25, from Hazel reports, report 065):

- **A recursive function's calls of itself in tail position are a loop.** No stack to overflow on a long list: a million-deep count runs compiled. Its variables are declared in each pass, so a closure made in one pass keeps that pass's values.
- **A named function of a tuple pattern takes the parts as JS arguments.** A function bound by a let, a module's member or a recursive definition, whose parameter is a tuple pattern, has a direct form (`f.$d(a, b)`), and a call with its tuple written out goes to it with no array. Its value is still a function of one argument for everyone else (a page, the interpreter, a builtin), so the converters and pages that keep compiled code are unchanged.
- **A constructor without an argument is one constant**, made once (`None`, `Done`), **a module's member is read as its own variable** (`Common.pick` is `pick`, so its calls reach its direct form), and **`==` against a number, string or boolean written out is `===`**.
- **On the games of hazeljs-examples**, each played through its own run of states: through `jit`, the loops and arguments take 0.70 of 0.0.13's time, and the three smaller changes 0.95 of that again (the geometric mean over 14 games). Four ways: hazel-jit now runs the games' rules 4,211 times as fast as the interpreter and 2.9 times as fast as hazel-jit did on 2026-11-19 (each game's own file compiled ahead of time), and takes 4.4 times the time of the same game written by hand in JavaScript (five games), where it took 10.0 times. Report 065, "Four ways, on the games".

**The README, rewritten** around what the package does now: running unfinished programs, compiling finished ones, values both ways, Hazel's editor beside a page, and how fast, with two examples (the hazeljs-examples games and Gnome world, and listings in an article) in place of the long walks through Messed Up Dress Up and the Petri net simulator, which have their own pages and reports.

`hazel-lib.js` and `editor/` are built from hazelgrove/hazel at `2c4a61560f` (branch `hazeljs`, [#2857](https://github.com/hazelgrove/hazel/pull/2857), which merges `hazel-jit`, [#2859](https://github.com/hazelgrove/hazel/pull/2859), at `be44756900`), in one run of the **Build hazel-lib.js** workflow ([run 45650627110](https://github.com/hazelgrove/hazeljs/actions/runs/45650627110)). `hazel-lib.js` is byte for byte the file Hazel's own deploy of that commit serves ([run 45650029904](https://github.com/hazelgrove/hazel/actions/runs/45650029904)), its `//# buildInfo` line too: SHA-256 `1aca6509cf8e22d7a33452c21e944e739ed295bb7d03a3778346ccfa34ab1767` without that line; 2.9 MB, 670 KB gzipped. `editor/` is 68 files, 11.0 MB. Hazel's CI is green on that commit (formatting, strict warnings over its sources and tests, quick and full tests; [run 45650030006](https://github.com/hazelgrove/hazel/actions/runs/45650030006)). Checked in Node against that build: every example in the README gives the answer it shows; a function of a pair called with two arguments and with one array; compiled code's shapes; a million-deep tail call through `jit`; a changed spread copy and a frozen object; `Hazel.development` on and off; and Gnome dig's rules through `jitProgram`, step for step the same as through `runProgram` for 20 steps (70.9 ms a step interpreted, 0.23 ms through `jit`).

Not yet: an `SInt` is still checked at 32 bits in compiled code (64 bits with hazelgrove/hazel#2828).

## 0.0.13 (2026-11-25)

**Built, not published to npm**: 0.0.14 was published in its place the same day, with this version's changes and more. As built, it brings 0.0.9 through 0.0.12 with it: Hazel's editor in the package, `Hazel.jit` and `Hazel.compile`, Hazel on Jane Street Core, and the converters by declared type. Publishing waited on how compiled code holds records (Matthew, 2026-11-24: "let's wait until we settle the ongoing design questions about representation --- ^ticket(847) in particular"). Those five questions are settled (Matthew, 2026-11-24: "A, add direct reads" and "Yes, take the leans"; report 054, "Records the page's way"), and Matthew said to publish (2026-11-25: "Build and publish").

- **Compiled code's own shapes change.** A tuple whose every entry is labeled is now a plain object, `{x: 1, y: 2}`, its keys in the type's order; any other tuple is an array, as before. A list is `null` or a cell `{$h, $t}`, where it was `{h, t}`, and a constructor is `{$c, $v}`, where it was `{c, v}`. A label named `length` or `__proto__`, or starting with `$`, is kept as `$` and the label, so no record has the keys `$h`, `$t`, `$c` or `$v`. `jit` and `run` give a page the same shapes as before; only what `compile` returns changed.
- **A field read is the property itself.** `g.x` compiles to `g["x"]`, behind a check that `g` is an object holding `x` and not a list's cell, where it was a call into the runtime that read every label of every program; the engine can cache the read by the record's shape. On each game's own run in hazeljs-examples, as its page plays, a call through `jit` takes 0.63 of 0.0.12's time (the geometric mean over 14 games; Mahjong solitaire 0.27, Pinball 0.29, Minesweeper 0.46), with every answer the same.
- **The rule for a page, and `Hazel.development(on)`.** What a page gives a compiled function, and what it gets back, it does not change afterwards, as React has it for state; it makes a changed copy instead (`{...r, x: 2}`, `[...xs, 5]`). While `Hazel.development(true)` is on, everything that crosses is frozen, all the way down, so a page that breaks the rule throws where it does (in strict code) rather than getting a wrong answer later. It is off unless a page turns it on, since freezing walks every value that crosses. In `index.d.ts`, `index.mjs` and the README.
- **A function of several parameters called with them spread runs compiled.** `add(2, 3)`, for `let add : (Int, Int) -> Int`, went to the interpreter on every call, because the parameter's type was read with its parentheses; it now runs compiled.

**For a page that keeps compiled code** (the output of `compile`, with converters written by hand, as hazeljs-examples' `compiled.js` files have): it keeps working as it is, since its runtime is in the file with it. When it compiles again with 0.0.13, its converters change to the new shapes: `.$h`, `.$t`, `.$c` and `.$v` for `.h`, `.t`, `.c` and `.v`, and a record read by its labels, not by position.

`hazel-lib.js` and `editor/` are built from hazelgrove/hazel at `20febee548` (branch `hazeljs`, [#2857](https://github.com/hazelgrove/hazel/pull/2857), which merges `hazel-jit`, [#2859](https://github.com/hazelgrove/hazel/pull/2859)), in one run of the **Build hazel-lib.js** workflow ([run 45630954722](https://github.com/hazelgrove/hazeljs/actions/runs/45630954722)). `hazel-lib.js` is byte for byte the file Hazel's own deploy of that commit serves ([run 45540086629](https://github.com/hazelgrove/hazel/actions/runs/45540086629)), its `//# buildInfo` line too: SHA-256 `88517864eb3107ac224d699e2984159a87c79b3c5b593a14ac4b864f8c6bd56b` without that line. `editor/` is 68 files, 11.0 MB. Hazel's CI is green on that commit (formatting, strict warnings over its sources and tests, quick and full tests; [run 45540086735](https://github.com/hazelgrove/hazel/actions/runs/45540086735)). Checked in Node against that build: `jit` and `compile`; compiled code's new shapes; the pattern of 0.0.12's third item answered as `run` answers it; a changed spread copy of an answer and a frozen object; a function of two parameters called with them spread; `Hazel.development` on (an answer frozen, a change throwing) and off; and Gnome dig's rules through `jitProgram`, step for step the same as through `runProgram` for 20 steps (82 ms a step interpreted, 0.28 ms through `jit`).

Not yet: an `SInt` is still checked at 32 bits. SInt with 64 bits everywhere, and overflow an error, was settled on 2026-11-19, and comes with hazelgrove/hazel#2828.

## 0.0.12 (2026-11-24)

**Not published to npm** (Matthew, 2026-11-24: "as far as publishing on npm -- let's wait until we settle the ongoing design questions about representation --- ^ticket(847) in particular"). Built so the branch has its newest jit: records held the page's way, the question publishing waits on, is laid out as five decisions in the Hazel reports' report 054, "Records the page's way".

- **`jit`'s converters go by declared type.** A compiled function's arguments and answer go straight between a page's values and compiled code's shapes, by the function's declared types, with no Hazel values made on the way. Each type's converters remember what they converted, so a value a page hands back (the state a step answered, say) crosses with no descent. On each game's own run in hazeljs-examples, a call through `jit` takes 0.76 of the time of the same game compiled ahead of time with its own converters (the geometric mean over 14 games, report 063, "A game's own run of states").
- **Their memory is links on the objects, not WeakMaps.** A page's object gets a hidden link to its compiled value, not enumerable, so `{...answer}` and `Object.assign` do not carry it into a copy the page then changes; a frozen object, which cannot take one, is remembered in a WeakMap. Mahjong solitaire's run took 15.4 ms through `jit` with WeakMaps and 6.1 ms with links (6.4 ms ahead of time). The rule for a page is the same as before: an object a page gives Hazel, or gets from it, the page does not change; a changed copy is a new value.
- **A pattern by position that meets a labeled entry is the interpreter's.** `let f = fun r -> let (a, b) = r in a - b in f((x = 5, y = 2))` answered 3 through `jit`, where `run` is stuck: the interpreter binds `a` to the labeled entry `x = 5`. A compiled tuple now keeps its labels by index under `Symbol.for("hazel-jit.labels")`, which `Object.keys` and JSON do not see, and such a run stops for the interpreter (hazelgrove/hazel `e0a5925f3b`, `ec2a330996`).

`hazel-lib.js` and `editor/` are built from hazelgrove/hazel at `ec2a330996` (branch `hazeljs`, [#2857](https://github.com/hazelgrove/hazel/pull/2857), which merges `hazel-jit`, [#2859](https://github.com/hazelgrove/hazel/pull/2859)), in one run of the **Build hazel-lib.js** workflow ([run 45469330475](https://github.com/hazelgrove/hazeljs/actions/runs/45469330475)). `hazel-lib.js` is byte for byte the file Hazel's own deploy of that commit serves ([run 45463819390](https://github.com/hazelgrove/hazel/actions/runs/45463819390)): SHA-256 `3e594d15d6c88c5d1e68d332e7eedbe5127c83587b40b9f85da966effdc2ef76` without its `//# buildInfo` line. `editor/` is 68 files, 11.0 MB. Hazel's CI is green on that commit (formatting, strict warnings over its sources and tests, quick and full tests; [run 45463819265](https://github.com/hazelgrove/hazel/actions/runs/45463819265)). Checked in Node against that build: `jit` and `compile`; the pattern above answered as `run` answers it; a changed spread copy of an answer and a frozen object; and Gnome dig's rules through `jitProgram`, step for step the same as through `runProgram` for 20 steps (88 ms a step interpreted, 0.27 ms through `jit`).

Not yet: an `SInt` is still checked at 32 bits (64 bits with hazelgrove/hazel#2828).

## 0.0.11 (2026-11-23)

**Hazel on Jane Street Core** (Matthew, 2026-11-23, on porting the `hazeljs` branch to `dev`'s Core: "Yes, port now"). The `hazeljs` branch on hazelgrove/hazel ([#2857](https://github.com/hazelgrove/hazel/pull/2857)) now has `dev` as of `21da4ae66b`: the move to Jane Street Core (hazelgrove/hazel#2470 through #2477) and two small fixes after it, nothing else. Everything the branch adds was ported to Core with it: hazel-jit's compiler and its way to and from JavaScript, the library, programs of named modules, and the embed. The API is the same as 0.0.10's.

- **A fix the port needed.** Core's `List.init` calls its function from the last index down, where OCaml's own went up from 0. `jit` reads a compiled tuple's labels back by the value at each index, using each label up once found, so in reverse it mixed up fields that JavaScript's `==` takes as equal: `(b = false, a = 0, c = 5)` came back as `{a: false, b: 0, c: 5}`. Fixed before this build (hazelgrove/hazel `98c482395d`), with a test.

`hazel-lib.js` and `editor/` are built from hazelgrove/hazel at `98c482395d` (branch `hazeljs`), in one run of the **Build hazel-lib.js** workflow ([run 45242432003](https://github.com/hazelgrove/hazeljs/actions/runs/45242432003)). `hazel-lib.js` is byte for byte the file Hazel's own deploy of that commit serves ([run 45241590094](https://github.com/hazelgrove/hazel/actions/runs/45241590094)): SHA-256 `d87a978d424df06699bfca949a8529b3a8c716ecc95324c43c375ecb6295b817` without its `//# buildInfo` line. `editor/` is 68 files, 11.0 MB. Hazel's CI is green on that commit (formatting, strict warnings over its sources and tests, quick and full tests). Checked in Node against that build: `jit` and `compile` as the README shows them, and Gnome dig's rules through `jitProgram`, step for step the same as through `runProgram` for 20 steps.

Not yet: an `SInt` is still checked at 32 bits. Its 64 bits come with hazelgrove/hazel#2828, which is on Core too.

## 0.0.10 (2026-11-23)

**Hazel compiled to JavaScript, from the package** (Matthew, 2026-11-23: "have the latest hazel jit work too, so that hazel code can be parsed and jitted from the npm package API as well"), **and an editor that is offline and licensed throughout** ("use the PRs that replace font and logos so that they work offline and obey licensing terms for everything").

- **`Hazel.jit(text)`** runs a program compiled to JavaScript by hazel-jit, and gives its value as `run` does. A function the compiled code made stays compiled, its arguments read by the type it declares; a call it cannot finish (an invalid operation, something indeterminate) is the interpreter's. **`Hazel.compile(text)`** gives the JavaScript itself and its runtime's source, to keep in a file and run without Hazel, as the [hazeljs-examples](https://matthewhammer.org/hazeljs-examples/) games do. `compileProgram` and `jitProgram` do the same for a program of named modules. When hazel-jit does not compile a form (a hole, a test), `compiled` is false and `reason` says why. Types in `index.d.ts`; the README's "Compiled to JavaScript".
- **The editor's font is IBM Plex Sans** (SIL Open Font License), in place of a copy of Helvetica Neue that Hazel had no license to ship (hazelgrove/hazel#2837), and **its icons ship with it** (Material Icons, Apache 2.0; hazelgrove/hazel#2842), so nothing is taken out of the editor's page at build time any more: it names no other host as built. **The licenses go with them**, in `editor/licenses/`, copied from Hazel's own `licenses/` by the build: IBM Plex Sans's and Material Icons', and Source Code Pro's (the code font, Adobe's, SIL Open Font License 1.1), which Hazel had shipped without and now has (hazelgrove/hazel#2857). Hazel's `dev` also dropped a dozen unused icon images and two unused stylesheets since 0.0.9's build, so `editor/` is 63 files of Hazel's where it was 78, and 5 of licenses.
- **Built from one branch, `hazeljs`** on hazelgrove/hazel ([#2857](https://github.com/hazelgrove/hazel/pull/2857)), which tracks everything the package depends on: the library (#2711, #2719), the editable embed (#2814), the font and the icons, hazel-jit's compiler, and `dev` as of just before its move to Jane Street Core.

`hazel-lib.js` and `editor/` are built from hazelgrove/hazel at `7274df28a5` (branch `hazeljs`), in one run of the **Build hazel-lib.js** workflow ([run 45219953158](https://github.com/hazelgrove/hazeljs/actions/runs/45219953158)): `hazel-lib.js` is byte for byte the file Hazel's own deploy of that commit serves ([run 45219934939](https://github.com/hazelgrove/hazel/actions/runs/45219934939)), SHA-256 `e571b30dde55596494c38354360627dfee883cbf2faf8c9dfe1b4cda81442e50` without its `//# buildInfo` line; `editor/` is 68 files, 11.0 MB. Checked in Node against that branch's build: `jit` and `compile` as the README shows them; a division by zero answered as `run` answers it; Gnome dig's rules through `jitProgram`, step for step the same as through `runProgram` (87 ms a step interpreted, 1.4 ms through `jit`).

`build.sh`: the editor's copy is made writable before its page is read (dune's outputs are read-only), the page is written only if something was taken out, and Hazel's `licenses/` is copied into `editor/licenses/`.

Not yet: Hazel's move to Jane Street Core (on `dev` since #2470) is not in this build, and an `SInt` is checked at 32 bits; 64 bits come with hazelgrove/hazel#2828.

## 0.0.9 (2026-11-19)

**Hazel's editor is in the package, and nothing loads from anywhere else** ([hazelgrove/hazeljs#2](https://github.com/hazelgrove/hazeljs/issues/2); Matthew, 2026-11-19: "let's repackage the hazeljs npm package to include the tile editor work, and avoid any dynamic loads from anywhere else"). Through 0.0.8, `hazel-listings.js` framed Hazel's editor from a preview build of a draft branch, `https://build.hazel.org/embed-editable/`, built from another commit than `hazel-lib.js`, which a push to that branch could change under any pinned version, and which took messages only from matthewhammer.org and `localhost`.

- **`editor/`**: Hazel's app, 78 files, 11 MB, built in the same workflow run and from the same commit as `hazel-lib.js`: hazelgrove/hazel at `7fcf33f33a` (branch `hazeljs-editor`: [#2814](https://github.com/hazelgrove/hazel/pull/2814)'s editable embed, with [#2719](https://github.com/hazelgrove/hazel/pull/2719)'s last two commits and a fix for embed mode on a `blob:` page). Without what a frame never loads: the tutorial's intro video, the bundler's input, and Google's Material Icons stylesheet, for a command palette embed mode never shows; the build fails if the editor's page or a stylesheet still names an outside address.
- **`hazel-listings.js` frames the packaged editor by default**, from wherever the script itself was loaded: a CDN, `node_modules`, or your own copy. An npm CDN serves files, not pages (jsDelivr sends `.html` as plain text), so the script reads `editor/index.html`, adds a `<base>` at `editor/`, and frames it from a `blob:` address, which has your page's origin: the frame takes your page's messages on any site, with no list. `data-frame="URL"` frames a copy of Hazel's app at an address of its own, as before.
- **Checked in a browser**, with the listings example (`examples/listings/`) on one origin and the package on another, served as a CDN serves it (`scripts/serve-cors.py`: `.html` as plain text): both listings start in Hazel's editor, and the page and its frames request nothing from any other host.

`hazel-lib.js` is built from `7fcf33f33a`, byte for byte the file Hazel's own deploy of that commit serves ([run 44565698736](https://github.com/hazelgrove/hazel/actions/runs/44565698736)). Since 0.0.8's (`2ab33ebd90`), nothing that analyzes or runs a program has changed; the file differs because two shared modules of the web app did, which the library compiles in but does not call: `JsUtil` (embed mode's address on a `blob:` page) and `Menu` (embed mode's right-click menu opens down).

The **Build hazel-lib.js** workflow builds the editor too, with its new input `editor` ([run 44567106513](https://github.com/hazelgrove/hazeljs/actions/runs/44567106513)).

README: the editor in the package, where the frame works, the editor's size, and how to check the editor against Hazel's own deploy.

## 0.0.8 (2026-11-17)

`hazel-lib.js` is 0.0.7's, unchanged (hazelgrove/hazel at `2ab33ebd90`). `hazel-listings.js`:

- **One button switches every listing between text and Hazel's editor** (Matthew, 2026-11-17: "let's have a single button that toggles from: plain text box (maybe with highlighting though? not there today), hazel edit box"). It replaces 0.0.7's button on each listing. **Edit in Hazel** starts the editors, one at a time in the page's order; **Show as text** shows each listing as it now is, edits and all, and keeps the editors loaded and hidden, so switching back is quick. Text first with `start: "request"`, as in 0.0.7; otherwise the editors start once the first listing is near the screen, as before. `HazelListingsOptions.toggle` puts the button in an element (or a selector's), or leaves it out (`false`); `HazelListings.view("text" | "tiles")` switches from the page's own control, and `HazelListings.view()` says which is showing. A go to definition from the page (`HazelListings.goto`) while the text shows scrolls to the listing that defines the name.
- **The text is highlighted**: keywords, types and constructors, strings, numbers and comments, near the colours of Hazel's editor, in light and dark. As spans in the `<pre>`, so it still reads and copies as text; the colours are CSS variables (`--hazel-type`, `--hazel-string`, `--hazel-number`, `--hazel-comment`), and like the other defaults they have no weight, so a page's own rules win.

## 0.0.7 (2026-11-15)

`hazel-lib.js` from hazelgrove/hazel at `2ab33ebd90` ([#2719](https://github.com/hazelgrove/hazel/pull/2719)), built on GitHub's machines by the **Build hazel-lib.js** workflow ([run 43752808750](https://github.com/hazelgrove/hazeljs/actions/runs/43752808750)): the same file, byte for byte, as Hazel's own deploy of that commit ([run 43750481255](https://github.com/hazelgrove/hazel/actions/runs/43750481255)), SHA-256 `14700f3486537d5e27ef3aef8938641a38fc51b5092f1e3f6adbd2a750a4d948` without its `//# buildInfo` line, as the workflow prints it. Since 0.0.5's `6c283c8a9f`, the library's one change:

- **A JavaScript value goes in by the type the function declares.** An array is a tuple where the parameter's type wants a tuple, and a list where it wants a list. Before, every array was a list, and a list met with a tuple type stays stuck. So `{tag: "Two", value: [3, true]}` never matched `Two(m, t)`, and a function of a pair called with one array `[3, true]` returned `{hazel: ...}` (called with two arguments, `f(3, true)`, it worked). Found writing [hazeljs-oracles](https://github.com/matthewhammer/hazeljs-oracles)' Tarot, whose year-ahead spread passes a labeled tuple instead. The type is read all the way down: a constructor's value by its own type in the sum, a labeled tuple's fields by theirs, a recursive type's own name as the whole type again (a command tree sent back in from JavaScript), and a number as the number type asks. A whole number where a `Float` is expected, `2` for `fun x : Float -> ...`, was an `Int` and stuck there; it is a `Float` now. The parameter's type is its annotation (`fun s : S -> ...`, `fun (m, t) : (Int, Bool) -> ...`) or, at the program's top level, the binding's (`let f : A -> B = fun x -> ...`); with neither, a value goes in as before. Not yet for a module's member typed only by its binding (`let f : (Int, Bool) -> Int = fun (n, t) -> ...` in a module, exported by the tail): one array `[3, true]` still goes in as a list there, so annotate the parameter itself, or call it with two arguments, `f(3, true)` (found 2026-11-16, before 0.0.7 was published).

`hazel-listings.js`:

- **Hazel's editor on request** (2026-11-16): with `window.HazelListingsOptions = { start: "request" }` set before the script loads, or `data-start="request"` on its tag, each listing stays text, with an **Open in Hazel's editor** button that starts the editor there (and a go to definition into a listing starts its editor). Each editor is a whole Hazel app, about 7 MB of JavaScript and some 50 MB of memory; [hazeljs-oracles](https://github.com/matthewhammer/hazeljs-oracles)' pages opened five and four of them as they loaded, and were painfully slow on an older Android phone. Without the option, the listings start as before.

README:

- **Values:** a value going in is read by the declared type.
- **On older or slower devices:** what makes a hazeljs page slow on an older phone, and what to do: the library loaded after the page, one build, whole types declared, few and large calls, the editor on request, a measurement on the device.

## 0.0.6 (2026-11-06)

`hazel-lib.js` is 0.0.5's, unchanged: hazelgrove/hazel at `6c283c8a9f` ([#2719](https://github.com/hazelgrove/hazel/pull/2719)).

`hazel-listings.js`:

- **Long lines break to fit the listing, and again when its width changes** ([hazelgrove/hazeljs#1](https://github.com/hazelgrove/hazeljs/issues/1)). A line longer than its listing is laid out as a pretty-printer would, broken at the outermost places the code allows (before a case's `|`, after a `let`'s `in`, after `,`, after `->` and `=>`, before `then` and `else`, before `++`, ...), each piece indented 2 deeper; only spaces and line breaks change (a long comment becomes several), so the program means what it meant. The editor is sent that copy, and the page keeps its own text, so a wider listing gets its long lines back. It breaks again 300 ms after any change of a listing's width: the window, a divider, full screen. This is Messed Up Dress Up's way of laying out its script panel, as that game's `js/25-scripting.js` has it.
- **The editor is sent the page's code font.** The font of each `<pre class="hazel">` goes to Hazel's editor with its size, so the listing's width is measured, in characters, in the font it is shown in.

README:

- **Listings in an article:** long lines break to fit.
- **The Petri net example:** its net is Hazel too now (`rules/Main.hz`), editable on the page and drawn again after each edit.

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
