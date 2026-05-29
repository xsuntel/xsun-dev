# App PHP Rules (Symfony 8.0 & PHP 8.4)

This system prompt defines the identity, technology stack, and behavioral guidelines for the AI assistant.

## Core Language & Style Standards

- **PHP Version**: All code must be compatible with **PHP 8.4**. Use modern features like property hooks, asymmetric visibility, and the `#[\Deprecated]` attribute where appropriate.
- **Strict Types**: `declare(strict_types=1);` is mandatory and must be the first statement in every PHP file.
- **Final by Default**: All classes (Entities, Services, Controllers, etc.) must be declared as `final` unless they are explicitly designed for extension.
- **Readonly Properties**: Use `readonly` for constructor-promoted properties to enforce immutability.
- **PSR Standards**: Strictly adhere to PSR-12 (Code Style) and PSR-4 (Autoloading).

## Architecture: CQRS & Messenger

The application follows a strict Command Query Responsibility Segregation (CQRS) pattern using Symfony Messenger.

- **Commands (Write Operations)**:
    - Location: `app/src/MessageCommand/`
    - Naming: Use imperative verbs (e.g., `CreateUserCommand.php`).
    - Handler Location: `app/src/MessageCommandHandler/`
    - Handler Signature: `public function __invoke(CreateUserCommand $command): void`
    - Attribute: `#[AsMessageHandler]` is required on the handler.
- **Queries (Read Operations)**:
    - Location: `app/src/MessageQuery/`
    - Naming: Use descriptive nouns (e.g., `FindUserByIdQuery.php`).
    - Handler Location: `app/src/MessageQueryHandler/`
    - Handler Signature: `public function __invoke(FindUserByIdQuery $query): UserDTO` (or other appropriate return type).
    - Attribute: `#[AsMessageHandler]` is required on the handler.
- **Events (Side Effects)**:
    - Location: `app/src/MessageEvent/`
    - Naming: Use past-tense verbs (e.g., `UserWasCreatedEvent.php`).
    - Handler Location: `app/src/MessageEventHandler/`

**Controllers must not contain business logic.** They should only dispatch a Command or Query message and return the response.

## Data Persistence: Doctrine & PostgreSQL

- **Entities**:
    - Location: `app/src/Entity/`
    - Mapping: Use **PHP Attributes only** (`#[ORM\Entity]`, `#[ORM\Column]`, etc.). Annotation mapping (`@ORM\...`) is forbidden.
    - Properties: Must be typed.
- **Repositories**:
    - Location: `app/src/EntityRepository/`
    - Implementation: Extend `Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository`.
- **State Changes**: Do not implement public setters on entities for properties managed by a state machine. State transitions must be handled exclusively through the **Symfony Workflow** component to ensure integrity.

## API Layer: API Platform

- **API Resources**:
    - Location: `app/src/ApiResource/`
    - Attribute: Use `#[ApiResource]` on the class to expose it as a REST/GraphQL endpoint.
    - Operations: Define operations (GET, POST, etc.) and their corresponding processors or providers within the `#[ApiResource]` attribute.
- **Data Transfer Objects (DTOs)**: Use DTOs as input and output for API resources to decouple the API layer from the domain model (entities). Apply validation constraints to input DTOs.

## Other Key Components

- **Twig Components**:
    - Location: `app/src/Twig/Components/`
    - Attributes: Use `#[AsTwigComponent]` for standard components and `#[AsLiveComponent]` for reactive, stateful components.
- **Scheduler**:
    - Location: `app/src/Scheduler/`
    - Attribute: Use `#[AsSchedule]` on a provider class to define recurring tasks.
- **Security**:
    - Apply `#[IsCsrfTokenValid]` attribute for CSRF protection on controller actions that handle form submissions.
    - Use the `symfony/rate-limiter` for all authentication and public-facing API endpoints.
