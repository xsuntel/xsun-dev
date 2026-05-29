# Database Rules

These rules apply to all Doctrine Entity, Repository, and Migration files.

@see https://symfony.com/doc/current/doctrine.html

## Multiple Entity Managers

@see https://symfony.com/doc/current/doctrine/multiple_entity_managers.html

This project uses a **multi-database architecture** — each domain has its own PostgreSQL database and a dedicated Doctrine connection and EntityManager. All connections are declared in `app/config/packages/doctrine.yaml`.

| EntityManager name | Database name | Domain           |
| ------------------ | ------------- | ---------------- |
| `abstract`         | `abstract`    | Abstract / Users |
| `company`          | `company`     | Company          |
| `partners`         | `partners`    | Partners         |
| `products`         | `products`    | Products         |

**Rules:**

- Never define associations (OneToMany, ManyToOne, etc.) between Entities that belong to different EntityManagers — Doctrine does not support cross-manager relations.
- Do not use `ServiceEntityRepository` — it always resolves via `ManagerRegistry` and can silently bind to the wrong EntityManager. Extend `Doctrine\ORM\EntityRepository` and inject the correct EntityManager explicitly via `#[Target]`.
- Entities must only be mapped inside the EntityManager that matches their namespace directory.

```yaml
# config/packages/doctrine.yaml (excerpt)
doctrine:
  dbal:
    default_connection: abstract
    connections:
      abstract:
        driver: pdo_pgsql
        dbname: abstract
        mapping_types: { enum: string }
  orm:
    default_entity_manager: abstract
    entity_managers:
      abstract:
        connection: abstract
        mappings:
          App\Entity\Abstract:
            type: attribute
            dir: "%kernel.project_dir%/src/Entity/Abstract"
            prefix: App\Entity\Abstract
            alias: Abstract
```

## Table Naming Convention

- Table names are `snake_case` and reflect the namespace hierarchy, compressed.
- Pattern: `{subdomain}_{entity_name}` — drop the provider path prefix shared by all tables in the same database.
  - `App\Entity\Providers\Finance\App\DigitalAsset\example\Domestic\Coin\API\REST\Exchange\Service\StatusWallet` → `api_rest_exchange_service_status_wallet`
  - `App\Entity\Providers\Finance\App\DigitalAsset\example\Domestic\Coin\API\REST\Quotation\Orderbook\Orderbook` → `api_rest_quotation_orderbook_orderbook`
  - `App\Entity\Abstract\Users` → `users`
- **Never** rely on Doctrine auto-generated table names — always declare `#[ORM\Table(name: '...')]` explicitly.
- Abstract/shared entities use the `abstract_` prefix: `abstract_users`, `abstract_connect_*`.
- Avoid PostgreSQL reserved words as table or column names (`user`, `group`, `order`, `type`, etc.).

## Entity Class Design

@see https://www.doctrine-project.org/projects/doctrine-orm/en/3.3/reference/basic-mapping.html

### Class-Level Rules

- Mark every concrete entity class `final` — entities are not designed for extension.
- Always declare `#[ORM\Entity(repositoryClass: XxxRepository::class)]` — never leave the repository class unset.
- Always declare `#[ORM\Table(name: '...')]` — never omit it.
- Add `#[ORM\HasLifecycleCallbacks]` to the class when any method uses `#[ORM\PrePersist]` or `#[ORM\PreUpdate]`.

### Constructor Pattern

- Initialize only the primary key field(s) via constructor — never set timestamps or nullable fields there.
- Do not use `#[ORM\GeneratedValue]` for provider-data entities with natural string PKs (market symbol, currency code, etc.).

```php
#[ORM\Entity(repositoryClass: OrderbookRepository::class)]
#[ORM\Table(name: 'api_rest_quotation_orderbook_orderbook')]
#[ORM\HasLifecycleCallbacks]
final class Orderbook
{
    #[ORM\Id]
    #[ORM\Column(type: 'string', nullable: false)]
    private string $market;

    public function __construct(string $market)
    {
        $this->market = $market;
    }
}
```

### PHP 8.4 Property Hooks

Use PHP 8.4 property hooks for inline data normalization on assignment — avoid writing a separate setter method when the transformation is a one-liner:

```php
#[ORM\Column(nullable: false)]
private ?string $total_ask_size = null {
    set(string|float|null $value) {
        $this->total_ask_size = rtrim(rtrim((string) $value, '0'), '.');
    }
}
```

### Composite Primary Keys

When the natural PK is multi-column, declare multiple `#[ORM\Id]` attributes — do not introduce a surrogate `id` column just to avoid composites:

```php
#[ORM\Id]
#[ORM\Column(nullable: false)]
private string $currency;

#[ORM\Id]
#[ORM\Column(nullable: false)]
private string $net_type;
```

## Timezone

@see https://www.php.net/manual/en/class.datetimeimmutable.php

- All `\DateTimeImmutable` instances that represent Korean business time must be created with `new \DateTimeImmutable('now', new \DateTimeZone('Asia/Seoul'))`.
- **Never** use `new \DateTime()` — always `new \DateTimeImmutable()`.
- **Never** use `new \DateTimeImmutable()` without an explicit timezone for Korean timestamps.
- `createdAt` in domain entities (non-provider): set once in `#[ORM\PrePersist]`.
- `updatedAt` in provider-data entities: call `setUpdatedAt()` explicitly in batch import handlers — do not use `#[ORM\PreUpdate]` alone, as bulk imports bypass the UoW change-tracking.

```php
#[ORM\PrePersist]
public function onPrePersist(): void
{
    $now = new \DateTimeImmutable('now', new \DateTimeZone('Asia/Seoul'));
    $this->createdAt = $now;
    $this->updatedAt = $now;
}

#[ORM\PreUpdate]
public function onPreUpdate(): void
{
    $this->updatedAt = new \DateTimeImmutable('now', new \DateTimeZone('Asia/Seoul'));
}
```

## Column Mapping

@see https://www.doctrine-project.org/projects/doctrine-orm/en/3.3/reference/basic-mapping.html#doctrine-mapping-types

### Type Reference

| Use case                   | Doctrine type                       | PHP type                     | Notes                                                |
| -------------------------- | ----------------------------------- | ---------------------------- | ---------------------------------------------------- |
| Short text                 | `string`                            | `string`                     | Always set `length:`                                 |
| Long text / keys           | `text`                              | `string`                     | No length limit                                      |
| API response payload       | `json`                              | `array`                      | Maps to PostgreSQL `jsonb`                           |
| Prices / decimals          | `decimal`                           | `string`                     | Always set `precision:` and `scale:` — never `float` |
| Timestamps                 | `datetime_immutable`                | `\DateTimeImmutable`         | Column type explicit                                 |
| Boolean flags              | `boolean`                           | `bool`                       |                                                      |
| Large integers             | `bigint`                            | `string`                     | PHP has no 64-bit int on 32-bit systems              |
| Auto-increment PK          | `integer` + `#[ORM\GeneratedValue]` | `?int`                       | Domain entities only                                 |
| Public-facing surrogate PK | `uuid`                              | `Symfony\Component\Uid\Uuid` | Provider-API entities may use string PKs instead     |
| Enum columns               | via `enumType:`                     | Backed enum                  | See below                                            |

### Enum Columns

Map PHP backed enums via the `enumType:` parameter — never store enum values as raw strings in the entity class:

```php
#[ORM\Column(enumType: TwoFactorTypeEnum::class)]
private TwoFactorTypeEnum $twoFactorType;
```

PostgreSQL native `ENUM` types are mapped to `string` via `doctrine.yaml`:

```yaml
doctrine:
  dbal:
    connections:
      abstract:
        mapping_types: { enum: string }
```

### Encrypted Columns

API key columns that hold secrets: declare `type: 'text'` — encryption and decryption happen in the `Service/{Provider}/ApiKeyService` class, never in the entity or repository. Never store plaintext keys.

### JSON / JSONB Columns

Use `type: 'json'` (not `type: 'json_object'`) for API response payloads:

```php
#[ORM\Column(type: 'json', nullable: false)]
private ?array $orderbook_units = null;
```

## Index Strategy

@see https://www.doctrine-project.org/projects/doctrine-orm/en/3.3/reference/attributes-reference.html

- Declare `#[ORM\Index]` explicitly for **every** foreign-key column — Doctrine ORM 3 does not auto-create them.
- Composite indexes for filter combinations used together (e.g., `[status, createdAt]`, `[market, timestamp]`).
- Use `#[ORM\UniqueConstraint]` on the class (not `unique: true` on individual columns) to ensure the constraint is named and manageable:

```php
#[ORM\Entity(repositoryClass: ApiKeysRepository::class)]
#[ORM\Table(name: 'example_account_api_keys')]
#[ORM\UniqueConstraint(name: 'uniq_api_key_user', columns: ['user_id', 'label'])]
#[UniqueEntity(fields: ['userId', 'label'])]
final class ApiKeys
{
    #[ORM\Index(columns: ['user_id'], name: 'idx_api_keys_user')]
    // ...
}
```

- Add `GIN` indexes on `json` columns that are queried with the `@>` (contains) operator — declare via a native migration SQL, not a Doctrine attribute.
- Prefer partial indexes (via native SQL migration) for large tables filtered by a status enum.

## Lifecycle Callbacks

@see https://www.doctrine-project.org/projects/doctrine-orm/en/3.3/reference/events.html#lifecycle-callbacks

- The class-level attribute `#[ORM\HasLifecycleCallbacks]` is **required** — without it, `#[ORM\PrePersist]` and `#[ORM\PreUpdate]` methods are silently ignored.
- `#[ORM\PrePersist]` fires once before the first `INSERT` — use it to set `createdAt` and `updatedAt`.
- `#[ORM\PreUpdate]` fires before each `UPDATE` — use it to set `updatedAt` only.
- Combining both on one method (`#[ORM\PrePersist]` `#[ORM\PreUpdate]`) is acceptable for provider-data entities where `createdAt` is not tracked:

```php
#[ORM\PrePersist]
#[ORM\PreUpdate]
public function onPrePersistOrUpdate(): void
{
    $this->updatedAt = new \DateTimeImmutable('now', new \DateTimeZone('Asia/Seoul'));
}
```

- Never call lifecycle callback methods directly from application code — they are invoked by the UoW.

## Repository Rules

@see https://symfony.com/doc/current/doctrine.html#querying-for-objects-the-repository

- Extend `Doctrine\ORM\EntityRepository` — **not** `ServiceEntityRepository` (ServiceEntityRepository cannot resolve the correct EntityManager in this project's multi-EM setup).
- Inject the correct EntityManager via `#[Target('...entity_manager')]` and call `parent::__construct()`:

```php
use Doctrine\ORM\EntityManagerInterface;
use Doctrine\ORM\EntityRepository;
use Symfony\Component\DependencyInjection\Attribute\Target;

class MarketAllRepository extends EntityRepository
{
    public function __construct(
        #[Target('providers_finance_app_digitalasset_example_domestic.entity_manager')]
        EntityManagerInterface $entityManager,
    ) {
        parent::__construct($entityManager, $entityManager->getClassMetadata(MarketAll::class));
    }
}
```

- All finder methods that return a collection must declare a PHPDoc `@return EntityClass[]`.
- Use `createQueryBuilder()` for all non-trivial queries — never `findBy()` with more than two criteria.
- **QueryBuilder extraction pattern** — expose a `findByXxxQueryBuilder(): QueryBuilder` method alongside `findByXxx(): array` so callers can append `setMaxResults()`, `orderBy()`, or pagination without duplicating query logic:

```php
public function findBySearch(?string $query, ?int $limit = null): array
{
    $qb = $this->findBySearchQueryBuilder($query);
    if ($limit) {
        $qb->setMaxResults($limit);
    }
    return $qb->getQuery()->getArrayResult();
}

public function findBySearchQueryBuilder(?string $query): QueryBuilder
{
    $qb = $this->createQueryBuilder('v');
    if ($query) {
        $qb->andWhere('v.korean_name LIKE :query')
            ->setParameter('query', '%'.$query.'%');
    }
    return $qb;
}
```

- Prevent N+1 queries: use `JOIN FETCH` (`->addSelect('r')` + `->leftJoin('e.relation', 'r')`) when the caller always accesses a relation.
- Use `getArrayResult()` instead of `getResult()` when the caller only reads scalar values and does not need hydrated objects.
- Use `getOneOrNullResult()` for single optional results — never `getResult()[0] ?? null`.
- Use Pagerfanta (`BabDev\PagerfantaBundle`) with the Doctrine ORM adapter for all list queries — never manual `LIMIT`/`OFFSET`.

## Migration Workflow

@see https://symfony.com/doc/current/doctrine.html#migrations-creating-the-database-tables-schema
@see https://symfony.com/doc/current/doctrine/multiple_entity_managers.html

Because this project has multiple EntityManagers, always specify `--em=` (entity manager name) and `--db=` (connection name) when running Doctrine commands:

```bash
# Generate a diff migration for a specific entity manager
cd app && php bin/console doctrine:migrations:diff --em=providers_finance_app_digitalasset_example_domestic

# Apply migrations for a specific entity manager
cd app && php bin/console doctrine:migrations:migrate --em=providers_finance_app_digitalasset_example_domestic

# Validate schema for a specific entity manager
cd app && php bin/console doctrine:schema:validate --em=abstract

# Create the database for a specific connection
cd app && php bin/console doctrine:database:create --connection=company
```

**Rules:**

- **Never edit** a migration file after it has been applied to any environment.
- Destructive changes (column removal, type change on a live column) require a **two-step migration**:
  1. Add the new column / backfill data / mark old column nullable.
  2. Drop the old column in a separate migration after the backfill is verified.
- **Never add** a `NOT NULL` column without a `DEFAULT` value in the `up()` SQL — it will fail on tables with existing rows.
- Always review the generated SQL before applying — `doctrine:migrations:diff` may generate DROP statements for tables it cannot map, such as non-Doctrine-managed tables.
- Always run `doctrine:schema:validate` after applying migrations to confirm schema consistency.

## PostgreSQL-Specific Features

@see https://www.postgresql.org/docs/current/datatype-json.html

### JSONB Querying

Use `JSONB` (via Doctrine `json` type) for API response payloads that need to be queried. Doctrine maps `json` columns to PostgreSQL `jsonb` automatically when the driver is `pdo_pgsql`.

Add a `GIN` index on `jsonb` columns queried with the `@>` operator — this must be done via raw SQL in a migration:

```sql
CREATE INDEX CONCURRENTLY idx_orderbook_units_gin ON api_rest_quotation_orderbook_orderbook USING gin (orderbook_units);
```

### Window Functions

Window functions in native SQL queries must go through a Repository method — never in a Service:

```php
use Doctrine\ORM\Query\ResultSetMapping;

public function findRankedByVolume(): array
{
    $rsm = new ResultSetMapping();
    $rsm->addScalarResult('market', 'market');
    $rsm->addScalarResult('acc_trade_volume', 'volume');
    $rsm->addScalarResult('rnk', 'rank');

    $sql = '
        SELECT market, acc_trade_volume,
               RANK() OVER (ORDER BY acc_trade_volume DESC) AS rnk
        FROM api_rest_quotation_ticker_ticker
    ';

    return $this->getEntityManager()
        ->createNativeQuery($sql, $rsm)
        ->getArrayResult();
}
```

- Use `NativeQuery` + `ResultSetMapping` for window function queries — never raw PDO.
- Never write window functions inside a Service class — always delegate to a Repository method.

### Advisory Locks

PostgreSQL advisory locks can be used as an alternative to `symfony/lock` for long-running batch imports. Use `pg_try_advisory_lock($key)` via a native query — never rely on application-level timeouts for batch coordination.
