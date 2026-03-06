---
trigger: always_on
glob: "app/config/packages/messenger.yaml, app/src/MessageCommand/**/*.php, app/src/MessageEvent/**/*.php, app/.env*"
description: "RabbitMQ (AMQP) configuration, exchange/queue routing, and reliability strategies"
---

# Message Rules (RabbitMQ / AMQP)

This system prompt defines the identity, technology stack, and behavioral guidelines for the AI assistant.

## Core Principles

- **Usage Role**: Use RabbitMQ for critical business logic (Commands/Events) requiring durability, complex routing, or
  reliability. (Use Redis for simple, ephemeral tasks).
- **Transport**: Configured via `amqp://` DSN in `.env`.

## Configuration (messenger.yaml)

- **Exchanges & Queues**:
  - Prefer `fanout` exchanges for Events (Broadcast to multiple queues).
  - Prefer `direct` or `topic` exchanges for Commands (Target specific queues).
- **Auto-setup**: Ensure `auto_setup: true` is enabled in dev/test to create queues automatically.
- **Serialization**: Use Symfony Serializer (JSON) to make messages language-agnostic if needed.

## Routing Strategy (CQRS)

- **Commands**: Route to a specific work queue.
  - Example: `App\MessageCommand\RegisterUser` -> `amqp_command_transport`
- **Events**: Route to an exchange that distributes to subscribers.
  - Example: `App\MessageEvent\UserRegistered` -> `amqp_event_transport`

## Reliability & Error Handling

- **Dead Letter Queue (DLQ)**: ALWAYS configure a `failed` transport backed by a separate queue/storage to catch
  messages that fail after retries.
- **Retries**: Configure `retry_strategy` (e.g., exponential backoff) in `messenger.yaml`.

## Worker Management

- **Consumption**: Run php bin/console messenger:consume amqp -vv inside app/.
- **Production**: Use Supervisor or Systemd to keep workers alive.
- **Limit**: Use --limit=10 or --time-limit=3600 to prevent memory leaks in PHP long-running processes.

## Debugging

- Use RabbitMQ Management Interface (usually port 15672) to inspect queues.
- **CLI**: php bin/console messenger:stats amqp
