---
name: reviewing-code-changes
description: Use when reviewing code changes, identifying potential bugs, or suggesting improvements for pull requests. Covers correctness, maintainability, performance, security, and project-specific rule compliance (Symfony 8, PHP 8.4, Doctrine multi-EM, RabbitMQ message flow, Redis cache, API key handling).
allowed-tools: Read, Grep, Glob
---

# Code Review

## Review Scope

Before starting, determine what changed:

```bash
git diff main...HEAD --name-only   # Files changed
git diff main...HEAD               # Full diff
```

Group changed files by layer — Entity, Repository, Service, Handler, Controller, Config — and apply the relevant checklist sections for each layer.

## Review Checklist

### Correctness

- [ ] Does the business logic satisfy the stated requirements?
- [ ] Are edge cases handled (empty collections, null returns, zero values, timezone boundaries)?
- [ ] Is error handling present at system boundaries (HTTP responses, external API calls, Messenger handlers)?
- [ ] Are `getOneOrNullResult()` used for single optional results (not `getResult()[0] ?? null`)?
- [ ] Are all `\DateTimeImmutable` instances created with an explicit `Asia/Seoul` timezone where Korean business time is required?

### PHP 8.4 Conventions

- [ ] Are `readonly` properties used for injected dependencies (Constructor Property Promotion)?
- [ ] Are PHP 8.4 property hooks used for inline data normalization instead of separate setter methods?
- [ ] Are `match` expressions used instead of multi-branch `if`/`switch` where appropriate?
- [ ] Are backed enums used for domain constants and column types (not raw strings)?
- [ ] Are `final` classes used for all concrete Entity and Value Object classes?

### Symfony 8 Conventions

- [ ] Are services injected via constructor (not `$this->container->get()`)?
- [ ] Are `#[IsGranted]` attributes used for authorization (not manual `if` checks in controllers)?
- [ ] Are Symfony Validator constraints applied to all DTOs that accept user input?
- [ ] Is `#[Sensitive]` applied to DTO properties that carry API keys or passwords?
- [ ] Are `#[AsPeriodicTask]` scheduler classes dispatching Commands via `MessageBusInterface` (not calling Services directly)?

### Doctrine / Database (@see `.claude/rules/database/postgresql-rule.md`)

- [ ] Does the entity class extend nothing (is it `final` with no parent)?
- [ ] Is `#[ORM\Entity(repositoryClass: ...)]` declared with an explicit repository class?
- [ ] Is `#[ORM\Table(name: '...')]` declared explicitly (never relying on auto-generated names)?
- [ ] Is `#[ORM\HasLifecycleCallbacks]` present on any class that uses `#[ORM\PrePersist]` or `#[ORM\PreUpdate]`?
- [ ] Does the Repository extend `Doctrine\ORM\EntityRepository` (not `ServiceEntityRepository`)?
- [ ] Is the correct EntityManager injected via `#[Target('...entity_manager')]`?
- [ ] Are cross-EntityManager associations absent (no `OneToMany`/`ManyToOne` between different EM domains)?
- [ ] Are `decimal` columns typed as `string` in PHP (not `float`)?
- [ ] Are all foreign-key columns backed by an explicit `#[ORM\Index]`?
- [ ] Does `findByXxx()` have a companion `findByXxxQueryBuilder()` for callers that need pagination or ordering?
- [ ] Is `getArrayResult()` used when only scalar values are needed (not `getResult()`)?

### External API Integration (@see `.claude/rules/api/rest-rule.md`)

- [ ] Is `HttpClientInterface` used (not Guzzle, cURL, or `file_get_contents`)?
- [ ] Is API key decryption confined to the `Service/{Provider}/ApiKeyService` class?
- [ ] Are decrypted API key values absent from logs (only masked prefix logged)?
- [ ] Is the fetch-and-persist pattern intact: `Handler` fetches → raw JSON stored in `Entity` → `MessageEvent` dispatched for downstream processing?
- [ ] Is a Symfony Lock guard in place before consecutive HTTP calls to rate-limited endpoints?
- [ ] Are transient failures (503, timeout) re-thrown as `\RuntimeException` for RabbitMQ retry?
- [ ] Are permanent failures (401, 403) dispatching a `MessageEvent` to notify the user (not retried)?

### Redis / Cache (@see `.claude/rules/cache/redis-rule.md`)

- [ ] Is a specific named pool injected via `#[Target('cache_pool_{domain}')]` (not the generic `cache.app`)?
- [ ] Does every `$item->expiresAfter(...)` call set a TTL (never indefinite)?
- [ ] Is `TagAwareCacheInterface` used when invalidation by tag is needed?
- [ ] Is the `\Redis` class absent from all service and controller code (cache access via Symfony Cache only)?
- [ ] Is `CacheInterface` used for simple get/set and `TagAwareCacheInterface` only when tagging is needed?

### Security

- [ ] Is all user input validated with Symfony Validator before processing?
- [ ] Is Twig auto-escaping intact (no `|raw` filter on user-supplied content)?
- [ ] Are CSRF tokens enabled on all state-changing HTML forms?
- [ ] Is no sensitive data (API keys, tokens, passwords) stored in environment-committed files (`.env`, source code)?
- [ ] Are SQL parameters always bound (no string interpolation into DQL/SQL)?
- [ ] Are `#[IsGranted]` or voter checks in place for every endpoint that mutates data?

### Maintainability

- [ ] Is each class or function responsible for a single concern?
- [ ] Is duplication minimised — are shared patterns extracted to a common method or service?
- [ ] Are comments present only where the **why** is non-obvious (not restating what the code does)?
- [ ] Are unused `use` statements, variables, and dead code removed?
- [ ] Are method names and variable names descriptive enough to make their purpose clear without a comment?

### Performance

- [ ] Are N+1 queries eliminated with `JOIN FETCH` / `addSelect()` where a relation is always accessed?
- [ ] Is `getArrayResult()` used over `getResult()` for read-only scalar queries?
- [ ] Are expensive queries covered by the appropriate cache pool with a sensible TTL?
- [ ] Is there no synchronous HTTP call in the request cycle that should be a dispatched Command?
- [ ] Are Pagerfanta adapters used for all list queries (no manual `LIMIT`/`OFFSET`)?

## Severity Levels

Apply one of three severities to each finding:

| Severity | Label | When to use |
|----------|-------|-------------|
| Must fix | `[MUST]` | Bug, security vulnerability, rule violation, data corruption risk |
| Should fix | `[SHOULD]` | Performance issue, maintainability problem, project convention deviation |
| Consider | `[CONSIDER]` | Optional improvement, style preference, future-proofing |

Only `[MUST]` items block merge.

## Review Output Format

Structure the review response in this exact order:

---

### Summary

One or two sentences: overall code quality assessment and merge readiness.

### [MUST] Required Changes

Items that must be resolved before merging. Reference the specific file and line:

- `app/src/Entity/Foo.php:42` — Missing `#[ORM\HasLifecycleCallbacks]`; `#[ORM\PrePersist]` will be silently ignored without it.
- `app/src/Service/Bar.php:17` — Decrypted API key passed to logger; use masked prefix only.

### [SHOULD] Recommended Changes

Items that improve quality but do not block merge:

- `app/src/Repository/BazRepository.php` — `findByStatus()` has no companion `findByStatusQueryBuilder()`; callers cannot paginate without duplicating the query.

### [CONSIDER] Optional Suggestions

Low-priority ideas for future improvement:

- Consider extracting the timezone constant `new \DateTimeZone('Asia/Seoul')` to a shared constant to avoid scattered string literals.

### Positive Feedback

Acknowledge what is done well — this is not optional. Identify at least one concrete strength:

- `app/src/MessageHandler/FooHandler.php` — Correctly separates fetch and transform; the raw JSON is persisted first and transformation is deferred to a downstream `MessageEvent`.

---

## Rule File Quick Reference

When a finding relates to a project rule, cite the rule file directly:

| Area | Rule file |
|------|-----------|
| Database / Doctrine | `.claude/rules/database/postgresql-rule.md` |
| External API | `.claude/rules/api/rest-rule.md` |
| Redis / Cache | `.claude/rules/cache/redis-rule.md` |
| Nginx | `.claude/rules/server/nginx-rule.md` |
| General conventions | `CLAUDE.md` |
