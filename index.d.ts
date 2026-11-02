// Types for hazeljs: Hazel as a JavaScript library.

/**
 * A Hazel value as JavaScript sees it, both ways (a function's arguments go
 * back to Hazel the same way):
 * numbers, booleans and strings as themselves; a list as an array; `()` as
 * `null`; a labeled tuple `(x = 1, y = 2)` as an object `{x: 1, y: 2}`;
 * another tuple `(1, true)` as an array; a constructor `A` as `{tag: "A"}`
 * and `B(3)` as `{tag: "B", value: 3}`; a function as a JS function.
 * Anything else (a type, a hole) comes back as `{hazel: "<its printing>"}`.
 */
export type HazelValue =
  | number
  | boolean
  | string
  | null
  | HazelValue[]
  | HazelConstructor
  | HazelOther
  | HazelFunction
  | { [label: string]: HazelValue };

export interface HazelConstructor {
  tag: string;
  value?: HazelValue;
}

export interface HazelOther {
  hazel: string;
}

/** A Hazel function: one argument, or several as a tuple. */
export type HazelFunction = (...args: HazelValue[]) => HazelValue;

export interface Analysis {
  /** The program's error messages. Errors do not stop a run. */
  errors: string[];
}

export interface Result extends Analysis {
  /** The program's value: there even when there are errors, since Hazel evaluates around them. */
  value: HazelValue;
}

/** One module of a program: its name, and its body (its members, with no `in`). */
export interface ProgramModule {
  name: string;
  text: string;
}

export interface ProgramSpec {
  /** Definitions every module sees, ending in `in`. */
  preamble?: string;
  /** In order: each module sees the preamble and the modules before it. */
  modules: ProgramModule[];
  /** What the program gives, seeing every module; `()` if left out. */
  tail?: string;
}

export interface ProgramError {
  /** The module the error is in, or null for the preamble and the tail. */
  module: string | null;
  message: string;
  /** The id of the term the error is on. */
  id: string;
}

export interface ProgramAnalysis {
  /** No errors, no holes and nothing incomplete. */
  ok: boolean;
  errors: ProgramError[];
  /** Each module's holes, by name. */
  holes: Record<string, number>;
  /** The preamble's and the tail's holes. */
  programHoles: number;
  /** Each module's brackets and keywords left open, or closed with no opener. */
  incomplete: Record<string, number>;
  /** The same for the preamble and the tail. */
  programIncomplete: number;
  /** How long the call took, in milliseconds. */
  ms: number;
}

export interface ProgramResult extends ProgramAnalysis {
  value: HazelValue;
}

export interface HazelLib {
  /** The library's own label, for example "0.1 (draft, js-library)". */
  version: string;
  /** The hazelgrove/hazel commit this build is from. */
  build: string;
  analyze(text: string): Analysis;
  run(text: string): Result;
  analyzeProgram(spec: ProgramSpec): ProgramAnalysis;
  runProgram(spec: ProgramSpec): ProgramResult;
}

declare const Hazel: HazelLib;
export default Hazel;
export declare const version: HazelLib["version"];
export declare const build: HazelLib["build"];
export declare const analyze: HazelLib["analyze"];
export declare const run: HazelLib["run"];
export declare const analyzeProgram: HazelLib["analyzeProgram"];
export declare const runProgram: HazelLib["runProgram"];
