---
title: "JavaScript Analysis & Refactoring Guide"
description: "Evaluate the quality of a JavaScript file and provide structured improvement recommendations."
arguments:
    - name: file
      description: "Path to the JavaScript file to analyze"
---

Analyze the following JavaScript file:

**`{{file}}`**

Perform a thorough review across all sections below. For each finding, reference the exact line number(s) and provide a concrete fix or improved code snippet.

---

## 1. Module System & Import Organization

Check the following and flag any violations:

- **ES Module syntax only**: All imports must use `import` / `export` — never `require()` / `module.exports`. Flag any CommonJS usage.
- **Import grouping**: Imports must be ordered and separated by a blank line:
  1. Framework / third-party packages (e.g., `@hotwired/stimulus`, `stimulus-use`)
  2. Local modules (relative paths `./` or `../`)
  - Flag unsorted or ungrouped imports.
- **Named vs. default exports**:
  - Stimulus controllers must use `export default class` (framework convention).
  - Utility and helper modules must use named exports — flag unnecessary `export default` on non-controller modules.
- **Unused imports**: Flag any `import` statement whose binding is never referenced in the file.
- **Dynamic `import()`**: Flag synchronous `import` of heavy modules in a hot path — recommend lazy `import()` for code-splitting.
- **Side-effect-only imports**: Flag bare `import './something'` unless the file is explicitly a side-effect entry point (e.g., polyfills, CSS). Add a comment explaining the intent.

---

## 2. Variable Declarations & Scope

- **`const` by default**: Flag any `let` declaration whose binding is never reassigned — it should be `const`.
- **`var` prohibition**: Flag every `var` declaration — replace with `const` or `let` in the appropriate block scope.
- **Temporal Dead Zone (TDZ)**: Flag any reference to a `let` or `const` variable before its declaration in the same scope.
- **Naming conventions**:
  - `camelCase` for variables, functions, and method names.
  - `PascalCase` for class names and constructor functions.
  - `UPPER_SNAKE_CASE` for module-level constants.
  - `#camelCase` for private class fields.
  - Flag any deviation.
- **`for...in` on arrays**: Flag `for (const key in array)` — use `for...of` or `.forEach()` for array iteration.
- **Shadowed variables**: Flag a variable declared in an inner scope with the same name as an outer-scope binding — it creates confusion and likely indicates a bug.

---

## 3. Modern Syntax (ES2020 – ES2022)

Flag legacy patterns that have modern, safer equivalents:

- **Optional chaining `?.`**: Flag `obj && obj.prop && obj.prop.method()` chains — replace with `obj?.prop?.method()`.
- **Nullish coalescing `??`**: Flag `value || default` when `value` can legitimately be `0`, `''`, or `false` — replace with `value ?? default`.
- **Logical assignment**: Flag manual `if (!x) x = y` patterns — replace with `x ??= y`, `x ||= y`, or `x &&= y`.
- **Destructuring**: Flag repetitive property access (`obj.a`, `obj.b`, `obj.c`) at the top of a function — use object destructuring `const { a, b, c } = obj`.
- **Spread operator**: Flag `Object.assign({}, a, b)` — replace with `{ ...a, ...b }`. Flag `[].concat(arr1, arr2)` — replace with `[...arr1, ...arr2]`.
- **Template literals**: Flag string concatenation with `+` — replace with template literals `` `${value}` ``.
- **`Array.from()` vs. spread**: Flag `Array.from(nodeList)` when `[...nodeList]` is cleaner; use `Array.from()` when a mapping function is needed.
- **`Promise.allSettled()` / `Promise.any()`**: Flag `Promise.all()` when partial failures should not abort the entire batch — use `Promise.allSettled()` instead.
- **Top-level `await`**: Flag IIFE wrappers `(async () => { await ...; })()` in ES module files — use top-level `await` directly (ES2022).
- **Private class fields `#`**: Flag `_prefixed` properties used to signal privacy — replace with true private fields (`#field`).

---

## 4. Functions & Async Programming

- **Arrow functions for callbacks**: Flag `function` expressions used as callbacks, array method arguments, or inline handlers — replace with arrow functions.
- **Named `function` declarations**: Flag anonymous function expressions assigned to `const` at module scope when a named function declaration would improve stack traces.
- **`async/await` over `.then()` chains**: Flag `.then().catch()` chains — rewrite as `async/await` with `try/catch`. Exception: `Promise.all([...]).then()` in a non-async context where `await` would require an IIFE.
- **Unhandled promise rejections**: Flag `async` function calls that are not `await`ed and not `.catch()`ed — unhandled rejections crash the process in modern runtimes.
- **`async` without `await`**: Flag `async function` declarations that contain no `await` expression — the `async` keyword is unnecessary.
- **Error handling in `async` functions**: Flag `try/catch` blocks that catch `Error` generically when a specific error type is detectable — log enough context to diagnose the failure.
- **Default parameters**: Flag `const value = arg || 'default'` at the top of a function body — replace with a default parameter `function fn(arg = 'default')`.
- **Function length**: Flag functions longer than ~30 lines — extract sub-responsibilities into helper functions.

---

## 5. Class Design (ES2015+ / ES2022)

- **`class` syntax**: Flag constructor function patterns (`function MyClass() {}`, `MyClass.prototype.method = ...`) — replace with `class` syntax.
- **Private fields `#`**: Flag `this._field` conventions — replace with `#field` for true encapsulation. Private fields are not accessible outside the class at runtime.
- **Static methods for pure utilities**: Flag `static` methods that reference `this` or instance state — static methods must be pure functions with no instance dependency.
- **No `constructor()` in Stimulus controllers**: Flag `constructor()` overrides in classes that extend `Controller` — use `connect()` / `initialize()` lifecycle hooks instead.
- **`super()` calls**: Flag subclasses that override `constructor()` without calling `super()` first.
- **Class field initializers**: Prefer class field syntax (`#count = 0`) over `this.#count = 0` in `constructor()` for simple default values.

---

## 6. Stimulus Controller Conventions

- **One controller, one behavior**: Flag controllers that manage more than one independent UI behavior — split into separate controllers.
- **Static descriptor arrays at the top**: `static targets`, `static values`, `static classes`, and `static outlets` must be declared as static array/object properties at the top of the class, before any methods.
- **Lifecycle hooks over constructor**: Use `initialize()` for one-time setup, `connect()` for DOM-ready wiring, `disconnect()` for cleanup. Flag any `constructor()` usage.
- **Target references only**: Flag `document.querySelector()`, `document.getElementById()`, or `this.element.querySelector()` inside a controller — always use `this.*Target` or `this.*Targets` instead.
- **Value change callbacks**: Flag manual polling or `setInterval` used to watch for value changes — use `*ValueChanged()` callbacks provided by the Values API.
- **Outlet communication**: Flag direct DOM queries to find and call methods on another controller — use Stimulus outlets (`static outlets = ['other-controller']`) for inter-controller communication.
- **Custom DOM events**: Flag direct method calls between controllers when outlets are not appropriate — dispatch and listen to custom DOM events (`this.dispatch('event-name', { detail: {} })`).
- **`data-action` over inline listeners**: Flag `addEventListener` calls in `connect()` for standard user interactions (click, input, submit) — wire them declaratively with `data-action` attributes in the HTML instead. Reserve `addEventListener` for non-standard events (e.g., `turbo:load`, `keydown` with modifiers).
- **Cleanup in `disconnect()`**: Flag `addEventListener` calls in `connect()` that do not have a corresponding `removeEventListener` in `disconnect()` — they cause memory leaks on Turbo navigation.
- **Controller naming**: Controller filenames must follow `kebab-case` (e.g., `modal_controller.js` should be `modal-controller.js`) and match the `data-controller` attribute value in HTML.

---

## 7. Error Handling

- **Empty `catch` blocks**: Flag `catch (e) {}` or `catch (e) { /* ignore */ }` — every caught error must be logged or re-thrown.
- **Error type specificity**: Flag `catch (e)` when a specific error type (e.g., `TypeError`, `RangeError`, a custom error class) is detectable — narrow the catch scope.
- **`fetch` error handling**: Flag `fetch()` calls that only check `response.ok` without a `catch` for network errors, or that do not handle non-2xx responses explicitly.
- **`JSON.parse` without try/catch**: Flag bare `JSON.parse(str)` — wrap in `try/catch` since malformed JSON throws synchronously.
- **Error context in logs**: Flag `console.error(e)` without contextual information — include the operation name and relevant identifiers: `console.error('Failed to submit form', { formId, error: e })`.
- **Re-throwing**: When an error is caught only to be logged, re-throw it so callers can also handle it: `catch (e) { console.error(...); throw e; }`.

---

## 8. Security

- **`innerHTML` assignment**: Flag `element.innerHTML = userValue` — this is an XSS vector. Use `element.textContent = userValue` for plain text, or sanitize HTML with DOMPurify before inserting.
- **`eval()` usage**: Flag any `eval()`, `new Function(string)`, or `setTimeout(string, ...)` calls — they execute arbitrary code and are never necessary.
- **`document.write()`**: Flag any `document.write()` call — it overwrites the entire document after load and is an XSS risk.
- **Unvalidated URL construction**: Flag string concatenation used to build URLs with user-supplied values — use `URL` / `URLSearchParams` constructors to safely assemble URLs.
- **Sensitive data in `localStorage` / `sessionStorage`**: Flag storage of tokens, passwords, or PII in Web Storage — use server-side session (Redis-backed) or `HttpOnly` cookies instead.
- **`postMessage` without origin check**: Flag `window.addEventListener('message', handler)` that does not validate `event.origin` before processing `event.data`.
- **Third-party script injection**: Flag dynamic `<script>` tag creation from external URLs without Subresource Integrity (`integrity` attribute).

---

## 9. Performance & Memory

- **Event listener leaks**: Flag `addEventListener` in `connect()` without a paired `removeEventListener` in `disconnect()` — Turbo Drive navigates without full page reloads, causing listeners to accumulate.
- **Unbounded `setInterval`**: Flag `setInterval` without a stored reference and a corresponding `clearInterval` in `disconnect()`.
- **`querySelectorAll` in loops**: Flag repeated `querySelectorAll` inside event handlers or loops — cache the result in a variable or use Stimulus targets.
- **Forced layout / reflow**: Flag patterns that read a layout property (e.g., `offsetHeight`, `getBoundingClientRect()`) immediately after a DOM write — batch reads and writes separately to avoid layout thrashing.
- **`async` event listeners**: Flag `element.addEventListener('click', async (e) => { ... })` — unhandled rejections inside async event listeners are silently swallowed. Wrap the body in try/catch.
- **Debounce / throttle for high-frequency events**: Flag `input`, `scroll`, `resize`, or `mousemove` listeners that perform expensive operations (fetch, DOM mutation, computation) without debouncing or throttling.

---

## 10. Code Quality & Duplication

- **DRY principle**: Flag any block of 5+ lines that appears more than once — extract into a shared function or a utility module under `assets/`.
- **Magic numbers and strings**: Flag inline numeric literals (e.g., `setTimeout(fn, 3000)`) or repeated string constants — extract to named `const` at the module level.
- **Dead code**: Flag unreachable code after a `return`, `throw`, or `break` statement. Flag functions, variables, or imports that are defined but never used.
- **Commented-out code**: Flag blocks of code commented out without explanation — either restore with a comment explaining why it is inactive, or delete it.
- **Console statements**: Flag `console.log()` / `console.debug()` left in production-bound code — use a structured logging utility or gate behind a debug flag.
- **Deeply nested callbacks**: Flag callback or promise nesting deeper than 3 levels — flatten with `async/await` or extract inner functions.

---

## 11. Output Format

Provide your analysis in this structure:

### Summary

| Category                    | Status (OK / WARN / FAIL) | Issue Count |
|-----------------------------|---------------------------|-------------|
| Module System & Imports     |                           |             |
| Variable Declarations       |                           |             |
| Modern Syntax (ES2020-2022) |                           |             |
| Functions & Async           |                           |             |
| Class Design                |                           |             |
| Stimulus Conventions        |                           |             |
| Error Handling              |                           |             |
| Security                    |                           |             |
| Performance & Memory        |                           |             |
| Code Quality                |                           |             |

### Critical Issues (must fix)

For each issue: **[Line N]** Description → Recommended fix with code snippet.

### Improvement Suggestions (should fix)

For each suggestion: **[Line N]** Description → Recommended approach.

### Refactoring Proposals

If structural changes are warranted (controller split, utility extraction, async refactor, etc.), describe the proposal with before/after code examples.
