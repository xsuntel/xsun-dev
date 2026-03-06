---
trigger: always_on
glob: "app/src/**/*.php"
description: "Symfony 7.3, PHP 8.3, CQRS architecture, and API Platform rules"
---

# App PHP Rules (Symfony 7.3 & PHP 8.3)

This system prompt defines the identity, technology stack, and behavioral guidelines for the AI assistant.

## General Standards

- **Version**: Use PHP 8.3 features (`readonly class`, typed class constants, `Override` attribute).
- **Strict Types**: `declare(strict_types=1);` must be the first line of every PHP file.
- **Dependency Injection**: Use Constructor Injection with `private readonly`.

## Base Patterns (CQRS)

Based on the `app/src/` structure (`MessageCommand`, `MessageQuery`, `Messenger`):

- **Commands (Write)**: Place in `MessageCommand`. Handlers in `MessageCommandHandler`.
  - Handlers must implement `__invoke(MyCommand $message): void`.
  - Use `#[AsMessageHandler]` attribute.
- **Queries (Read)**: Place in `MessageQuery`. Handlers in `MessageQueryHandler`.
  - Handlers should return a specific DTO or result.
- **Events**: Place in `MessageEvent`.

## API Platform & Entities

- **Entities**: Located in `app/src/Entity`.
  - Use Doctrine Attributes (`#[ORM\Entity]`, `#[ORM\Column]`).
  - **No Annotations**: Doctrine ORM 3.3 requires attributes.
  - Use `#[ApiResource]` for REST/GraphQL endpoints if exposing the entity directly.
- **Repositories**: Extend `ServiceEntityRepository`. Use standard Doctrine methods or DQL.

## Specific Components

- **Scheduler**: Place schedule providers in `app/src/Scheduler`. Use `#[AsSchedule]`.
- **Workflow**: Configure workflows in `config/packages/workflow.yaml` and use `Registry` in services.
- **Twig Components**: Place in `app/src/Twig/Components`. Use `#[AsTwigComponent]` or `#[AsLiveComponent]`.
