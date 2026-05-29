---
name: PHP Custom Style
description: PHP
keep-coding-instructions: true
---

# PHP Style Instructions

## Standards Compliance

- **PSR-1** (Basic Coding Standard): UTF-8 without BOM, `<?php` tag only, side-effect-free declaration files
- **PSR-4** (Autoloading Standard): namespace maps 1:1 to directory path under `app/src/`
- **PSR-12** (Extended Coding Style): primary style guide — supersedes PSR-2

## Naming Conventions (PSR-1 / PSR-12)

| Symbol        | Convention                          | Example                          |
|---------------|-------------------------------------|----------------------------------|
| Class         | PascalCase                          | `OrderStatusService`             |
| Interface     | PascalCase + `Interface` suffix     | `OrderRepositoryInterface`       |
| Trait         | PascalCase + `Trait` suffix         | `TimestampableTrait`             |
| Enum          | PascalCase + `Enum` suffix          | `OrderStatusEnum`                |
| Method        | camelCase                           | `findActiveOrders()`             |
| Property      | camelCase                           | `$createdAt`                     |
| Constant      | UPPER_SNAKE_CASE                    | `MAX_RETRY_COUNT`                |
| Variable      | camelCase                           | `$orderCount`                    |

## PHP 8.4 Modern Features

Always prefer these over legacy equivalents:

- Constructor property promotion for all injected dependencies
- `readonly` on properties never mutated after construction; `readonly class` where all properties qualify
- `match` instead of `switch` for exhaustive value mapping (no fall-through, returns a value)
- `enum` (backed or pure) for fixed-domain values — status, type, role
- Named arguments when calling functions with multiple optional parameters
- Nullsafe operator `?->` instead of `isset()` chains
- Union types `TypeA|TypeB` and intersection types `TypeA&TypeB` in signatures — never `mixed` unless unavoidable
- First-class callable syntax `$fn = strlen(...)` for callable references
- Property hooks (`get` / `set`) for computed or validated properties (PHP 8.4)
- Asymmetric visibility `public private(set)` where write access must be restricted (PHP 8.4)

## Formatting Rules (PSR-12)

- **Indentation:** 4 spaces — never tabs
- **Line length:** soft limit 120 characters; readability takes precedence over line length
- One statement per line; no multiple statements on one line
- Opening brace on the same line as the class/function/control structure keyword
- Closing brace on its own line
- No space between function or method name and the opening parenthesis
- One space before and after binary operators (`+`, `-`, `===`, `??`, etc.)
- Trailing comma on the last item in multi-line arrays and argument lists
- Visibility (`public`, `protected`, `private`) declared on every property and method
- `abstract` / `final` declared before visibility; `static` declared after visibility

## Code Block Format

Always wrap PHP code in fenced code blocks with the `php` language identifier:

```php
<?php

declare(strict_types=1);
```

## File Header Order

Every PHP file must follow this exact order:

1. `<?php`
2. Blank line
3. `declare(strict_types=1);`
4. Blank line
5. `namespace App\...;`
6. Blank line
7. `use` statements — sorted alphabetically, grouped in this order:
   - PHP built-ins (e.g., `\DateTimeImmutable`, `\InvalidArgumentException`)
   - Doctrine (`Doctrine\ORM\*`, `Doctrine\Common\*`)
   - Symfony (`Symfony\*`, `Twig\*`)
   - App (`App\*`)
8. Blank line
9. Class declaration

## Multi-File Responses

When generating multiple files, prefix each block with the full `app/`-relative path as a comment:

```
// app/src/Entity/Domain/Name.php
```

Then the full file content immediately follows.

## Inline Explanation Format

After code blocks, use these headings only:

- **How it works** — what the code does, in 3–5 bullets
- **Why this way** — architectural or performance justification
- **Next steps** — migration command, debug:router, etc. (only when relevant)

Do NOT add:

- "Here is the code:" preamble
- Summaries of what was written (the code speaks for itself)
- Motivational filler ("Great question!", "Certainly!", etc.)

## Comment Style in Generated Code

- No block comments (`/* ... */`) in generated PHP.
- Section separators use this exact format (for long controller/handler methods only):

```php
// -----------------------------------------------------------------------------------------------------------------
// Section Name
// -----------------------------------------------------------------------------------------------------------------
```

- Inline comments only when the WHY is non-obvious.
- No `@param` / `@return` docblocks when native types already express the contract.
