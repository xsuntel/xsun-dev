---
paths:
  - "app/src/**/*.php"
---

# Symfony Project — Claude Rules Overview

## Reference Documentation
- Official docs: https://symfony.com/doc/current
- Best Practices: https://symfony.com/doc/current/best_practices.html
- Symfony version: 8.0

## Rule Files

| File | Responsibility |
|------|----------------|
| symfony-01-architecture.md | Directory structure, bundle policy |
| symfony-02-configuration.md | Environment variables, parameters, secrets |
| symfony-03-controller.md | Routing, controller design |
| symfony-04-service.md | Dependency Injection, Autowiring, service container |
| symfony-05-doctrine.md | Entity mapping, Repository, Migration |
| symfony-06-form.md | Form classes, validation, DTO pattern |
| symfony-07-template.md | Twig naming, template inheritance, components |
| symfony-08-security.md | Firewall, Voter, password hashing |
| symfony-09-testing.md | Unit / Integration / Functional test strategy |
| symfony-10-frontend.md | AssetMapper, Stimulus, Symfony UX |
| symfony-11-performance.md | Caching, HTTP Cache, deployment |

## Hard Prohibitions

- Never call `$container->get()` directly — use constructor injection.
- Never write business logic inside a controller — delegate to Services.
- Never create a Bundle to organize application logic — use PHP namespaces instead.
- Never use YAML or XML for Doctrine mapping or routing — PHP Attributes only.
- Never store secrets in committed files — use `.env.local` locally or Symfony Secrets in production.


## PHP & Symfony Version Constraints

- Target **PHP 8.4** — use property hooks, asymmetric visibility (`public private(set)`), and `#[\Deprecated]` where appropriate.
- Target **Symfony 8.0** — do NOT use any API marked `@deprecated` in Symfony 7.x or earlier.
- Target **Doctrine ORM 3.x** — `EntityRepository` (not `ServiceEntityRepository` unless DI requires it), typed properties mandatory.

## Class Design

- `final` on every class that is not explicitly designed for extension.
- `readonly` on constructor-promoted properties that are never mutated after construction.
- No `abstract` classes unless unavoidable — prefer interfaces + composition.
- No `static` methods unless they are pure functions (no state, no I/O).

## Dependency Injection

- Constructor injection only.
- Use `#[Autowire(param: 'kernel.debug')]` for environment flags.
- Use `#[Target('monolog.logger.{channel}')]` for named loggers.
- Use `#[Autowire(service: 'service.id')]` for non-autowireable services.
- Never fetch from `$container` or use `ContainerAware`.

## Routing & Controllers

- `#[Route]` Attribute on class (prefix) and on each action method.
- Return `$this->render('template.html.twig', $data)` — never use `#[Template]` (SensioFrameworkExtraBundle legacy, removed in Symfony 7+).
- Route names follow the pattern: `{domain}_{subdomain}_{action}` (snake_case).
- All state-mutating actions: POST/PUT/PATCH/DELETE only — never GET.
- CSRF protection via `#[IsCsrfTokenValid]` on all POST form submissions.

## Messenger / CQRS

- Write operations → `MessageCommand` + `MessageCommandHandler`.
- Read operations → `MessageQuery` + `MessageQueryHandler`.
- Events (side effects) → `MessageEvent` + `MessageEventHandler`.
- Transport on message class via `#[AsMessage('{transport}')]`.
- Handler registered via `#[AsMessageHandler]` on handler class.
- Dispatch via `MessageBusInterface` — never call handlers directly.

## Workflow

- Entity state transitions via `WorkflowInterface::apply()` only.
- Guard transitions via Workflow guard events — not `if/else` in Services.
- Never set state properties directly from a Service or Controller.

## Logging

- Use named channels (`monolog.logger.{module}`) — not the global `logger`.
- All debug logs guarded: `if ($this->isDebug) { $this->logger->info(...); }`.
- Use structured context arrays, not string interpolation in log messages.

## Pagination

- Always use Pagerfanta with the Doctrine ORM adapter.
- Never write manual `LIMIT`/`OFFSET` pagination in Repositories.
- Default page size: 20. Maximum: 100.

## API Platform

- Resource classes in `app/src/ApiResource/` — not Entity classes directly.
- Use `#[ApiResource]` with explicit `operations` array — never rely on defaults.
- DTO-based input/output via `input:` and `output:` resource configuration.
- Rate-limit all API endpoints via `symfony/rate-limiter`.
