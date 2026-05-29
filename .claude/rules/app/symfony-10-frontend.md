---
paths:
  - "app/src/assets/**/*.js"
---

# Frontend Rules

@see https://symfony.com/doc/current/frontend.html

## AssetMapper (Default Choice)

- Use AssetMapper for all new projects — no bundler (Webpack Encore) required.
- Write modern JS/CSS directly; AssetMapper handles importmap and versioning automatically.
- Configure via `config/packages/asset_mapper.yaml`.

```bash
php bin/console asset-map:compile   # production build
php bin/console importmap:require @hotwired/stimulus
```

@see https://symfony.com/doc/current/frontend/asset_mapper.html

## Stimulus Controllers

All JavaScript behaviour is implemented as Stimulus controllers:

```javascript
// assets/controllers/toggle_controller.js
import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
    static targets = ['content'];
    static values  = { open: Boolean };

    connect() {
        this.openValue = false;
    }

    toggle() {
        this.openValue = !this.openValue;
        this.contentTarget.hidden = !this.openValue;
    }
}
```

```twig
{# Usage in Twig #}
<div data-controller="toggle">
    <button data-action="toggle#toggle">Show / Hide</button>
    <div data-toggle-target="content" hidden>Hidden content</div>
</div>
```

- Register controllers via `assets/controllers.json` (Symfony UX bundle controllers) or `assets/app.js` (custom controllers).
- Use `data-controller`, `data-action`, `data-{identifier}-target`, and `data-{identifier}-{name}-value` HTML attributes as documented.
- Never manipulate the DOM outside a Stimulus controller.

## Symfony UX Bundles

Prefer Symfony UX packages over custom JavaScript where they cover the use case:

| Package | Use case |
|---------|----------|
| `symfony/ux-turbo` | SPA-like navigation without full reload |
| `symfony/ux-live-component` | Reactive components without writing JS |
| `symfony/ux-twig-component` | Reusable Twig+PHP components |
| `symfony/ux-chart-js` | Chart.js charts |
| `symfony/ux-dropzone` | File upload dropzone |

## Webpack Encore (Legacy / Complex Bundling Only)

Use Webpack Encore only when complex bundling is required (code splitting, SASS compilation, etc.):

- JS/CSS sources live in `assets/`.
- `public/build/` is in `.gitignore` — never commit compiled assets.
- Run `yarn encore dev --watch` during development.

## Asset Naming

- CSS entry point: `assets/styles/app.css`.
- JS entry point: `assets/app.js`.
- Stimulus controllers: `assets/controllers/{name}_controller.js`.
- Shared utilities: `assets/js/{name}.js`.

## Tailwind CSS

- Use utility-first classes — no custom CSS unless a utility class truly cannot express the style.
- Configure `content` paths in `tailwind.config.js` to include all Twig templates.
- Never use `@apply` for styles that are used only once — write the utilities inline.

@see https://symfony.com/bundles/StimulusBundle/current/index.html
