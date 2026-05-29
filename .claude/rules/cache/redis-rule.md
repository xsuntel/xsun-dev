# Cache Rules

@see https://symfony.com/doc/current/cache.html

## General Rules

- Use `CacheInterface` for simple get/set operations — use `TagAwareCacheInterface` when targeted invalidation by tag is needed.
- Always inject a specific pool via `#[Target('cache_pool_{domain}')]` — never inject the generic `cache.app` pool in domain services.
- Set an explicit TTL on every cache item via `$item->expiresAfter(...)` — never cache indefinitely in any environment.
- Apply environment-aware TTLs using `kernel.debug`: short values in development, full values in production.
- Never call the `\Redis` class directly — all cache reads and writes must go through the Symfony Cache component.

```php
use Symfony\Component\DependencyInjection\Attribute\Autowire;
use Symfony\Component\DependencyInjection\Attribute\Target;
use Symfony\Contracts\Cache\CacheInterface;
use Symfony\Contracts\Cache\ItemInterface;

public function __construct(
    #[Autowire(param: 'kernel.debug')]
    private readonly bool $isDebug,
    #[Target('cache_pool_company')]
    private readonly CacheInterface $cache,
) {}

public function getData(): array
{
    return $this->cache->get('my_key', function (ItemInterface $item): array {
        $item->expiresAfter($this->isDebug ? 10 : 3600);

        return $this->repository->findAll();
    });
}
```

## Configuring Redis

@see https://symfony.com/doc/current/components/cache/adapters/redis_adapter.html#configuring-redis

### Environment Variables

Defined in `app/.env` — override in `.env.local` (never commit overrides):

```dotenv
REDIS_HOST=127.0.0.1
REDIS_PORT=6379
LOCK_DSN="redis://${REDIS_HOST}:${REDIS_PORT}/0"
```

### Service Definitions

Two Redis services are defined in `app/config/services.yaml`:

**1. `Redis`** — raw `\Redis` instance, used exclusively by the session handler:

```yaml
Redis:
  class: Redis
  calls:
    - connect: ["%cache_host%", "%cache_port%"]
```

**2. `app.cache_redis_provider`** — factory-built connection for all cache pools:

```yaml
app.cache_redis_provider:
  class: Redis
  factory: ['Symfony\Component\Cache\Adapter\RedisAdapter', "createConnection"]
  arguments:
    - "redis://%cache_host%:%cache_port%"
    - { retry_interval: 2, timeout: 10 }
```

- Use `app.cache_redis_provider` as the `provider:` for every cache pool — never reference `Redis` directly.
- Never change `retry_interval` or `timeout` values without load-testing in the target environment.

### Default Provider

Declared in `app/config/packages/cache.yaml`:

```yaml
framework:
  cache:
    default_redis_provider: "redis://%cache_host%"
```

### Non-Cache Redis Uses

Redis serves three additional roles in this project beyond caching:

**Session storage** (`RedisSessionHandler` — `config/services.yaml:100-103`):

```yaml
Symfony\Component\HttpFoundation\Session\Storage\Handler\RedisSessionHandler:
  arguments:
    - "@Redis"
    - { prefix: "redis_session_", ttl: 600 }
```

- Session TTL is 600 seconds (10 minutes) — never increase this without a security review.
- The `Redis` service (raw connection) is used here, not `app.cache_redis_provider`.

**Distributed locks** (`app/config/packages/lock.yaml`):

```yaml
framework:
  lock:
    abstract: "%env(LOCK_DSN)%"
    company: "%env(LOCK_DSN)%"
    partners: "%env(LOCK_DSN)%"
    projects: "%env(LOCK_DSN)%"
    team: "%env(LOCK_DSN)%"
    tools: "%env(LOCK_DSN)%"
```

- Always inject the named lock store that matches the current domain — never use the default lock store.
- Lock key pattern for API rate limiting: `lock_{provider}_{endpoint_tr_id}` (e.g., `lock_korea_investment_FHKST01010100`).

**Messenger sync transports** (`app/config/packages/messenger.yaml`):

- `sync_providers_finance_app_digitalasset_example_domestic` → `MESSENGER_TRANSPORT_DSN_REDIS`
- `sync_providers_finance_app_securities_example_domestic` → `MESSENGER_TRANSPORT_DSN_REDIS`

Redis transports are for **synchronous, in-process** message handling only. All async work uses RabbitMQ transports — never route async messages to a Redis transport.

## Redis Cache Adapter

@see https://symfony.com/doc/current/components/cache/adapters/redis_adapter.html

### Pool Convention

All 15 domain-scoped cache pools share the same configuration:

```yaml
adapter: cache.adapter.redis
provider: app.cache_redis_provider
tags: true
```

`tags: true` wraps the pool in a `TagAwareCacheAdapter`, so every pool supports both `CacheInterface` and `TagAwareCacheInterface`.

### Pool Name Reference

| Pool Name              | Domain    |
| ---------------------- | --------- |
| `cache_pool_abstract`  | Abstract  |
| `cache_pool_company`   | Company   |
| `cache_pool_partners`  | Partners  |
| `cache_pool_products`  | Products  |
| `cache_pool_resources` | Resources |
| `cache_pool_team`      | Team      |
| `cache_pool_tools`     | Tools     |

Naming pattern:

- Core domains: `cache_pool_{domain}`
- Provider integrations: `cache_pool_providers_{provider_path}`

When adding a new provider, add a matching pool to both `config/packages/dev/cache.yaml` and `config/packages/prod/cache.yaml`.

### Injection Pattern

**Simple cache** — use `CacheInterface` with `#[Target]`:

```php
use Symfony\Component\DependencyInjection\Attribute\Target;
use Symfony\Contracts\Cache\CacheInterface;

#[Target('cache_pool_company')]
private readonly CacheInterface $cache,
```

**Tag-based invalidation** — use `TagAwareCacheInterface` with `#[Target]`:

```php
use Symfony\Contracts\Cache\TagAwareCacheInterface;

#[Target('cache_pool_providers_finance_app_agencies_ecos')]
private readonly TagAwareCacheInterface $cache,

// Storing with tags:
$value = $this->cache->get('ecos_data_key', function (ItemInterface $item): array {
    $item->expiresAfter($this->isDebug ? 5 : 21600);
    $item->tag(['ecos', 'ecos_economic']);

    return $this->service->fetch();
});

// Invalidating by tag:
$this->cache->invalidateTags(['ecos']);
```

### TTL Reference

| Context                              | Debug TTL | Production TTL         |
| ------------------------------------ | --------- | ---------------------- |
| Company / controller data            | 10 s      | 3600 s (1 h)           |
| Financial agency data (ECOS / KOSIS) | 5–10 s    | 21600–86400 s (6–24 h) |
| Real-time market data (example)      | 5 s       | 30 s                   |
| Candle / orderbook data (example)    | 5 s       | 600 s (10 min)         |
| Twig extension runtime               | 30 s      | 3600 s (1 h)           |

### Environment Adapter Matrix

The `app` adapter changes per environment; all 15 pools always use Redis:

| Environment | `app` adapter              | Pool adapter          |
| ----------- | -------------------------- | --------------------- |
| `dev`       | `cache.adapter.filesystem` | `cache.adapter.redis` |
| `prod`      | `cache.adapter.array`      | `cache.adapter.redis` |

The `app` adapter difference means Symfony's internal metadata (routes, DI container) is stored on the filesystem in `dev` and in memory in `prod` — Redis pools are unaffected by this distinction.
