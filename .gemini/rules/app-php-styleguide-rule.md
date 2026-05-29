# Symfony Project Style Guide for Gemini Code Assist

This style guide defines the coding standards and conventions for our Symfony project.
Gemini Code Assist must follow these rules when reviewing pull requests and suggesting code changes.

---

## 1. PHP & Symfony Version Requirements

- **Minimum PHP version: 8.2+**
    - Use `readonly` properties wherever applicable.
    - Use union types, intersection types, and `never` return types as appropriate.
    - Use named arguments for clarity when calling functions with multiple parameters.
    - Use fibers and enums (`enum`) where applicable.
- **Target framework: Symfony 6.4 LTS or Symfony 7.x**
    - Always follow the conventions of the targeted Symfony version.
    - Do not use deprecated APIs from older Symfony versions.

---

## 2. PHP Attributes (Annotations Strictly Forbidden)

- **Always use PHP 8 Attributes** for routing, ORM mapping, validation, and security.
- **Never use Doctrine-style annotations** (PHPDoc `@`-based annotations).

### Routing
```php
// ✅ Correct
#[Route('/user/{id}', name: 'user_show', methods: ['GET'])]
public function show(int $id): Response {}

// ❌ Wrong
/**
 * @Route("/user/{id}", name="user_show", methods={"GET"})
 */
public function show(int $id): Response {}
```

### Doctrine ORM Mapping
```php
// ✅ Correct
#[ORM\Entity(repositoryClass: UserRepository::class)]
#[ORM\Table(name: 'users')]
class User
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column(type: 'integer')]
    private int $id;

    #[ORM\Column(length: 180, unique: true)]
    private string $email;
}

// ❌ Wrong
/**
 * @ORM\Entity(repositoryClass="App\Repository\UserRepository")
 * @ORM\Table(name="users")
 */
class User {}
```

### Validation
```php
// ✅ Correct
#[Assert\NotBlank]
#[Assert\Email]
#[Assert\Length(min: 2, max: 50)]
private string $email;

// ❌ Wrong
/** @Assert\NotBlank */
/** @Assert\Email */
private string $email;
```

---

## 3. Dependency Injection

- **Always prefer constructor injection** over setter injection or property injection.
- Use **autowiring and autoconfiguration** as the default strategy.
- Do not manually register services that can be autowired.
- Use `#[Target]` or specific type-hints to disambiguate when multiple implementations exist.
- Use `#[Autowire]` attribute for scalar parameters or service references when needed.

```php
// ✅ Correct — Constructor injection with autowiring
final class OrderService
{
    public function __construct(
        private readonly OrderRepository $orderRepository,
        private readonly MailerInterface $mailer,
        #[Autowire('%app.order_limit%')] private readonly int $orderLimit,
    ) {}
}

// ❌ Wrong — Setter injection
class OrderService
{
    private OrderRepository $orderRepository;

    public function setOrderRepository(OrderRepository $repo): void
    {
        $this->orderRepository = $repo;
    }
}
```

- Use `readonly` properties in constructor-injected services to prevent mutation.
- Declare classes as `final` unless explicitly designed for inheritance.

---

## 4. Directory Structure & Namespace Conventions

Follow the standard Symfony project layout:

```
src/
├── Controller/         # HTTP controllers only — no business logic
├── Entity/             # Doctrine ORM entities
├── Repository/         # Doctrine repositories (extend ServiceEntityRepository)
├── Service/            # Business logic and application services
├── Form/               # Symfony Form types (suffix: Type)
├── EventSubscriber/    # Event subscribers (implements EventSubscriberInterface)
├── EventListener/      # Event listeners
├── Command/            # Console commands (suffix: Command)
├── DTO/                # Data Transfer Objects (immutable, readonly preferred)
├── Validator/          # Custom validators and constraints
├── Security/           # Security voters, authenticators
├── Twig/               # Twig extensions and runtime classes
└── Exception/          # Custom domain exceptions

templates/              # Twig templates (.html.twig)
config/
├── packages/           # Bundle configuration
├── routes/             # Route configuration (prefer Attribute routing)
└── services.yaml       # Service configuration (minimal, rely on autowiring)
```

- All namespaces must follow **PSR-4** and match the directory structure under `src/`.
- Template files must use the `.html.twig` extension.

---

## 5. Naming Conventions

### Controllers
- Suffix: `Controller` (e.g., `UserController`, `ProductController`)
- Must extend `AbstractController`
- One controller per resource domain; group related actions within the same controller
- Return only `Response`, `JsonResponse`, or `RedirectResponse`

```php
// ✅ Correct
#[Route('/products', name: 'product_')]
final class ProductController extends AbstractController
{
    #[Route('/', name: 'index', methods: ['GET'])]
    public function index(): Response {}

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(Product $product): Response {}
}
```

### Entities
- Use **singular nouns** (e.g., `User`, `Product`, `Order`)
- No suffix needed
- All entity properties must be `private`; expose via getters/setters or public readonly

### Repositories
- Suffix: `Repository` (e.g., `UserRepository`, `ProductRepository`)
- Must extend `ServiceEntityRepository`
- All custom query methods must have explicit return types

```php
// ✅ Correct
final class UserRepository extends ServiceEntityRepository
{
    /** @return User[] */
    public function findActiveUsers(): array
    {
        return $this->createQueryBuilder('u')
            ->where('u.active = :active')
            ->setParameter('active', true)
            ->getQuery()
            ->getResult();
    }
}
```

### Services
- Descriptive names reflecting their role (e.g., `OrderProcessingService`, `EmailNotificationService`)
- Follow PSR-4 naming

### Form Types
- Suffix: `Type` (e.g., `UserType`, `RegistrationFormType`)

### Commands
- Suffix: `Command` (e.g., `SendEmailCommand`, `ImportProductsCommand`)
- Use `#[AsCommand]` attribute with a descriptive name

```php
#[AsCommand(name: 'app:import-products', description: 'Import products from CSV')]
final class ImportProductsCommand extends Command {}
```

### Events
- Past-tense, descriptive names (e.g., `UserRegisteredEvent`, `OrderPlacedEvent`)

---

## 6. Security

- **Always use `#[IsGranted()]`** attribute for access control in controllers.
- Do not use `$this->denyAccessUnlessGranted()` inline when an attribute can be used.
- Use `Symfony\Component\Security\Http\Attribute\IsGranted` (not the old SensioFrameworkExtraBundle version).

```php
// ✅ Correct
#[IsGranted('ROLE_ADMIN')]
#[Route('/admin/users', name: 'admin_users')]
public function listUsers(): Response {}

// ✅ Correct — Voter-based
#[IsGranted('EDIT', subject: 'post')]
#[Route('/post/{id}/edit', name: 'post_edit')]
public function edit(Post $post): Response {}

// ❌ Wrong — inline check
public function listUsers(): Response
{
    $this->denyAccessUnlessGranted('ROLE_ADMIN');
}
```

- Implement **custom Voters** for complex authorization logic.
- Always use `UserInterface` for the user entity.
- Use `PasswordHasherInterface` for password hashing — never use plain `md5` or `sha1`.
- Validate and sanitize all user input using Symfony's Validator component.
- Enable CSRF protection on all state-changing forms.

---

## 7. Controllers

- Controllers must be **thin** — delegate all business logic to services.
- Do not put database queries directly in controllers.
- Do not instantiate services manually inside controllers (use DI).
- Use **ParamConverter / `#[MapEntity]`** to resolve entities from route parameters.

```php
// ✅ Correct — thin controller, uses service and MapEntity
final class OrderController extends AbstractController
{
    public function __construct(
        private readonly OrderService $orderService,
    ) {}

    #[Route('/orders/{id}/confirm', name: 'order_confirm', methods: ['POST'])]
    #[IsGranted('ROLE_USER')]
    public function confirm(
        #[MapEntity(id: 'id')] Order $order,
    ): Response {
        $this->orderService->confirm($order);
        return $this->redirectToRoute('order_show', ['id' => $order->getId()]);
    }
}

// ❌ Wrong — fat controller with business logic
public function confirm(int $id): Response
{
    $order = $this->entityManager->find(Order::class, $id);
    $order->setStatus('confirmed');
    $order->setUpdatedAt(new \DateTimeImmutable());
    $this->mailer->send(...);
    $this->entityManager->flush();
    return $this->redirectToRoute('order_show', ['id' => $id]);
}
```

---

## 8. Doctrine ORM & Database

- Use **Doctrine Migrations** for all schema changes — never modify the schema manually.
- Always use **repositories** for data access — do not inject `EntityManagerInterface` into controllers.
- Use `EntityManagerInterface` only in services and repositories.
- Prefer `findBy`, `findOneBy`, or QueryBuilder over raw SQL unless necessary.
- Use `#[ORM\Index]` for frequently queried columns.
- Use `DateTimeImmutable` for date fields — not `DateTime`.

```php
// ✅ Correct
#[ORM\Column(type: Types::DATETIME_IMMUTABLE)]
private \DateTimeImmutable $createdAt;

// ❌ Wrong
#[ORM\Column(type: 'datetime')]
private \DateTime $createdAt;
```

- Define cascade operations explicitly and avoid unnecessary `cascade: ['all']`.

---

## 9. Twig Templates

- All templates must be in the `templates/` directory with `.html.twig` extension.
- Use Twig **inheritance** with a `base.html.twig` layout.
- Do not write PHP logic in Twig templates — offload to Twig extensions or controllers.
- Use `{{ asset() }}` for static assets and `{{ path() }}` / `{{ url() }}` for routes.
- Escape output using `|e` filter or rely on Twig's auto-escaping.
- Do not use raw SQL or service calls inside templates.

---

## 10. Forms

- All form classes must extend `AbstractType` and be placed in `src/Form/`.
- Define `buildForm()` and `configureOptions()` with explicit types.
- Always set `data_class` in `configureOptions()` when binding to an entity or DTO.
- Use **DTO objects** as form data classes instead of entities where applicable.

```php
// ✅ Correct
final class RegistrationFormType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options): void
    {
        $builder
            ->add('email', EmailType::class)
            ->add('password', RepeatedType::class, [
                'type' => PasswordType::class,
            ]);
    }

    public function configureOptions(OptionsResolver $resolver): void
    {
        $resolver->setDefaults(['data_class' => RegistrationDto::class]);
    }
}
```

---

## 11. Testing

- Use **PHPUnit** for unit and integration tests.
- Use `WebTestCase` for functional (HTTP) tests.
- Use `KernelTestCase` for service-level integration tests.
- Test file structure must mirror `src/` under `tests/`.
- All public service methods should have corresponding unit tests.
- Use data providers for parameterized tests.
- Mock external dependencies using PHPUnit `MockObject` or Prophecy.

```php
// ✅ Correct
final class OrderServiceTest extends TestCase
{
    public function testConfirmOrder(): void
    {
        $repository = $this->createMock(OrderRepository::class);
        $service = new OrderService($repository);
        // ...assert expected behavior
    }
}
```

---

## 12. Code Style & Quality

- Follow **Symfony Coding Standards** (based on PSR-12 with Symfony-specific rules).
- Use **PHP CS Fixer** with the Symfony ruleset for all formatting.
- Use **PHPStan at level 8+** for static analysis — all code must pass without errors.
- Declare `strict_types=1` at the top of every PHP file.
- Avoid `mixed` types — always use explicit types.
- Use `final` on classes that are not designed for extension.
- Avoid magic numbers — extract into named constants or configuration parameters.

```php
// ✅ Correct
<?php

declare(strict_types=1);

namespace App\Service;

final class PricingService
{
    private const VAT_RATE = 0.21;

    public function calculateWithVat(float $price): float
    {
        return $price * (1 + self::VAT_RATE);
    }
}
```

---

## 13. Event System & Messaging

- Use **Symfony EventDispatcher** for domain events within the application.
- Use **Symfony Messenger** for asynchronous processing and command/query buses.
- Implement `EventSubscriberInterface` for event subscribers.
- Use `#[AsEventListener]` attribute for simple event listeners.

```php
// ✅ Correct
#[AsEventListener(event: UserRegisteredEvent::class)]
final class SendWelcomeEmailListener
{
    public function __invoke(UserRegisteredEvent $event): void {}
}
```

---

## 14. Configuration & Environment

- Use `.env` for default values; use `.env.local` for local overrides (never commit `.env.local`).
- Access parameters via `#[Autowire('%parameter_name%')]` or `ParameterBagInterface`.
- Do not hardcode environment-specific values in PHP files.
- Use `config/packages/` for bundle configuration — prefer YAML format.

---

## 15. Error Handling & Logging

- Use **Monolog** via `LoggerInterface` for all logging.
- Do not use `var_dump()`, `print_r()`, or `echo` for debugging in production code.
- Throw domain-specific exceptions that extend `\RuntimeException` or `\LogicException`.
- Use Symfony's exception listeners or `#[Route]` error pages for user-facing errors.

```php
// ✅ Correct
final class OrderNotFoundException extends \RuntimeException
{
    public static function forId(int $id): self
    {
        return new self(sprintf('Order with ID %d was not found.', $id));
    }
}
```

---

## Code Review Focus Areas for Symfony

When reviewing pull requests, Gemini Code Assist must **flag** the following as issues:

| Category | Flag as Issue |
|---|---|
| Annotations | Any `@ORM`, `@Route`, `@Assert` annotation usage |
| Fat Controllers | Business logic or DB queries inside controllers |
| Missing Access Control | Controllers without `#[IsGranted()]` on sensitive routes |
| Missing Types | Functions/methods without full type declarations |
| Direct EM in Controllers | `EntityManagerInterface` injected into controllers |
| Mutable Dates | Use of `\DateTime` instead of `\DateTimeImmutable` |
| Missing `strict_types` | PHP files without `declare(strict_types=1)` |
| Hardcoded Values | Magic numbers or hardcoded environment values |
| Raw SQL in Controllers | SQL queries outside of Repository classes |
| Missing Tests | New public service methods without test coverage |