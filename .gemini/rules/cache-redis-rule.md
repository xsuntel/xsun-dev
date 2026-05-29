# Redis Usage Rules (Cache, Messenger, Lock, Session)

This system prompt defines the identity, technology stack, and behavioral guidelines for the AI assistant. Redis is a critical component of the infrastructure and must be used correctly for its designated roles.

## 1. Caching Layer

- **Primary Interface**: Inject `Symfony\Contracts\Cache\TagAwareCacheInterface` for all application-level caching. This allows for fine-grained cache invalidation using tags.
- **Cache Pools**: Configure dedicated cache pools in `app/config/packages/cache.yaml` for different parts of the application (e.g., `cache.app`, `cache.api_responses`). Do not use the default system pool for application data.
- **Cache Keys**: Use a consistent, namespaced key format to avoid collisions. A good practice is `<service_name>:<entity_name>:<id>`.
- **Doctrine Caching**: Redis is configured for Doctrine's metadata, query, and result caches in production environments to optimize database performance. This is configured in `app/config/packages/doctrine.yaml`.

## 2. Symfony Messenger Transport

- **Role**: Redis serves as the **secondary, lightweight transport** for internal, ephemeral, or non-critical asynchronous tasks.
- **When to Use**:
    - Fast-processing jobs where persistence is not critical.
    - Session-bound or user-specific queues.
    - Tasks where a slight chance of message loss during a crash is acceptable.
- **When NOT to Use**: For high-reliability tasks, external system integration, or jobs requiring complex retry strategies, **use RabbitMQ**.
- **Configuration**: The Redis transport is configured in `app/config/packages/messenger.yaml` under a specific transport name (e.g., `async_redis`). Messages are routed to it in `framework.messenger.routing`.

## 3. Distributed Locking (Symfony Lock)

- **Purpose**: To prevent race conditions and ensure that critical or long-running tasks (e.g., console commands, message handlers) do not execute concurrently.
- **Implementation**:
    - Inject `Symfony\Component\Lock\LockFactory` into your service or command.
    - Create a lock: `$lock = $lockFactory->createLock('my-unique-lock-key', 3600);`
    - Acquire the lock: `if ($lock->acquire()) { ... $lock->release(); }`
- **Storage**: The lock store is configured to use Redis for distributed consistency across multiple application instances.

## 4. Session Storage

- **Configuration**: The `framework.session.handler_id` in `app/config/packages/framework.yaml` is configured to use a Redis-based session handler.
- **Benefit**: This provides scalable, distributed session management, allowing user sessions to persist across different servers in a load-balanced environment. Avoid the default file-based session storage in production.
