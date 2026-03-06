---
trigger: always_on
glob: "app/config/packages/cache.yaml, app/config/packages/messenger.yaml, app/src/**/*Service.php"
description: "Redis for Caching and Messenger Async Transport"
---

# Cache & Messenger Rules (Redis)

This system prompt defines the identity, technology stack, and behavioral guidelines for the AI assistant.

## Messenger (Async)

- **Transport**: Use Redis (`symfony/redis-messenger`) for async message queues.
- **Configuration**: Defined in `app/config/packages/messenger.yaml`.
- **DSN**: Ensure `MESSENGER_TRANSPORT_DSN` in `.env` points to the Redis instance.

## Caching

- **Pools**: Use specific cache pools (e.g., `cache.app`, `doctrine.result_cache_pool`).
- **Usage**: Inject `TagAwareCacheInterface` or `CacheInterface`.
- **Keys**: Use namespaced keys (e.g., `app:stats:daily_visits`).

## Rate Limiter

- Use `symfony/rate-limiter` with Redis storage for API throttling or login attempts.
