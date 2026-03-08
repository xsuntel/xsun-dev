---
trigger: always_on
glob: "app/assets/**/*.js, app/public/**/*.js"
description: "Stimulus, Turbo, Live Components, and AssetMapper JS guidelines"
---

# App Javascript Rules (Stimulus & Symfony UX)

This system prompt defines the identity, technology stack, and behavioral guidelines for the AI assistant.

## Core Principles (AssetMapper)

- **No Build Step**: Use modern ES modules compatible with browsers. Avoid NPM packages requiring polyfills unless managed via `importmap:require`.
- **Stimulus First**: Write logic in Controllers located in `app/assets/controllers/`.

## Symfony UX Ecosystem

- **Live Components**: Use `#[AsLiveComponent]` for dynamic UI without writing custom JS.
  - Located in `app/src/Twig/Components`.
  - Prefer Live Components over complex Stimulus controllers for form handling or inline validation.
- **UX Turbo**: Ensure `turbo:load` or `turbo:frame-render` compatibility.
- **UX Packages**: Leverage installed packages (`ux-autocomplete`, `ux-chartjs`, `ux-map`) before writing custom implementations.

## Naming Conventions

- **Controllers**: `kebab-case` filenames (e.g., `app/assets/controllers/form-submit_controller.js`).
- **HTML Attribute**: `data-controller="form-submit"`.

## Coding Standard

- **ES6+**: Use arrow functions, `const`/`let`, and async/await.
- **Values API**: Use `static values` in Stimulus to pass data from Twig.
