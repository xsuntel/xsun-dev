---
paths:
  - "app/src/Entity/**/*.php"
  - "app/src/EntityRepository/**/*.php"
  - "app/src/Repository/**/*.php"
---

# Doctrine / Database Rules

@see https://symfony.com/doc/current/doctrine.html

## Entity Mapping

- Use PHP Attributes exclusively (`#[ORM\Entity]`, `#[ORM\Column]`, etc.).
- Never use XML or YAML mapping files.
- Always declare `#[ORM\Table(name: '...')]` explicitly — never rely on auto-generated table names.
- Mark entity classes `final` unless they are abstract base entities.

```php
#[ORM\Entity(repositoryClass: PostRepository::class)]
#[ORM\Table(name: 'post')]
#[ORM\HasLifecycleCallbacks]
final class Post
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    private ?int $id = null;

    #[ORM\Column(length: 255)]
    private string $title;

    #[ORM\Column]
    private \DateTimeImmutable $createdAt;

    public const int ITEMS_PER_PAGE = 20;  // domain constants belong on the entity

    #[ORM\PrePersist]
    public function initCreatedAt(): void
    {
        $this->createdAt = new \DateTimeImmutable('now', new \DateTimeZone('Asia/Seoul'));
    }
}
```

## Repository

- Encapsulate all business queries in Repository classes — no DQL or QueryBuilder in Controllers or Services.
- Extend `Doctrine\ORM\EntityRepository` (not `ServiceEntityRepository` unless DI requires it).
- Use `createQueryBuilder()` for any query with more than one filter criterion — never `findBy()` with complex conditions.

```php
final class PostRepository extends EntityRepository
{
    /** @return Post[] */
    public function findPublishedOrderedByDate(): array
    {
        return $this->createQueryBuilder('p')
            ->where('p.publishedAt IS NOT NULL')
            ->orderBy('p.publishedAt', 'DESC')
            ->getQuery()
            ->getResult();
    }
}
```

## Repository Query Patterns

- Simple lookups: use `findBy()` and `findOneBy()`.
- Complex queries: use `QueryBuilder` — avoid writing DQL strings directly.
- Performance-critical queries: use Native SQL + `ResultSetMapping`.
- Pagination: use Pagerfanta with the Doctrine ORM adapter (never manual `LIMIT`/`OFFSET`).

```php
// Repository method naming conventions
public function findPublishedOrderedByDate(): array {}      // returns a collection
public function findOneBySlugOrFail(string $slug): Post {}  // single result, throws on miss
```

## Preventing N+1 Queries

Always use `JOIN FETCH` when the caller will access a relation:

```php
$this->createQueryBuilder('p')
    ->addSelect('a')
    ->leftJoin('p.author', 'a')
    ->getQuery()
    ->getResult();
```

Declare `#[ORM\Index]` on every foreign-key column — Doctrine ORM 3 does not add them automatically.

## Association Configuration

- `fetch: 'EXTRA_LAZY'` — prevents loading the entire collection when only the count is needed.
- `cascade: ['persist', 'remove']` — use explicitly and sparingly; do not cascade by default.
- Bidirectional relations must always declare both `mappedBy` and `inversedBy`.
- `OneToMany` collections must be initialized as `ArrayCollection` in the constructor.

```php
#[ORM\OneToMany(targetEntity: Comment::class, mappedBy: 'post',
    fetch: 'EXTRA_LAZY', cascade: ['persist'])]
private Collection $comments;

public function __construct()
{
    $this->comments = new ArrayCollection();
}
```

@see https://symfony.com/doc/current/doctrine.html#relationships-and-associations

## Migration Workflow

```bash
# After creating or modifying an Entity:
cd app && php bin/console doctrine:migrations:diff

# Review the generated file in app/migrations/ before applying
cd app && php bin/console doctrine:migrations:migrate

# Validate schema consistency
cd app && php bin/console doctrine:schema:validate
```

- Never edit a migration after it has been applied to any environment.
- Never add `NOT NULL` without a `DEFAULT` in the same migration — it breaks existing rows.
- Destructive changes (column removal, type change on a live column) require a two-step migration: (1) backfill / deprecate, (2) drop.

## Bulk Data Processing

Use `toIterable()` (Doctrine ORM 3) for large result sets to avoid loading everything into memory:

```php
foreach ($this->createQueryBuilder('p')->getQuery()->toIterable() as $post) {
    // process $post
    $this->em->detach($post);
}
```

@see https://symfony.com/doc/current/best_practices.html#use-attributes-to-define-the-doctrine-entity-mapping
