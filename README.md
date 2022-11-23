resinator
=========

A (very work-in-progress) cross-platform Windows resource-definition script (.rc) to resource file (.res) compiler. The intention is for this to eventually get merged into the Zig compiler as per [this accepted proposal](https://github.com/ziglang/zig/issues/3702).

## Overview / How it will fit into Zig

A Windows resource-definition file is made up of both C/C++ preprocessor commands and resource definitions.

- The preprocessor commands will be evaluated first via Zig (this would be either clang or arocc)
- The preprocessed `.rc` file will be compiled into a `.res` (that's what this project does)
- The `.res` will be linked into executables by Zig's linker

## Goals

Similar to `llvm-rc` and GNU's `windres`, `resinator` aims to be a cross-platform alternative to the MSVC++ `rc` tool.

However, unlike `llvm-rc` and `windres`, `resinator` aims to get as close to 1:1 compatibility with the MSVC++ `rc` tool as possible. That is, the ideal would be:

- The `.res` output of `resinator` should match the `.res` output of the Windows `rc` tool in as many cases as possible (if not exactly, then functionally). However, `resinator` may not support all valid `.rc` files (i.e. `#pragma code_page` support might be limited to particular code pages).
- `resinator` should fail to compile `.rc` files that the Windows `rc` tool fails to compile.

The plan is to use fuzz testing with the `rc` tool as an oracle to ensure that `resinator` generates the same output for every input.

### Intentional divergences from the MSVC++ `rc` tool

- In `resinator`, using the number `6` as a resource type is an error and will fail to compile.
  + The Windows RC compiler allows the number `6` (i.e. `RT_STRING`) to be specified as a resource type. When this happens, the Windows RC compiler will output a `.res` file with a resource that has the format of a user-defined resource, but with the type `RT_STRING`. The resulting `.res` file is basically always invalid/bogus/unreadable, as `STRINGTABLE`/`RT_STRING` has [a very particular format](https://devblogs.microsoft.com/oldnewthing/20040130-00/?p=40813).

### Unavoidable divergences from the MSVC++ `rc` tool

- In `resinator`, splices (`\` at the end of a line) are removed by the preprocessor before checking if any string literals are too long.
  + The Windows RC compiler includes the splice characters in the string literal length check (even though they don't show up in the string literal).

## Status

- Lexer
  + Mostly working for what's been implemented so far. Still possible that this will significantly change pending future discoveries about `.rc` files.
- Parsing
  + Converts the token list into an AST. Supports a few of the simpler resource types (RCDATA, ICON, CURSOR, user-defined), but doesn't handle malformed resources all that well.
- Compiling
  + Converts the AST into the binary `.res` file. Supports most of the resources that the parser supports (RCDATA, ICON, CURSOR, etc).
    + ICON and CURSOR `.ico` parsing is supported, but may not be fully correct yet.
