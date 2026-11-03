# Changelog

## Unreleased

- `examples/`: Node with `require`, Node with `import`, TypeScript (strict, `tsc --noEmit`) and a plain web page, each written as a user would use the package.
- `scripts/check-examples.sh` packs the package, installs the tarball into a copy of each example and runs them; `scripts/check-browser.py` opens the page in headless Firefox; `.github/workflows/check.yml` runs both on Node 18, 20 and 22. Neither file is in the published package.

## 0.0.1 (2026-11-02)

The first prototype. `hazel-lib.js` is built from hazelgrove/hazel at `0d66c36618` (the `js-library-embed` branch, [#2719](https://github.com/hazelgrove/hazel/pull/2719), stacked on [#2711](https://github.com/hazelgrove/hazel/pull/2711)).

- `Hazel.analyze` and `Hazel.run` for a program's text; `Hazel.analyzeProgram` and `Hazel.runProgram` for a program of named modules.
- Values converted both ways, including Hazel functions as JavaScript functions.
- CommonJS, ES module and browser `<script>` entry points; TypeScript types.

Known issues: `ms` reads 0 under Node; a module of about 150 members overflows Node's default stack; a text only the recovering parser can read prints a `SLOW PARSE` line to the console.
