<p align="center"><img src="https://cdn.jsdelivr.net/gh/hazelgrove/hazeljs@main/hazelnut.svg" width="120" height="120" alt="Hazel's hazelnut logo"></p>

# hazeljs

**[Hazel](https://hazel.org) as a JavaScript library: run Hazel programs in a page or in Node, finished or not, compiled to JavaScript when they are complete, and call their functions from JavaScript.**

Hazel is a typed functional language with holes: it type-checks and runs a program that is not finished, around its holes and errors. That makes it a good language for the parts of an app that people write and change while it runs: rules, scripts, exercises, a game's logic. hazeljs gives a page Hazel's interpreter, hazel-jit (Hazel's compiler to JavaScript), and Hazel's own editor.

```js
const Hazel = require("hazeljs");

const { value: area } = Hazel.jit(`
  type Shape = + Circle(Float) + Rect(Float, Float) in
  fun s : Shape -> case s | Circle(r) => 3.14159 *. r *. r | Rect(w, h) => w *. h end`);

area({ tag: "Rect", value: [2, 3] }); // 6, computed by compiled JavaScript
```

> **Experimental.** A prototype (0.0.x): the API may change in any release. Built from Hazel's branch `hazeljs` ([hazelgrove/hazel#2857](https://github.com/hazelgrove/hazel/pull/2857)) at commit `2c4a61560f` (`Hazel.build` names it), which holds the library ([#2711](https://github.com/hazelgrove/hazel/pull/2711), [#2719](https://github.com/hazelgrove/hazel/pull/2719)), the editable embed ([#2814](https://github.com/hazelgrove/hazel/pull/2814)) and hazel-jit ([#2859](https://github.com/hazelgrove/hazel/pull/2859)).

## What it does

- **Runs unfinished programs.** `Hazel.run` and `Hazel.runProgram` type-check a program and run it with Hazel's interpreter, holes and errors included, and report what is wrong as data: each error with its module, each module's holes, anything left open.
- **Compiles finished ones.** `Hazel.jit` and `Hazel.jitProgram` compile a complete program to JavaScript in the page and run that. Where hazel-jit can't (a hole, a test, an error the interpreter would show), the interpreter runs it, so the answer is the same either way. `Hazel.compile` gives the JavaScript itself, to keep in a file and run without loading Hazel at all.
- **Calls both ways.** A Hazel function is a JavaScript function. Values cross by the types the function declares: records as objects, lists as arrays, constructors as `{tag, value}`.
- **Hazel's own editor, beside your page.** `hazel-listings.js` turns each `<pre class="hazel">` into Hazel's tile editor, with go to definition across listings, all from the package, offline.

## How fast

**On the games of [hazeljs-examples](https://matthewhammer.org/hazeljs-examples/), hazel-jit runs the games' rules 4,211 times as fast as Hazel's interpreter, 2.9 times as fast as hazel-jit did a week earlier, and takes 4.4 times the time of the same game written by hand in JavaScript.** Each game played through its own run of states, as its page plays it, every answer the same all four ways (the geometric mean over 14 games; plain JavaScript for the five games that have a version written by hand).

The five games with all four ways, the time of one call of the game's rule:

| Game | Hazel's interpreter | hazel-jit, 2026-11-19 | hazel-jit now (0.0.14) | plain JavaScript |
|---|---:|---:|---:|---:|
| Checkers | 18.4 ms | 11.5 µs | 11.2 µs | 1.4 µs |
| Go | 74.3 ms | 25.8 µs | 13.2 µs | 4.2 µs |
| Minesweeper | 71.0 ms | 64.9 µs | 8.6 µs | 0.7 µs |
| Mahjong | 22.8 ms | 21.4 µs | 12.4 µs | 8.6 µs |
| Solitaire | 40.7 ms | 10.0 µs | 4.1 µs | 1.1 µs |

- **The interpreter** is `Hazel.runProgram`. **hazel-jit now** is `Hazel.jitProgram`, converting each call's values from the page's shapes and back. **hazel-jit, 2026-11-19** is each game's own file compiled ahead of time a week earlier, with converters written by hand. **Plain JavaScript** is the game written by hand.
- Measured on GitHub's machines (Node 22), one machine a game, all four ways one after another. How, and every game: [Hazel reports, report 65, "Four ways, on the games"](https://matthewhammer.org/hazel/reports/065/#fourway).
- What still separates hazel-jit from plain JavaScript, and what comes next: the same report, [What is still left](https://matthewhammer.org/hazel/reports/065/#left) and [Conversion at the edges](https://matthewhammer.org/hazel/reports/065/#crossing).

## Install

```sh
npm install hazeljs
```

Or in a web page, from a CDN that serves npm packages:

```html
<script src="https://cdn.jsdelivr.net/npm/hazeljs@0.0.14/hazel-lib.js"></script>
<script>
  console.log(Hazel.run("1 + 2").value); // 3
</script>
```

The script defines a global `Hazel`. From Node: `const Hazel = require("hazeljs")`, or `import Hazel, { run, jit } from "hazeljs"`. TypeScript types are included (`index.d.ts`).

## Usage

### Run, even unfinished

```js
Hazel.run("let x = 2 in x * 21");
// { errors: [], value: 42 }

Hazel.analyze("1 + true");
// { errors: ["Error in term:\n  true\nNature of error: Expecting type Int but got inconsistent type Bool"] }
```

A program's errors do not stop it: Hazel evaluates around its holes and errors, so `value` is there either way, and your code decides which errors it accepts. Where an error or a hole stopped the evaluation, that part of the value is `{ hazel: "…" }`, a printout of the term it stopped at.

### Run compiled

`jit` is a drop-in for `run`:

```js
const { value, compiled, reason } = Hazel.jit(`
  let sq : Int -> Int = fun x -> x * x in
  let sum_sq : [Int] -> Int = fun xs -> case xs | [] => 0 | x :: rest => sq(x) + sum_sq(rest) end in
  (sq = sq, sum_sq = sum_sq)`);

value.sum_sq([1, 2, 3]); // 14
```

- **The same values as `run`.** A function the compiled code made stays compiled; its arguments are read by the type it declares, straight into compiled code's shapes, and its answer comes back the same way.
- **The interpreter covers the rest.** A call the compiled code can't finish (dividing by zero, something indeterminate, a run past its budget) is run by the interpreter, and its answer returned. A program hazel-jit doesn't compile at all (it has a hole or a test) has `compiled: false`, `reason` names the form, and `value` is the interpreter's.
- **Ahead of time.** `compile` returns `js`, the body of a function of `$R`, and `runtime`, the source of the object to pass as `$R`: `new Function("$R", js)(eval("(" + runtime + ")"))` is the program's value, in hazel-jit's own shapes (below). Keep the two strings in a file and the page runs the program without Hazel.

### A program of modules

For a page with an editor per module, hand Hazel the texts and let it build one program:

```js
const result = Hazel.runProgram({
  preamble: "type Cmd = + Done + Say(String) in",   // what every module sees, ending in `in`
  modules: [
    { name: "Common", text: "let greet = fun (s : String) -> Say(s)" },
    { name: "Room", text: "let on_event = fun (n : Int) -> Common.greet(\"hi\")" },
  ],
  tail: "Room.on_event",                             // what the program gives
});

result.ok;       // true: no errors, no holes, nothing left open
result.value(1); // { tag: "Say", value: "hi" }
```

Each module sees the preamble and the modules before it (`Common.greet`), and the tail sees them all. `jitProgram` and `compileProgram` take the same spec. The answer says what is not ready, where:

- `errors`: `[{ module, message, id }]`, `module` the module the error is in (`null` for the preamble and the tail);
- `holes`: each module's holes, by name, and `programHoles`, the preamble's and the tail's;
- `incomplete`: each module's brackets and keywords left open, and `programIncomplete`;
- `ok`: none of these. A function still being written can have holes and no errors, so act on `value` only when `ok`.

Hazel remembers the texts of the last program it read, so after one module changes, only that module is read again.

## API

| Call | Returns |
|---|---|
| `Hazel.analyze(text)` | `{ errors }`, the program's error messages |
| `Hazel.run(text)` | `{ errors, value }` |
| `Hazel.jit(text)` | `{ errors, compiled, reason, value, ms }`: run compiled, the value as `run` gives it |
| `Hazel.compile(text)` | `{ errors, compiled, js, runtime, reason, ms }`: the JavaScript itself |
| `Hazel.analyzeProgram(spec)` | `{ ok, errors, holes, programHoles, incomplete, programIncomplete, ms }` for a program of modules |
| `Hazel.runProgram(spec)` | the same, and `value` |
| `Hazel.jitProgram(spec)`, `Hazel.compileProgram(spec)` | `analyzeProgram`'s fields, and `jit`'s or `compile`'s |
| `Hazel.development(on)` | while on, what crosses into and out of compiled functions is frozen (below) |
| `Hazel.version`, `Hazel.build` | the library's label, and the hazelgrove/hazel commit it is built from |

## Values

| Hazel | JavaScript, as `run` and `jit` give and take it | Compiled code's own shapes (`compile`) |
|---|---|---|
| `Int`, `Float` and the other numbers | number | number (an `Int` past 2^53, a `BigInt`) |
| `Bool`, `String` | boolean, string | the same |
| a record `(x = 1, y = 2)` | an object `{x: 1, y: 2}` | the same object |
| another tuple `(1, true)` | an array `[1, true]` | an array |
| a list | an array | `null`, or a cell `{$h, $t}` |
| a constructor `A`, `B(3)` | `{tag: "A"}`, `{tag: "B", value: 3}` | `{$c: "A"}`, `{$c: "B", $v: 3}` |
| a function | a JavaScript function: one argument, or a tuple's parts as several | a function of one argument; a named one of a tuple also has `$d`, the parts as arguments |
| `()` | `null` | |

A value going into a Hazel function is read by the type the function declares (`fun s : Shape -> ...`, or `let f : A -> B = ...`): an array is a tuple where the type wants a tuple and a list where it wants a list, an object meets a record's fields by label in any order, and a whole number is a `Float` where a `Float` is wanted. With no type declared, an array is a list and a whole number an `Int`, so declare the parameter's type where a tuple or a `Float` comes from JavaScript.

**Don't change what crosses.** What your page gives a compiled function, and what it gets back, the page does not change afterwards, as React has it for state: make a changed copy instead (`{...state, x: 2}`, `[...xs, 5]`). The library keeps a record of plain values as your own object, and remembers what it converted, which is much of why a call is fast; changing one would change a Hazel value under the compiled code. While you develop, `Hazel.development(true)` freezes everything that crosses, all the way down, so a change throws where it happens (in strict code). It is off unless you turn it on.

## Examples

### Games and activities whose rules are Hazel

**▶ [hazeljs-examples](https://matthewhammer.org/hazeljs-examples/)** ([source](https://github.com/matthewhammer/hazeljs-examples)): oracles (an I Ching, a Tarot, an astrology chart), board and card games (Checkers and Go with Hazel opponents, Minesweeper, Mahjong, Solitaire), arcade games, and Gnome world. Each page keeps its state and draws it in JavaScript, and calls its rules, written in Hazel, on each event: compiled by hazel-jit when the page loads, or interpreted while you edit them in Hazel's editor beside the game.

<img src="https://matthewhammer.org/hazel/reports/065/img/gnome-world.jpg" width="720" alt="Gnome world: on the left, the world's vocabulary in Hazel (record types for a ground, a layer, a place, a plan, a room, a gnome and its moves); on the right, the game: a gnome among trees and burrows, the buttons to play it, and the line saying Hazel's rules were compiled by hazel-jit as the page loaded, the gnome's step about 0.088 ms.">

In [Gnome world](https://matthewhammer.org/hazeljs-examples/world/), Hazel plans the world from a seed and moves the gnome sixty times a second: its rules compile as the page loads, and the gnome's step takes about a tenth of a millisecond.

### Listings in an article

For an article or a blog post, `hazel-listings.js` turns each `<pre class="hazel">` into Hazel's own editor:

```html
<pre class="hazel" data-program="shapes">type Shape = + Circle(Float) + Rect(Float, Float) in</pre>
<pre class="hazel" data-program="shapes" data-module="Geometry">let area = fun s : Shape ->
  case s
  | Circle(r) => 3.14159 *. r *. r
  | Rect(w, h) => w *. h
  end</pre>
<script src="https://cdn.jsdelivr.net/npm/hazeljs@0.0.14/hazel-listings.js"></script>
```

- **One program per name.** Listings with the same `data-program` are one program: the one without `data-module` is its preamble, each other a module. Go to definition works across them (Ctrl or ⌘-click, F12), and each error shows under the listing it is in.
- **Text first, the editor when asked.** One button switches every listing between highlighted text and Hazel's editor; with `data-start="request"` on the script tag, the listings start as text. Each editor is a whole Hazel app, so on a phone, start as text.
- **The page can follow edits:** `HazelListings.onChange(program, fn)` calls `fn` with the program after each edit, in the form `runProgram` takes.
- **Offline, on any site.** The editor (`editor/`, 68 files, 11 MB) is in the package, built from the same commit as `hazel-lib.js`; nothing loads from anywhere else. The frames are made from `blob:` addresses with your page's origin, so a page whose Content Security Policy limits frames must allow `blob:` in `frame-src`.

The guide, itself such a page: [Hazel Listings in an Article](https://matthewhammer.org/hazel/reports/044/). A page can also frame Hazel's editor itself and talk to it by `postMessage`; the protocol is in Hazel's [docs/hazel-as-a-js-library.md](https://github.com/hazelgrove/hazel/blob/hazeljs/docs/hazel-as-a-js-library.md).

## Fast on any device

- **Compile what is finished.** `Hazel.jit` runs a complete program thousands of times as fast as the interpreter; `Hazel.compile`, ahead of time, lets a page skip loading Hazel altogether.
- **Load the library after the page.** `hazel-lib.js` is about 2.9 MB (670 KB gzipped). Load it `async` once the page has drawn, and let the page's own JavaScript answer until Hazel is ready.
- **Build once.** Reading and analyzing a program is the costly step (half a second for a few hundred lines on a laptop, several seconds on an older phone). Build when the page loads and after an edit, never on every key press; calling the functions it returns is what to do often.
- **Declare each function's whole type,** what it returns as well as what it takes: `let take : ([Card], Int) -> (Card, [Card]) = fun (cs, k) -> ...`. Values cross by it, the interpreter's steps are several times cheaper with it, and a call through `jit` reads its arguments by it.
- **Hand back what you were given.** A value that crossed before crosses again for nothing, so a page that passes the last answer back as the next call's state is faster than one that rebuilds it each time.

## Is it really Hazel?

What you can check is that `hazel-lib.js` is exactly what Hazel's source compiles to, at a commit you can read. `Hazel.build` names the commit, and so does the `hazel` field of `package.json`: for this release, `2c4a61560f22850146835684331f33992d21e9a6`, on Hazel's branch `hazeljs`.

- **Rebuild it and compare:** with a clone of [hazelgrove/hazel](https://github.com/hazelgrove/hazel) and its toolchain, `scripts/verify-build.sh path/to/hazel` builds that commit as Hazel's Deploy workflow does and compares the files. Every byte matches except one comment line, `//# buildInfo:`, where js_of_ocaml names its version. Without that line, this release's file has the SHA-256 `1aca6509cf8e22d7a33452c21e944e739ed295bb7d03a3778346ccfa34ab1767`.
- **Or let GitHub rebuild it:** this repository's **Verify hazel-lib.js** workflow runs the same script on GitHub's machines, from a fresh clone of Hazel, and anyone can run it.
- **Hazel's own CI built it too:** Hazel's deploy of that commit ([run 45650029904](https://github.com/hazelgrove/hazel/actions/runs/45650029904)) is this release's file, byte for byte, served at `https://build.hazel.org/hazeljs/hazel-lib.js` until the branch moves on.

That shows where the file came from, not that the code at that commit does what you want; for that, read it, or trust the people who wrote it.

## Limits

- **Experimental.** No promise of stability yet; pin an exact version.
- **Synchronous.** Every call runs on the calling thread; a long-running program blocks it. A compiled run stops at its budget, and the interpreter's answer is returned.
- **One global.** The library puts one `Hazel` object on the global object.
- **No undo.** The library holds no editor of its own; the page keeps its texts, and passes an older one again to go back.
- **Errors name a term, not a place.** An error's `id` is its term's id in Hazel's syntax tree; no line and column yet. A stuck value is an OCaml printout of the term, not Hazel syntax.
- **Deep programs need a bigger stack.** In Node, a module of about 150 members overflows the default stack: run `node --stack-size=32000`, with the shell's limit raised to match (`ulimit -s 65536`).
- **An `SInt` is checked at 32 bits** in compiled code for now; 64 bits come with hazelgrove/hazel#2828.
- **The editor is most of the package:** `editor/` is 11 MB of its 14, loaded only when a listing's editor starts.

## About Hazel

Hazel is developed by the Hazel team: see [hazel.org](https://hazel.org) for the project, its papers and the people who make it, and the [contributors on GitHub](https://github.com/hazelgrove/hazel/graphs/contributors). Its source is [hazelgrove/hazel](https://github.com/hazelgrove/hazel), and questions and bugs go to its [issue tracker](https://github.com/hazelgrove/hazel/issues). What changed in each version of this package: [CHANGELOG.md](CHANGELOG.md).

## License

MIT, as Hazel is. See [LICENSE](LICENSE).
