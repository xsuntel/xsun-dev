---
paths:
  - "app/src/**/*.php"
---

# Architecture Rules

@see https://symfony.com/doc/current/best_practices.html#use-the-default-directory-structure

## Directory Structure

Always follow the standard Symfony directory layout. The Symfony application root is `app/`.

```text
symfony-scripts/                             # Repository root
└── app/
    └── src/                                 # PHP source code (Namespace: App\)
        ├── ApiResource/                     # API Platform resource classes
        ├── Command/                         # Symfony Console Commands
        ├── Controller/                      # HTTP Controllers (thin glue only)
        ├── DataFixtures/                    # DoctrineFixturesBundle fixture classes
        ├── Entity/                          # Doctrine Entities (PostgreSQL)
        ├── EntityRepository/                # Doctrine Repository classes
        ├── EventListener/                   # Single-event listeners (#[AsEventListener])
        ├── EventSubscriber/                 # Multi-event subscribers (getSubscribedEvents)
        ├── Form/                            # Symfony Form types
        ├── MessageCommand/                  # Messenger write-side messages (Commands)
        ├── MessageCommandHandler/           # Handlers for MessageCommand classes
        ├── MessageEvent/                    # Messenger domain events
        ├── MessageEventHandler/             # Handlers for MessageEvent classes
        ├── MessageQuery/                    # Messenger read-side messages (Queries)
        ├── MessageQueryHandler/             # Handlers for MessageQuery classes
        ├── Messenger/                       # Shared Messenger middleware / stamps
        ├── Scheduler/                       # Symfony Scheduler periodic tasks
        ├── Serializer/                      # Custom Symfony Serializer normalizers
        ├── Service/                         # Application and domain services
        ├── Twig/                            # Twig extensions and components
        ├── CLAUDE.md
        ├── Kernel.php
        └── Schedule.php
```

## Environments

- Three built-in environments: `dev`, `prod`, `test`.
- Per-environment configuration: `config/packages/{env}/` directory or `when@{env}:` key in YAML.
- The active environment is determined by the `APP_ENV` environment variable.

@see https://symfony.com/doc/current/configuration.html#configuration-environments

## Kernel

- `src/Kernel.php` is the application entry point.
- `HttpKernel` handles the full Request → Response conversion cycle.
- Always consult the official documentation before modifying the Kernel.

@see https://symfony.com/doc/current/components/http_kernel.html

## Bundle Policy

- **Prohibited**: Creating Bundles to separate application logic.
- **Allowed**: Extracting truly reusable, cross-project packages as Bundles (private repo).
- Organize code logically with PHP namespaces — not with Bundles.

@see https://symfony.com/doc/current/best_practices.html#don-t-create-any-bundle-to-organize-your-application-logic

## Listener vs. Subscriber

- Use `EventListener` + `#[AsEventListener]` when a class handles **exactly one** kernel or domain event.
- Use `EventSubscriber` + `getSubscribedEvents()` when a class handles **multiple** events.

This distinction keeps single-responsibility clear and avoids unnecessary boilerplate.

## Domain Hierarchy

The project is divided into the following top-level domains. Every `app/src/` subdirectory mirrors this hierarchy exactly.

| Domain               | Purpose                                                      |
| -------------------- | ------------------------------------------------------------ |
| `Abstract`           | Shared base logic (Users, Base, Connect) — no business logic |
| `Company`            | Company-facing pages and content                             |
| `Partners`           | Partner/store management                                     |
| `Products`           | Product catalog                                              |
| `Providers/Data`     | External data provider integrations (generic)                |
| `Providers/Finance`  | Financial provider integrations (example, example)           |
| `Providers/Property` | Property/real-estate provider integrations (VWorld)          |
| `Resources`          | Content resources (Blog, Developers, YouTube)                |
| `Team`               | Internal team tooling (Agents, Support)                      |
| `Tools`              | Application tools (Chat, Email)                              |

## Namespace → Directory Mapping

Every PHP class namespace maps 1:1 to the filesystem path under `app/src/`:

```
App\{Layer}\{Domain}\{Name}
→ app/src/{Layer}/{Domain}/{Name}.php
```

For deeply nested provider entities, the full provider path is preserved:

```
App\Entity\Providers\Finance\App\Securities\example\Domestic\Stock\API\REST\Enterprise\ChkHoliday
→ app/src/Entity/Providers/Finance/App/Securities/example/Domestic/Stock/API/REST/Enterprise/ChkHoliday.php
```

- **Never flatten** deeply nested provider namespaces for convenience — the path reflects the external provider's API hierarchy.
- **Never create** files in `app/src/` directly without a domain subdirectory — every class belongs to a domain.

## Cross-Domain Rules

- A domain class may depend on `Abstract` classes.
- A domain class **must not** depend on another domain's internal classes (e.g., `Company` must not import from `Partners`).
- Cross-domain data sharing must go through shared Entities or MessageQuery dispatches — never direct Service injection across domains.
- `Providers/*` domains are read-only data sources — they expose data via MessageQuery, never via direct Entity writes from other domains.

## Layer Placement Rules

| What you're building                    | Correct layer                              | Example path                                                              |
| --------------------------------------- | ------------------------------------------ | ------------------------------------------------------------------------- |
| Database record                         | `Entity`                                   | `app/src/Entity/Providers/Finance/.../ChkHoliday.php`                     |
| DB query logic                          | `EntityRepository`                         | `app/src/EntityRepository/Providers/Finance/.../ChkHolidayRepository.php` |
| Write async operation                   | `MessageCommand` + `MessageCommandHandler` | `app/src/MessageCommand/Providers/Finance/...`                            |
| Read async operation                    | `MessageQuery` + `MessageQueryHandler`     | `app/src/MessageQuery/Providers/Finance/...`                              |
| Domain event / side effect              | `MessageEvent` + `MessageEventHandler`     | `app/src/MessageEvent/Providers/Finance/...`                              |
| Reusable business logic                 | `Service`                                  | `app/src/Service/Providers/Finance/...`                                   |
| HTTP request handling                   | `Controller`                               | `app/src/Controller/Providers/Finance/...`                                |
| Background task                         | `Scheduler`                                | `app/src/Scheduler/Providers/Finance/...`                                 |
| Serialization format                    | `Serializer`                               | `app/src/Serializer/Providers/Finance/...`                                |
| Input form                              | `Form`                                     | `app/src/Form/Providers/Finance/...`                                      |
| Domain event listener (multiple events) | `EventSubscriber`                          | `app/src/EventSubscriber/Providers/Finance/...`                           |
| Kernel event listener (single event)    | `EventListener`                            | `app/src/EventListener/Providers/Finance/...`                             |

Use `EventSubscriber` when a class listens to multiple events via `getSubscribedEvents()`.
Use `EventListener` with `#[AsEventListener]` when a class handles exactly one event — it's simpler and avoids boilerplate.

## Naming Conventions

- **Classes**: PascalCase, no suffix except for the layer suffix required by convention:
  - Repositories: `{Name}Repository`
  - Handlers: same class name as the message it handles (suffixed at handler layer folder level)
  - EventSubscribers: `{Name}Subscriber`
  - EventListeners: `{Name}Listener`
  - Form types: `{Name}Type`
  - Twig components: `{Name}` (no suffix)
- **Enums**: `{DescriptiveName}Enum` (e.g., `OrdersStatusEnum`, `TwoFactorTypeEnum`).
- **Routes**: `{domain}_{subdomain}_{action}` in snake_case (e.g., `providers_finance_korea_investment_list`).
- **Twig templates**: mirror the controller path — `templates/{domain}/{subdomain}/{action}.html.twig`.

## Abstract Domain

The `Abstract` subdomain contains shared infrastructure for cross-cutting concerns:

- `Abstract/Base` — base Controller, base EventSubscriber, base Fixture setup
- `Abstract/Connect` — OAuth2 connection flows shared across providers
- `Abstract/Users` — user account handling shared across the application

Classes in `Abstract` must be interfaces or abstract classes — no `final` concrete implementations.
