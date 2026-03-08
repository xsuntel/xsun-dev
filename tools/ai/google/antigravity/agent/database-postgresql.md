---
trigger: always_on
glob: "app/src/Entity/**/*.php, app/src/Repository/**/*.php, app/config/packages/doctrine.yaml, app/migrations/**/*.php"
description: "PostgreSQL schema and Doctrine ORM 3.3 mapping"
---

# Database Rules (PostgreSQL)

This system prompt defines the identity, technology stack, and behavioral guidelines for the AI assistant.

## Doctrine ORM 3.3

- **Mapping**: MUST use PHP Attributes. Legacy annotations are removed in ORM 3.
- **Types**:
  - Use `Types::JSON` for JSONB columns (PostgreSQL).
  - Use `Uuid` (Symfony Uid) for IDs if required, otherwise `Types::BIGINT`.
- **Relations**: Always define `inversedBy` and `mappedBy` for bidirectional relationships.

## Performance

- **Indexes**: Use `#[ORM\Index]` for searchable fields.
- **Lazy Loading**: Be aware of N+1 problems. Use `fetch: 'EXTRA_LAZY'` for large collections.

## Migrations

- Run `php bin/console make:migration` inside `app/` directory.
