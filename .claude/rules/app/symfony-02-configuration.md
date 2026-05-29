---
paths:
  - "app/src/**/*.php"
---

# Configuration Rules

@see https://symfony.com/doc/current/configuration.html

## Environment Variable Processors

Use typed processors to cast and transform environment variables at the container level:

- `%env(int:MAX_ITEMS)%` — cast to integer
- `%env(json:ALLOWED_IPS)%` — parse JSON string into array
- `%env(resolve:APP_SECRET)%` — resolve references to other environment variables
- `%env(file:CERT_PATH)%` — read the file at the given path as the value
- For database passwords that contain special characters, prefer individual parameter variables over the URL format to avoid encoding issues.

@see https://symfony.com/doc/current/configuration/env_var_processors.html

## .env File Loading Priority (High → Low)

1. `.env.local.php` (compiled cache for production)
2. `.env.{APP_ENV}.local` (e.g., `.env.dev.local`)
3. `.env.{APP_ENV}` (e.g., `.env.test`)
4. `.env.local`
5. `.env`

@see https://symfony.com/doc/current/configuration.html#config-dot-env

## Required .gitignore Entries

The following files must never be committed:

- `.env.local`
- `.env.*.local`
- `.env.local.php`

## Configuration File Format

- Package configuration (`config/packages/`): YAML preferred.
- Service configuration (`config/services.yaml`): YAML preferred.
- Use one format consistently across the team (YAML or PHP — choose one).
- XML is only permitted as an exception when IDE auto-completion requires it.

## Environment Variables (Infrastructure Settings)

Use environment variables for values that differ per machine: database credentials, external API URLs, ports.

- Use the `.env` / `.env.local` / `.env.test` file hierarchy.
- `.env` is committed — it contains non-sensitive defaults and documentation only.
- `.env.local` is **never** committed — it overrides `.env` on the local machine.
- In production, inject variables via the host environment or a secrets manager — not `.env.local`.

@see https://symfony.com/doc/current/configuration.html#config-env-vars

## Secrets (Sensitive Values)

Store API keys, encryption keys, and other sensitive credentials in Symfony's Secrets system.

```bash
php bin/console secrets:set MY_API_KEY
php bin/console secrets:list --reveal   # dev only
```

- Secrets are encrypted at rest in `config/secrets/{env}/`.
- The decrypt key lives outside the repo — never commit it.

@see https://symfony.com/doc/current/configuration/secrets.html

## Parameters (Application Behaviour)

Define options that control application behaviour in the `parameters` block of `config/services.yaml`.

- Always prefix with `app.` to avoid collisions with Symfony's own parameters.
- Format: `app.{purpose}` — e.g., `app.items_per_page`, `app.upload_dir`.

```yaml
# Correct
parameters:
    app.items_per_page: 20
    app.upload_dir: '%kernel.project_dir%/public/uploads'

# Wrong — too vague, no prefix
parameters:
    dir: '../uploads'
```

Inject parameters into services via `#[Autowire]`:

```php
public function __construct(
    #[Autowire(param: 'app.upload_dir')]
    private readonly string $uploadDir,
) {}
```

@see https://symfony.com/doc/current/best_practices.html#use-constants-to-define-options-that-rarely-change

## Constants (Rarely Changing Values)

Define values that almost never change as PHP class constants — not parameters.

```php
#[ORM\Entity]
class Post
{
    public const int ITEMS_PER_PAGE = 20;
    public const int TITLE_MAX_LENGTH = 255;
}
```

Constants are accessible from Twig templates and Doctrine queries, making them more reusable than parameters for domain-level values.
