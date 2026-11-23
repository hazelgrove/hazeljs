// hazeljs from TypeScript: the package's declarations (index.d.ts) under `tsc --noEmit`, strict.
import Hazel, { run, jit, type Result, type HazelValue, type ProgramSpec, type JitResult } from "hazeljs";

const r: Result = run("let x = 2 in x * 21");
const v: HazelValue = r.value;
const errors: string[] = Hazel.analyze("1 + true").errors;

const spec: ProgramSpec = { modules: [{ name: "Main", text: "1 + 2" }] };
const n: number = Hazel.runProgram(spec).ms;

const j: JitResult = jit("fun (x : Int) -> x + 1");
const compiled: boolean = j.compiled;
const js: string | undefined = Hazel.compile("1 + 2").js;

console.log(v, errors.length, n, compiled, js !== undefined);
