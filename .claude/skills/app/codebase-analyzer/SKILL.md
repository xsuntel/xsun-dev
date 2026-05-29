---
name: app-codebase-analyzer
description: Use when analyzing project codebase structure, documenting architecture, mapping domain boundaries, or resolving dependency relationships. Covers Symfony app layout, multi-EntityManager topology, Messenger message flows, and external provider integrations.
---

# Codebase Analysis

## Information Sources

This skill uses **only** the following sources:

- Source code files within the project (under `app/src/`)
- Project documentation files (`CLAUDE.md`, `README.md`, `*.md` under `.claude/rules/`)
- Configuration files (`app/config/**/*.yaml`, `app/composer.json`, `package.json`, `.env.app`)
- Database migration files (`app/migrations/`)

If required information is not found in these sources, state explicitly:

> "This information is not confirmed in the project files."

Do not infer from general knowledge. Do not guess class names, namespace paths, or configuration values that are not visible in the current codebase.

## External Information

When project files are insufficient:

- State the gap: "This information is not confirmed in the project files."
- Do not fill gaps with assumption or general PHP/Symfony knowledge.
- Recommend consulting official documentation via available MCP tools if the user needs authoritative external reference.

## Analysis Methodology

Always follow this top-down order. Do not skip levels.

### Level 1 — Repository Layout

Start with the repository root, not `app/`:

```
symfony-scripts/
├── app/           ← Symfony Application Root (primary analysis target)
├── scripts/       ← Shell scripts and container configs
├── diagram/       ← draw.io architecture diagrams
├── tools/         ← IDE configuration documents
└── .env.app       ← Shared environment variable declarations
```

Read `CLAUDE.md` first — it defines the canonical directory structure and technology stack for this project.

### Level 2 — Symfony Application Structure

Map `app/src/` by namespace segment before reading individual files:

```
app/src/
├── Controller/         ← HTTP entry points; one per domain page/API route
├── Entity/             ← Doctrine entities, grouped by EntityManager domain
├── Repository/         ← Extend EntityRepository (not ServiceEntityRepository)
├── Service/            ← Domain logic; provider integrations under Service/Providers/
├── MessageCommand/     ← Async command messages dispatched to RabbitMQ
├── MessageHandler/     ← Handlers for MessageCommands (one handler per command)
├── MessageEvent/       ← Domain events dispatched after handler completion
├── EventSubscriber/    ← Listeners for MessageEvents and Symfony kernel events
├── Scheduler/          ← #[AsPeriodicTask] classes for recurring provider sync jobs
├── Form/               ← Symfony Form types
├── Twig/               ← Twig extensions and runtime components
├── Security/           ← Voters, authenticators, access control
└── Enum/               ← PHP 8.4 backed enums used as column types or domain constants
```

### Level 3 — Multi-EntityManager Topology

This project uses **10 separate PostgreSQL databases**, each with a dedicated EntityManager and Doctrine connection. Map the EM topology before reading any Entity:

| EntityManager | Database | Domain |
|---------------|----------|--------|
| `abstract` | `abstract` | Users, shared |
| `company` | `company` | Company |
| `partners` | `partners` | Partners |
| `products` | `products` | Products |

Source of truth: `app/config/packages/doctrine.yaml`. Read this file to confirm the current EM mapping before making any statements about where an entity lives.

### Level 4 — Message Flow Tracing

For any async feature, trace the full message lifecycle:

```
Scheduler (#[AsPeriodicTask])
  └── dispatches MessageCommand via MessageBusInterface
        └── MessageCommandHandler (RabbitMQ consumer)
              ├── calls HttpClientInterface → external API
              ├── persists response → Doctrine Entity (json column)
              └── dispatches MessageEvent
                    └── EventSubscriber → downstream processing / Notifier
```

Confirm the actual transport for each Command by reading `app/config/packages/messenger.yaml`. RabbitMQ handles async; Redis transports handle synchronous in-process flows only.

### Level 5 — Configuration Files

Read configuration files in this order when analyzing a domain:

1. `app/config/packages/doctrine.yaml` — EM and connection definitions
2. `app/config/packages/messenger.yaml` — transport routing per message class
3. `app/config/packages/cache.yaml` + env-specific overrides — pool definitions
4. `app/config/packages/framework.yaml` — scoped HTTP clients per provider
5. `app/config/services.yaml` — explicit service definitions and Redis connections

## Dependency Analysis

### PHP Dependencies

Read `app/composer.json`. Group packages by role:

| Role | Package pattern |
|------|----------------|
| Symfony core | `symfony/*` |
| Doctrine ORM | `doctrine/*` |
| Security / Auth | `lexik/jwt-authentication-bundle`, `scheb/2fa-*` |
| HTTP client | `symfony/http-client` (built-in) |
| WebSocket | `ratchet/pawl` |
| Holiday calc | `azuyalabs/yasumi` |
| Pagination | `babdev/pagerfanta-bundle` |

### JavaScript Dependencies

Read `app/package.json`. Key packages:

| Role | Package |
|------|---------|
| Hotwire | `@hotwired/stimulus`, `@hotwired/turbo` |
| CSS | `tailwindcss` |
| Asset pipeline | Symfony AssetMapper (`importmap.php`) |

Do not assume a package is installed without confirming it in `composer.json` or `package.json`.

## Output Format

### Architecture Summary

When documenting the overall architecture, use this structure:

```
## [Domain Name] Architecture

**EntityManager:** `{em_name}`
**Database:** `{db_name}`

### Entities
- `Entity\{Namespace}\{Class}` → table `{table_name}`

### Message Flow
- `Scheduler\{Class}` (every N seconds) → `MessageCommand\{Command}` → `MessageHandler\{Handler}`

### External API
- Provider: {name}, TR ID: {id}, Auth: {method}
- HTTP client: `{scoped_client_name}` (config/packages/framework.yaml)

### Cache
- Pool: `cache_pool_{domain}`, TTL: {dev}s dev / {prod}s prod
```

### Dependency Map

When mapping dependencies between classes, use a directed list — do not invent UML diagrams unless the user requests it:

```
{ServiceClass}
  depends on → {RepositoryClass} (via constructor injection)
  depends on → {CacheInterface} #[Target('cache_pool_{domain}')]
  depends on → {HttpClientInterface} #[Target('{scoped_client}')]
```

### Gap Report

When analysis reveals missing or ambiguous parts, report them explicitly at the end:

```
## Gaps Found

- [ ] `{ClassName}` referenced in `{file}` but not found in `app/src/`
- [ ] EntityManager `{em}` declared in doctrine.yaml but has no mapped entities yet
- [ ] Transport routing for `{MessageClass}` not found in messenger.yaml
```
