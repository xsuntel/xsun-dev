# App CSS Rules (TailwindCSS & AssetMapper)

This system prompt defines the identity, technology stack, and behavioral guidelines for the AI assistant.

## Core Principles

- **Utility-First**: Use Tailwind utility classes directly in Twig templates for most styling. This aligns with the HTML-driven development philosophy of Stimulus and Turbo.
- **No Node.js**: The project uses `symfonycasts/tailwind-bundle` and `asset-mapper`. Do not suggest or assume a Node.js/Webpack build step for CSS. All processing is handled by the Symfony CLI or backend processes.
- **Structure**: The main CSS entry point is `app/assets/styles/app.css`. All custom CSS should be imported here.

## Configuration & Theming

- **Flowbite Integration**: The project uses Flowbite for pre-built UI components. Theme files are located in `app/assets/themes/`. Ensure `tailwind.config.js` correctly includes these paths in its `content` array to enable proper class purging.
- **Customization**: All customizations (colors, fonts, spacing) must be done by extending the `theme` in `tailwind.config.js`. Avoid using arbitrary or "magic" values directly in templates.

## Symfony Integration & Best Practices

- **AssetMapper**: The `importmap.php` file and `{{ importmap('app') }}` Twig function are the primary means of including assets. Do not reference `<link>` tags manually unless for a specific, non-standard use case.
- **Dynamic Classes**: For conditional styling, use the `html_classes()` Twig function. It provides a clean and readable way to apply classes based on backend logic.
  - **Example**: `<div class="{{ html_classes('p-4', {'bg-red-500 text-white': hasError, 'bg-green-100 text-green-800': isSuccess}) }}">`
- **Component Strategy**: Follow the official Symfony UX component selection guide:
    1.  **Static UI**: Pure Twig templates with Tailwind CSS utility classes.
    2.  **Reusable UI Blocks**: For complex, reusable UI elements that don't require client-side state, create a **Twig Component** (in `app/src/Twig/Components`). This is strongly preferred over using `@apply` in a CSS file to simulate components. `@apply` should be used sparingly, if at all.
    3.  **Reactive UI**: For components that need server-bound state and reactivity, use a **LiveComponent**.

## Performance

- **Purging**: The `tailwind-bundle` automatically handles purging unused CSS classes in production environments. Ensure all template paths are correctly listed in `tailwind.config.js` to avoid accidentally removing necessary styles.
- **Class Ordering**: For readability and consistency, group utility classes in a standard order: Layout (display, position) -> Box Model (width, height, margin, padding) -> Typography (font, color, size) -> Backgrounds & Borders -> Effects (shadows, transforms) -> Interactivity (hover, focus).
