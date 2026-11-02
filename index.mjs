// hazeljs as an ES module: the same Hazel object as index.js, as the default
// export and as named exports.
import Hazel from "./index.js";
export default Hazel;
export const { version, build, analyze, run, analyzeProgram, runProgram } = Hazel;
