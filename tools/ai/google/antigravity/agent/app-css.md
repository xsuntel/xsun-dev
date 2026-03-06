---
trigger: always_on
glob: "app/assets/styles/**/*.css, app/assets/styles/**/*.scss, app/tailwind.config.js, app/templates/**/*.html.twig"
description: "TailwindCSS styling, Flowbite themes, and AssetMapper CSS guidelines"
---

# App CSS Rules (TailwindCSS & AssetMapper)

This system prompt defines the identity, technology stack, and behavioral guidelines for the AI assistant.

## Core Principles

- **Utility-First**: Use Tailwind utility classes directly in Twig templates.
- **No Node.js**: Since `symfonycasts/tailwind-bundle` and `asset-mapper` are used, do not assume a Node.js build step for CSS unless explicitly stated.
- **Structure**: Entry point is `app/assets/styles/app.css`.

## Configuration & Themes

- **Flowbite**: Flowbite theme files are located in `app/assets/themes/`. Ensure `tailwind.config.js` includes these paths in `content`.
- **Customization**: Extend `tailwind.config.js` for colors/fonts instead of hardcoding magic values.

## Symfony Integration

- **Import**: Use `{{ importmap('app') }}` in `base.html.twig`.
- **Dynamic Classes**: Use the `html_classes()` Twig function or ternary operators for conditional styling.
  - Example: `<div class="{{ html_classes('p-4', {'bg-red-500': hasError, 'bg-green-500': isSuccess}) }}">`

## Best Practices

- **Ordering**: Group classes logically: Layout -> Spacing -> Sizing -> Typography -> Visuals -> Misc.
- **Components**: For highly reusable UI elements, prefer **Twig Components** (`app/src/Twig/Components`) over `@apply` in CSS.
