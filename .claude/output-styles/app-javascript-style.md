---
name: Javascript Custom Style
description: JavaScript
keep-coding-instructions: true
---

# Javascript Style Instructions

## Module System (ES Modules — ES2015+)

- Always use ES Module syntax: `import` / `export` — never `require()` / `module.exports`
- Named exports preferred over default exports for utility and helper modules
- Default export only for Stimulus controllers (Hotwire framework convention)
- Dynamic `import()` for lazy-loading and code-splitting where appropriate

## Variable Declarations

- `const` by default — `let` only when reassignment is genuinely required
- Never `var` — block-scoped declarations only

## Functions

- Arrow functions for callbacks, inline transformers, and non-method functions
- Regular `function` declarations for named top-level functions that benefit from hoisting
- Async/await for all Promise-based operations — never raw `.then()` / `.catch()` chains
- Default parameters instead of `arg || fallback` patterns

## Modern Syntax (ES2020 – ES2022)

- Optional chaining `?.` for nullable property or method access
- Nullish coalescing `??` instead of `||` for null/undefined defaults (preserves `0` and `''`)
- Logical assignment `||=`, `&&=`, `??=` for conditional assignment
- Object and array destructuring in function parameters and variable declarations
- Spread operator `...` for array/object merging — never `Object.assign({}, ...)`
- Template literals for string interpolation — never string concatenation with `+`
- `Promise.allSettled()` / `Promise.any()` for concurrent async operations
- Top-level `await` in ES modules (ES2022) — no wrapper IIFE needed
- Private class fields `#field` for encapsulated state — do not use `_prefix` convention

## Class Design (ES2015+ / ES2022)

- Use `class` syntax for Stimulus controllers and all stateful modules
- Extend `Controller` from `@hotwired/stimulus` for every Stimulus controller
- Private class fields `#` for internal state not exposed to the outside
- Static methods only for pure utility functions with no instance dependency

## Stimulus-Specific Conventions

- One controller per behavior — keep controllers small and single-responsibility
- Declare `static targets`, `static values`, and `static classes` arrays at the top of the class
- Use `connect()` / `disconnect()` lifecycle hooks — do not override `constructor()`
- Communicate between controllers via Stimulus outlets or custom DOM events
- Never use `document.querySelector()` inside a controller — always use `this.*Target` references

## Formatting

- Semicolons: omit — ASI is reliable inside ES modules
- Quotes: single quotes `'` for string literals; backticks for template literals
- Indentation: 2 spaces for JavaScript files
- Trailing commas in multi-line arrays and objects (ES5+ compatible)
- Space before function body opening brace `{`; no space between name and `(`
