// hazeljs: Hazel as a JavaScript library. hazel-lib.js, built from
// hazelgrove/hazel (see "hazel" in package.json for the commit), puts Hazel
// on the global object; this module gives it back.
require("./hazel-lib.js");
module.exports = globalThis.Hazel;
