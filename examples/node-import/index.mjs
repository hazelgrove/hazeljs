// hazeljs from an ES module: the default export and the named ones are the same functions.
import assert from "node:assert/strict";
import Hazel, { analyze, run } from "hazeljs";

assert.equal(run, Hazel.run);
assert.equal(analyze, Hazel.analyze);
assert.deepEqual(run("let x = 2 in x * 21"), { errors: [], value: 42 });
assert.deepEqual(run("[1, 2, 3]").value, [1, 2, 3]);
assert.equal(run("()").value, null);

console.log("node-import: ok");
