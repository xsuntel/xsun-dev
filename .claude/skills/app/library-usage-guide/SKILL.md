---
name: library-usage-guide
description: Use when explaining how to install, configure, or use an external library in this project. Covers Composer packages, npm packages, Symfony bundles, and infrastructure client libraries. Always verifies compatibility with PHP 8.4, Symfony 8, and existing project conventions before recommending.
---

# Library Usage Guide

## Source Citation Rules

Every piece of technical information must cite its source.

| Information type | Required citation |
|-----------------|-------------------|
| API usage | Official docs URL or "see project usage at `{file_path}:{line}`" |
| Configuration options | Exact config file path (e.g. `app/config/packages/framework.yaml:15`) |
| Version | `app/composer.json` or `app/package.json` — never assume |
| Install command | Official docs or `composer.json` `require` / `require-dev` section |
| Bundle registration | `app/config/bundles.php` |

If a version cannot be confirmed from project files, state: "Version not confirmed — check `composer.json` or `composer.lock`."

## Pre-Recommendation Checklist

Before explaining how to use any library, verify all of the following:

1. **Already installed?** — Check `app/composer.json` (`require` / `require-dev`) or `app/package.json`.
2. **PHP 8.4 compatible?** — The project runs PHP 8.4; confirm the package's `require` constraint allows it.
3. **Symfony 8 compatible?** — Confirm the bundle or package supports Symfony `^8.0`.
4. **Conflicts with project rules?** — Cross-check against `.claude/rules/` rule files:
   - `api/rest-rule.md` — no Guzzle, no `curl`; only `HttpClientInterface`
   - `database/postgresql-rule.md` — no `ServiceEntityRepository`; extend `EntityRepository`
   - `CLAUDE.md` Out of Scope — no Laravel, Vue, React, React-adjacent packages
5. **Already abstracted?** — Check if the project wraps the library (e.g. Redis is accessed only via Symfony Cache pools — never `\Redis` directly).

If any check fails, report it before proceeding with usage examples.

## Version Resolution

Resolve versions in this priority order:

```bash
# 1. Exact installed version (locked)
grep '"package/name"' app/composer.lock | head -1

# 2. Required constraint (may allow a range)
grep '"package/name"' app/composer.json

# 3. JS packages
grep '"package-name"' app/package.json
```

Never state a version number without confirming it from one of these sources.

## Installation Guidance

### Composer (PHP)

```bash
# Production dependency
cd app && composer require vendor/package-name

# Development-only dependency
cd app && composer require --dev vendor/package-name

# After installing a Symfony bundle, confirm auto-registration
grep 'BundleClass' app/config/bundles.php
```

### npm / AssetMapper (JavaScript)

This project uses **Symfony AssetMapper**, not webpack/Vite. JavaScript packages are imported via `importmap.php`, not `node_modules` in the traditional sense.

```bash
# Add a JS package via AssetMapper
cd app && php bin/console importmap:require package-name

# Confirm the entry in importmap.php
grep 'package-name' app/importmap.php
```

Do not recommend `npm install` for frontend packages — use `importmap:require` instead.

## Response Format

Structure every library usage response as follows:

---

### {Library Name}

**Version:** `{version from composer.json/package.json}` | **Source:** `app/composer.json`

**Purpose in this project:** One sentence describing the role this library plays.

**Already configured at:** `app/config/packages/{config_file}.yaml` *(if applicable)*

#### Installation

```bash
cd app && composer require vendor/package-name
```

#### Configuration

```yaml
# app/config/packages/{bundle}.yaml
# Source: app/config/packages/{bundle}.yaml:{line}
{bundle_name}:
  option: value
```

#### Usage Example

Show usage as it appears in **this project's patterns** (constructor injection, Symfony attributes, etc.):

```php
use Vendor\Package\SomeClass;
use Symfony\Component\DependencyInjection\Attribute\Target;

public function __construct(
    #[Target('named_service')]
    private readonly SomeClass $service,
) {}
```

**Project reference:** `app/src/{ExistingFile}.php:{line}` *(point to an existing usage in the codebase when one exists)*

---

## Project-Specific Integration Patterns

When explaining library usage, always frame it within the conventions already established in this project:

### HTTP Client Libraries

**Do not recommend** Guzzle, cURL wrappers, or `file_get_contents`. The project uses only `Symfony\Contracts\HttpClient\HttpClientInterface` via scoped named clients:

```yaml
# app/config/packages/framework.yaml
framework:
  http_client:
    scoped_clients:
      my_provider.client:
        base_uri: 'https://api.provider.com'
        timeout: 30
```

### Cache Libraries

**Do not recommend** direct `\Redis` calls or PSR-6/PSR-16 adapters from external packages. All cache access goes through Symfony Cache pools injected with `#[Target]`:

```php
#[Target('cache_pool_{domain}')]
private readonly CacheInterface $cache,
```

### ORM / Database Libraries

**Do not recommend** raw PDO, DBAL-only queries in service classes, or other ORMs. All persistence uses Doctrine ORM via `EntityRepository` (not `ServiceEntityRepository`). Point users to the `database/postgresql-rule.md` rule file for the full constraints.

### Authentication Libraries

The project uses `LexikJWTAuthenticationBundle` for stateless API auth and `scheb/2fa-*` for two-factor. Do not suggest alternative auth libraries unless explicitly asked.

### Pagination

Use `babdev/pagerfanta-bundle` with the Doctrine ORM adapter. Do not suggest `knplabs/knp-paginator-bundle` or manual `LIMIT`/`OFFSET`.

## Deprecated / Prohibited Libraries

State a clear warning if the user asks about any of the following:

| Library | Reason |
|---------|--------|
| `guzzlehttp/guzzle` | Project rule: use `symfony/http-client` only |
| `doctrine/orm` `ServiceEntityRepository` | Project rule: always extend `EntityRepository` directly |
| `react/react`, `vue` npm packages | Out of scope per `CLAUDE.md` |
| Any Laravel package | Out of scope per `CLAUDE.md` |
| Direct `\Redis` class calls | Project rule: use Symfony Cache pools |

Always cite the specific rule file (`.claude/rules/`) when blocking a library recommendation.
