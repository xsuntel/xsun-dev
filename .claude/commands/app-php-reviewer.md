---
title: "PHP Analysis & Refactoring Guide"
description: "Evaluate the quality of a PHP file and provide structured improvement recommendations."
arguments:
    - name: file
      description: "Path to the PHP file to analyze"
---

Analyze the following PHP file:

**`{{file}}`**

Perform a thorough review across all sections below. For each finding, reference the exact line number(s) and provide a concrete fix or improved code snippet.

---

## 1. File Header & Standards Compliance

Check the following and flag any violations:

- **Shebang & opening tag**: File must start with `<?php` — no closing `?>` tag in non-template files.
- **`declare(strict_types=1)`**: Must appear immediately after the opening `<?php` line with a blank line between them. Flag any file that omits it.
- **Namespace declaration**: Must follow PSR-4 — the namespace must map 1:1 to the file path under `app/src/`. Flag mismatches.
- **`use` statement grouping**: Import groups must be ordered and separated by a blank line:
  1. PHP built-ins (`\DateTimeImmutable`, `\InvalidArgumentException`)
  2. Doctrine (`Doctrine\ORM\*`, `Doctrine\Common\*`)
  3. Symfony (`Symfony\*`, `Twig\*`)
  4. App (`App\*`)
  - Flag unsorted imports within a group and missing blank lines between groups.
- **PSR-12 formatting**: 4-space indentation, no tabs, soft limit 120 characters per line, one statement per line.

---

## 2. PHP 8.4 Modern Features

Flag uses of legacy patterns that have modern equivalents:

- **Constructor property promotion**: Injected dependencies must use promoted properties — flag separate property declaration + constructor assignment.
- **`readonly`**: Properties never mutated after construction must be declared `readonly`. A class where all properties qualify should be `readonly class`.
- **`match` over `switch`**: Flag any `switch` statement — replace with `match` when the result is exhaustively mapped to a return value.
- **`enum` over class constants**: Flag sets of related constants (status, type, role) that should be a backed or pure `enum`.
- **Nullsafe operator `?->`**: Flag `isset($obj) ? $obj->method() : null` chains — replace with `$obj?->method()`.
- **Named arguments**: Flag calls to functions with multiple optional parameters where position-only calling creates ambiguity.
- **Union / intersection types**: Flag `mixed` or absent type declarations where a union type (`TypeA|TypeB`) or intersection type (`TypeA&TypeB`) is determinable.
- **First-class callable syntax**: Flag `Closure::fromCallable([$this, 'method'])` — replace with `$this->method(...)`.
- **Property hooks (PHP 8.4)**: Flag verbose getter/setter pairs for computed or validated properties — replace with `get`/`set` property hooks.
- **Asymmetric visibility (PHP 8.4)**: Flag properties with a public getter + protected/private setter pattern — replace with `public private(set)`.

---

## 3. Type Safety & Static Analysis

- **Return types**: Every method must declare a return type. Flag missing return types, including `void`, `never`, `self`, and `static`.
- **Parameter types**: Every parameter must be typed. Flag untyped parameters.
- **`mixed` usage**: Flag any `mixed` type — it disables static analysis. Replace with the most specific union type possible.
- **Nullable vs. union**: Use `Type|null` (PHP 8.0+) over the shorthand `?Type` when the type declaration is part of a union with more than one type.
- **PHPStan compliance (Level 6+)**: Flag patterns that PHPStan would reject:
  - Accessing a property of a potentially-null value without a null check
  - Calling a method with an incompatible argument type
  - Unreachable code paths
  - Missing `@return` PHPDoc only when the native type is insufficient (e.g., `@return Order[]` on a method returning `array`)
- **`@param` / `@return` docblocks**: Only add when native types cannot express the full contract (e.g., array shapes, generics). Flag redundant docblocks that repeat what native types already declare.

---

## 4. Class Design & Architecture

- **`final` keyword**: Every concrete class not designed for extension must be `final`. Flag missing `final` on services, handlers, subscribers, and controllers.
- **`abstract` classes**: Flag `abstract` classes that could be replaced with an interface + composition.
- **`static` methods**: Flag non-pure `static` methods (those that access state, perform I/O, or use `self::`). Static methods must be pure functions.
- **Interface segregation**: Flag a class implementing a large interface when only a subset of methods is used — suggest splitting the interface.
- **Immutability**: Flag mutable value objects — DTOs and value objects should use `readonly` properties or `readonly class`.
- **No `new` in constructors**: Flag `new Dependency()` inside a constructor — inject via DI instead.
- **Single Responsibility**: Flag classes longer than ~200 lines or with more than ~7 public methods — they likely violate SRP.

---

## 5. Dependency Injection & Symfony Conventions

- **Constructor injection only**: Flag setter injection, property injection, or `$container->get()` calls. All dependencies must be constructor-injected.
- **`#[Autowire]` attributes**: Use `#[Autowire(param: 'kernel.debug')]` for environment flags, `#[Target('monolog.logger.{channel}')]` for named loggers, `#[Autowire(service: 'service.id')]` for non-autowireable services.
- **`ContainerAware`**: Flag any use of `ContainerAwareInterface` or `$this->container` — replace with explicit constructor injection.
- **Attribute-based configuration**: Flag YAML/XML-based route and security configuration — use `#[Route]`, `#[IsGranted]`, `#[IsCsrfTokenValid]` attributes instead.
- **Thin controllers**: Flag controllers that contain business logic — delegate to dedicated Service classes. Controllers should only: resolve input, call a service/handler, and return a response.
- **`#[Template]` attribute**: Flag `$this->render()` calls in controllers — use the `#[Template]` attribute instead.

---

## 6. Doctrine ORM

- **Explicit table names**: Flag entities missing `#[ORM\Table(name: '...')]` — Doctrine auto-generated names are prohibited.
- **Column mapping completeness**: Every `#[ORM\Column]` must declare `type:`, `nullable:`, and `length:` (for string columns). Flag incomplete declarations.
- **`float` for money**: Flag `type: 'float'` on price/amount columns — use `type: 'decimal'` with explicit `precision:` and `scale:`.
- **`json_object` type**: Flag use of the legacy `type: 'json_object'` alias — use `type: 'json'` instead.
- **Enum columns**: Flag string columns used to store enum values — use `enumType: MyEnum::class` in the column attribute.
- **Index declarations**: Flag foreign-key columns missing `#[ORM\Index]` — Doctrine ORM 3 does not auto-add them.
- **Unique constraints**: Flag `unique: true` on individual columns — use `#[ORM\UniqueConstraint]` at the class level to name the constraint.
- **`findAll()` in production paths**: Flag any `findAll()` call — use a paginated or filtered query instead.
- **N+1 queries**: Flag lazy-loaded relation accesses inside loops — use `JOIN FETCH` (`->addSelect('r')`, `->leftJoin('e.relation', 'r')`) in the repository query.
- **Query logic in controllers/services**: Flag DQL or QueryBuilder calls outside a Repository class.
- **`new \DateTime()`**: Flag — always use `new \DateTimeImmutable()`.
- **Timezone**: Flag `DateTimeImmutable` instances for Korean business time missing `new \DateTimeZone('Asia/Seoul')`.

---

## 7. Messenger / CQRS Pattern

- **Write operations**: Flag write logic dispatched as a `MessageQuery` or implemented inline in a Controller/Service — must use `MessageCommand` + `MessageCommandHandler`.
- **Read operations**: Flag read logic dispatched as a `MessageCommand` — must use `MessageQuery` + `MessageQueryHandler`.
- **Side effects**: Flag post-write side effects implemented inside a `MessageCommandHandler` — extract to a `MessageEvent` + `MessageEventHandler`.
- **Direct handler calls**: Flag any direct instantiation or method call on a handler class — always dispatch via `MessageBusInterface`.
- **`#[AsMessageHandler]`**: Flag handler classes missing this attribute.
- **Transport declaration**: Flag message classes missing `#[AsMessage('{transport}')]` when async dispatch is required.

---

## 8. Security

- **Raw request access**: Flag `$_POST`, `$_GET`, `$_REQUEST`, or `$request->get()` in controllers — all input must flow through a Form type or a DTO with Validator constraints.
- **CSRF protection**: Flag state-mutating form actions missing `#[IsCsrfTokenValid('intention', '_token')]`.
- **XSS — `|raw` filter**: Flag any `{{ variable|raw }}` in Twig or `->setContent(htmlspecialchars_decode(...))` in PHP that originates from user input or the database.
- **SQL injection**: Flag raw SQL with string interpolation — use `:param` binding in DQL/QueryBuilder, or `$conn->executeQuery($sql, $params)` for native queries.
- **Sensitive data in logs**: Flag `$this->logger->*()` calls that include passwords, tokens, or API keys in the message or context array.
- **`#[Sensitive]`**: Flag DTO properties carrying passwords or tokens that are missing the `#[Sensitive]` attribute.
- **Rate limiting**: Flag public-facing POST endpoints (login, registration, password reset) missing `symfony/rate-limiter` integration.

---

## 9. Error Handling & Logging

- **Swallowed exceptions**: Flag empty `catch` blocks or `catch` blocks that only `return null` without logging. Every caught exception must be logged or re-thrown.
- **Exception types**: Flag `catch (\Exception $e)` — catch the most specific exception type available.
- **Named logger channels**: Flag use of the global `logger` service — use a named channel (`monolog.logger.{module}`) injected via `#[Target]`.
- **Debug log guard**: Flag `$this->logger->info(...)` or `$this->logger->debug(...)` calls not guarded by `if ($this->isDebug)`.
- **Structured context**: Flag string interpolation in log messages (e.g., `"User {$id} failed"`) — use structured context arrays: `$this->logger->error('User failed', ['user_id' => $id])`.

---

## 10. Domain Structure Rules

- **Layer placement**: Verify the file is in the correct `app/src/` subdirectory for its type (Entity, EntityRepository, MessageCommand, MessageCommandHandler, MessageQuery, MessageQueryHandler, MessageEvent, MessageEventHandler, Service, Controller, Scheduler, Serializer, Form, EventSubscriber). Flag misplaced files.
- **Cross-domain dependencies**: Flag a domain class (e.g., `Company`) importing from another domain (e.g., `Partners`). Cross-domain data sharing must go through shared Entities or MessageQuery dispatches.
- **`Providers/*` write access**: Flag direct Entity writes (persist/flush) in code outside the `Providers/*` domain's own handlers.
- **`Abstract` domain**: Flag `final` concrete implementations inside `Abstract/` — classes there must be interfaces or abstract classes.
- **Namespace ↔ path mismatch**: Verify the declared namespace matches the file's actual directory path under `app/src/`.

---

## 11. Output Format

Provide your analysis in this structure:

### Summary

| Category                      | Status (OK / WARN / FAIL) | Issue Count |
|-------------------------------|---------------------------|-------------|
| File Header & Standards       |                           |             |
| PHP 8.4 Modern Features       |                           |             |
| Type Safety & Static Analysis |                           |             |
| Class Design & Architecture   |                           |             |
| Dependency Injection          |                           |             |
| Doctrine ORM                  |                           |             |
| Messenger / CQRS              |                           |             |
| Security                      |                           |             |
| Error Handling & Logging      |                           |             |
| Domain Structure              |                           |             |

### Critical Issues (must fix)

For each issue: **[Line N]** Description → Recommended fix with code snippet.

### Improvement Suggestions (should fix)

For each suggestion: **[Line N]** Description → Recommended approach.

### Refactoring Proposals

If structural changes are warranted (class extraction, layer reassignment, CQRS split, etc.), describe the proposal with before/after code examples.
