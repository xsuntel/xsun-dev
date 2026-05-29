---
title: "Shell Script Analysis & Refactoring Guide"
description: "Evaluate the quality of a shell script file and provide structured improvement recommendations."
arguments:
    - name: file
      description: "Path to the shell script file to analyze"
---

Analyze the following shell script file:

**`{{file}}`**

Perform a thorough review across all sections below. For each finding, reference the exact line number(s) and provide a concrete fix or improved code snippet.

---

## 1. Safety & Error Handling

Check the following and flag any violations:

- **Strict mode**: Is `set -euo pipefail` (or equivalent) enabled at the top? If commented out, explain the risk and recommend enabling it with appropriate `|| true` guards where intentional failures are expected.
- **Exit codes**: Do all commands that can fail have their return codes checked or handled?
- **`trap` usage**: Is there a `trap '...' ERR EXIT` handler to clean up temporary files, release locks, or log failure context?
- **`kill` signal**: Does the script use `kill -SIGKILL $$` (unclean termination)? Recommend replacing with `exit 1` or a graceful cleanup function.
- **Pipe failures**: Without `set -o pipefail`, a failing left-hand command in a pipe is silently ignored — flag every pipeline that lacks this guard.
- **Subshell `cd` guard**: Every `cd` must be followed by `|| return` (inside functions) or `|| exit 1` (at top level) to prevent the rest of the script from running in the wrong directory.

---

## 2. Variable Declarations & Quoting

- **Quoting**: Every variable expansion must be double-quoted (`"$VAR"`) unless word-splitting or glob expansion is intentionally required. Flag every unquoted `$VAR`.
- **`local` keyword**: All variables declared inside functions must use `local`. Flag any function-internal variable that modifies the global scope unintentionally.
- **Naming convention**:
  - `UPPER_SNAKE_CASE` for environment variables and exported globals
  - `lower_snake_case` for local function variables
  - Flag any inconsistency.
- **Undefined variable risk**: Without `set -u`, typos in variable names silently expand to empty strings. Flag every variable that is used before being assigned a value.
- **`readonly` / `declare -r`**: Constants that should never change after initialization should be declared `readonly`.

---

## 3. Function Design

- **Single responsibility**: Does each function do exactly one thing? Flag functions longer than ~30 lines that should be split.
- **Naming consistency**: Functions in this project follow `verbNoun()` or `setComponent()` patterns. Flag deviations.
- **Return values**: Functions should communicate success/failure via exit codes (`return 0` / `return 1`), not by printing to stdout and capturing with `$()` unless a value is needed.
- **Documentation**: Each function should have a single-line comment above it explaining its purpose if non-obvious.
- **Avoid global side effects**: Functions should not modify variables outside their scope unless that is their explicit purpose.

---

## 4. Conditional Sourcing Pattern

This project uses a guard pattern for sourcing dependencies:

```bash
if [ -f "${PROJECT_PATH}/scripts/base/_abstract.sh" ]; then
    source "${PROJECT_PATH}/scripts/base/_abstract.sh"
else
    echo "[ ERROR ] File not found: ./scripts/base/_abstract.sh" && exit 1
fi
```

Check:
- Does every `source` call verify file existence first?
- Does the error message include the expected file path?
- Does the failure branch exit with a non-zero code (`exit 1`), not just `exit`?

---

## 5. Directory & Path Handling

- **Project root discovery**: Verify `find_project_root()` (or equivalent) uses `.git` or `.env.app` as markers and walks the directory tree correctly.
- **Absolute paths**: All paths referenced in the script should be constructed from `PROJECT_PATH` or another anchored root — never relative paths from an assumed working directory.
- **Hardcoded paths**: Flag any hardcoded user-specific paths (e.g., `~/.config/...`) that break portability across machines. Recommend environment variable substitution.
- **Directory existence checks**: Before `cd` into any directory, check `if [ -d "$DIR" ]`.

---

## 6. Platform & Environment Portability

- **Shebang**: Should be `#!/usr/bin/env bash` for portability, or `#!/bin/bash` if the path is guaranteed. Flag `/bin/sh` if Bash-specific syntax is used.
- **Platform detection**: Verify `uname -s` returns are handled for all supported platforms (`Linux`, `Darwin`, `Windows`/`MINGW`). Flag any unhandled platform that falls through silently.
- **Environment branching**: Check that `ENVIRONMENT_NAME` comparisons (`prod`, `dev`, `test`) are exhaustive and that the fallback case is handled.
- **GNU vs. BSD utilities**: Commands like `sed`, `date`, `stat` behave differently on Linux vs. macOS. Flag any usage that would break on either platform.

---

## 7. Logging & Output Quality

- **Consistency**: This project uses `[ LABEL ] Message` format with dashed separators. Flag any `echo` output that breaks this convention.
- **stderr for errors**: Error messages must go to stderr: `echo "[ ERROR ] ..." >&2`. Flag errors printed to stdout.
- **Timestamps**: Long-running scripts should log start/end timestamps via `$(date '+%Y-%m-%d %H:%M:%S')`.
- **Verbose mode**: If the script supports a `--verbose` / `-v` flag, debug output must be gated behind it — not always printed.
- **No `echo` in functions that return values**: A function that returns a computed value via `$()` capture must not `echo` anything else, or the caller receives garbage.

---

## 8. Security

- **Input validation**: Any script that accepts arguments (`$1`, `$2`, ...) must validate them before use. Flag missing presence checks and format validation.
- **Command injection**: Flag any place where an external value (argument, env var, file content) is interpolated directly into a command string without sanitization.
- **`eval` usage**: Flag any `eval` statement — it is almost always replaceable with a safer construct.
- **Temporary files**: If `mktemp` is used, verify the temp file is removed in a `trap` handler. Never use predictable names like `/tmp/script.tmp`.
- **Sensitive values in logs**: Flag any `echo` or `printf` that could print passwords, tokens, or API keys.

---

## 9. Code Duplication & Reuse

- Flag any block of 5+ lines that appears more than once — it should be extracted into a reusable function.
- Check if utility functions (logging, platform detection, root discovery) are duplicated across files. In this project, shared logic should live in `scripts/base/_abstract.sh` and be sourced.
- Flag commented-out code blocks — either restore them with an explanation or delete them.

---

## 10. Output Format

Provide your analysis in this structure:

### Summary

| Category | Status | Issue Count |
|----------|--------|-------------|
| Safety & Error Handling | ✅ / ⚠️ / ❌ | N |
| Variable Declarations | ✅ / ⚠️ / ❌ | N |
| Function Design | ✅ / ⚠️ / ❌ | N |
| Sourcing Guards | ✅ / ⚠️ / ❌ | N |
| Path Handling | ✅ / ⚠️ / ❌ | N |
| Portability | ✅ / ⚠️ / ❌ | N |
| Logging & Output | ✅ / ⚠️ / ❌ | N |
| Security | ✅ / ⚠️ / ❌ | N |
| Code Duplication | ✅ / ⚠️ / ❌ | N |

### Critical Issues (must fix)

For each issue: **[Line N]** Description → Recommended fix with code snippet.

### Improvement Suggestions (should fix)

For each suggestion: **[Line N]** Description → Recommended approach.

### Refactoring Proposals

If structural changes are warranted (function extraction, shared utility consolidation, etc.), describe the proposal with before/after code examples.
