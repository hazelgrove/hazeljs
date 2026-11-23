// hazeljs from an ES module: the default export and the named ones are the same functions.
import assert from "node:assert/strict";
import Hazel, { analyze, run, compile, jit } from "hazeljs";

assert.equal(run, Hazel.run);
assert.equal(analyze, Hazel.analyze);
assert.deepEqual(run("let x = 2 in x * 21"), { errors: [], value: 42 });
assert.deepEqual(run("[1, 2, 3]").value, [1, 2, 3]);
assert.equal(run("()").value, null);

// hazel-jit (0.0.10): run compiled, the values as run gives them
assert.equal(jit, Hazel.jit);
assert.equal(compile, Hazel.compile);
const j = jit("(inc = fun (x : Int) -> x + 1, both = fun (xs : [Int]) -> xs @ xs)");
assert.equal(j.compiled, true);
assert.equal(j.value.inc(41), 42);
assert.deepEqual(j.value.both([1, 2]), [1, 2, 1, 2]);
const c = compile("let sq = fun (x : Int) -> x * x in sq(12)");
assert.equal(c.compiled, true);
assert.equal(new Function("$R", c.js)(eval("(" + c.runtime + ")")), 144);

console.log("node-import: ok");
