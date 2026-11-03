// What a call into Hazel costs, in time and in space, for one build of hazel-lib.js
// (^ticket(681): converting JS values directly at the call boundary, ^report(34)'s step 4).
//
//   node --expose-gc --max-semi-space-size=256 bench/boundary.mjs LIB LABEL [SIZES] [ROUNDS]
//
// LIB is a hazel-lib.js; LABEL names it in the output. For each size n:
//   typed    a function with an annotated parameter, (cells : [Cell]) -> 0, given n*n cells
//            from JavaScript: the argument converted, and checked against its annotation
//   untyped  the same without the annotation: the conversion alone
//   held     a function Hazel returned holding a list of n*n numbers, which it reads (not walks)
//            when called from JavaScript: whether a call pays for what the function holds
// and, where the build has Hazel.value (the handles trial), typed again with the cells passed as
// a handle. Time: the median of a call's milliseconds. Space: the bytes one call allocates, read
// from the heap with a young generation big enough that no collection runs during the call, and
// what the held function keeps after a collection.
import fs from "node:fs";
import vm from "node:vm";
import { createRequire } from "node:module";

globalThis.require = createRequire(import.meta.url);
const [lib, label, sizesArg = "8,16,32,64", roundsArg = "1"] = process.argv.slice(2);
vm.runInThisContext(fs.readFileSync(lib, "utf8"), { filename: "hazel-lib.js" });
const H = globalThis.Hazel;
if (typeof gc !== "function") throw new Error("run node with --expose-gc");

const program = `type Cell = (col = Int, row = Int, kind = String) in
let typed = fun (cells : [Cell]) -> 0 in
let untyped = fun cells -> 0 in
let held = fun (xs : [Int]) -> fun (i : Int) -> case xs | [] => 0 | _ :: _ => i end in
(typed = typed, untyped = untyped, held = held)`;
const r = H.run(program);
if (r.errors.length) throw new Error(r.errors.join("\n"));
const { typed, untyped, held } = r.value;

const cellsOf = n => Array.from({ length: n * n }, (_, i) => ({ col: i % n, row: Math.floor(i / n), kind: i % 7 ? "grass" : "water" }));
const median = xs => { const s = [...xs].sort((a, b) => a - b); return s[Math.floor(s.length / 2)]; };

// a call's ms: at least 15 calls, and at least 300 ms of them, after 3 to warm up
const time = call => {
  for (let i = 0; i < 3; i++) call();
  const ms = [];
  const start = performance.now();
  while (ms.length < 15 || (performance.now() - start < 300 && ms.length < 2000)) {
    const t0 = performance.now(); call(); ms.push(performance.now() - t0);
  }
  return median(ms);
};
// the bytes one call allocates: the heap's growth over one call, from just after a collection
const allocated = call => {
  const xs = [];
  for (let i = 0; i < 7; i++) { gc(); const before = process.memoryUsage().heapUsed; call(); xs.push(process.memoryUsage().heapUsed - before); }
  return median(xs);
};
// what a value keeps: the heap after a collection with it, against after one without it
const kept = make => {
  gc(); gc(); const before = process.memoryUsage().heapUsed;
  const v = make();
  gc(); gc(); const after = process.memoryUsage().heapUsed;
  if (v === undefined) throw new Error("unreachable");
  return after - before;
};

const out = [];
const row = (kind, n, ms, bytes, keeps) => {
  const o = { label, build: H.build, kind, n, cells: n * n, ms: +ms.toFixed(4), bytes: Math.round(bytes), ...(keeps !== undefined ? { keeps: Math.round(keeps) } : {}) };
  out.push(o);
  console.log(`BOUNDARY ${label} ${kind} n=${n}: ${o.ms} ms, ${o.bytes} B allocated a call${keeps !== undefined ? `, ${o.keeps} B kept` : ""}`);
};
for (let round = 1; round <= +roundsArg; round++) {
  for (const n of sizesArg.split(",").map(Number)) {
    const cells = cellsOf(n);
    row("typed", n, time(() => typed(cells)), allocated(() => typed(cells)));
    row("untyped", n, time(() => untyped(cells)), allocated(() => untyped(cells)));
    const xs = Array.from({ length: n * n }, (_, i) => i);
    const f = held(xs);
    row("held", n, time(() => f(1)), allocated(() => f(1)), kept(() => held(xs)));
    if (typeof H.value === "function") {
      const h = H.value(cells);
      row("typed, a handle", n, time(() => typed(h)), allocated(() => typed(h)));
    }
  }
}
fs.writeFileSync(`boundary-${label}.json`, JSON.stringify(out, null, 1) + "\n");
