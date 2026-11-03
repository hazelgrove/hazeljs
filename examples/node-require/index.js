// hazeljs from CommonJS: the README's examples, checked.
const assert = require("node:assert/strict");
const Hazel = require("hazeljs");

assert.deepEqual(Hazel.run("let x = 2 in x * 21"), { errors: [], value: 42 });
assert.equal(Hazel.analyze("1 + true").errors.length, 1);

const rule = Hazel.run(`
  type Cmd = + Done + Flip(Int, Cmd) in
  type Event = + Pull(Int) in
  fun e : Event -> case e | Pull(l) => Flip(l, Done) end`).value;
assert.deepEqual(rule({ tag: "Pull", value: 2 }), { tag: "Flip", value: [2, { tag: "Done" }] });

console.log("node-require: ok,", Hazel.version, "built from", Hazel.build);
