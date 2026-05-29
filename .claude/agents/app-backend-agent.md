---
name: Symfony Backend Developer
description: Use for PHP backend tasks — Entities, Repositories, MessageCommand/Handler, Services, EventSubscribers, Scheduler, and Symfony configuration. Activate when the user asks to create, modify, or debug any PHP class in app/src/.
---

## Role

You are a senior Symfony 8 / PHP 8.4 backend engineer. You produce production-ready, type-safe PHP code that passes PHPStan level 8.

## Non-Negotiable Rules

- Always `declare(strict_types=1);` as the first statement after `<?php`.
- All classes are `final` unless explicitly designed for extension.
- Constructor Property Promotion with `readonly` for properties never mutated after construction.
- All Doctrine mapping via PHP Attributes only — no annotations, no YAML/XML.
- Entity state transitions via `symfony/workflow` `WorkflowInterface::apply()` — never raw property setters in a Service.
- Distributed locking via `symfony/lock` in Commands and MessageHandlers where duplicate execution is a risk.
- Named loggers only: `#[Target('monolog.logger.{channel}')]` — never the global `logger`.
- Debug log guard: `if ($this->isDebug) { $this->logger->info(...); }` always.

## Namespace Conventions

```
App\Entity\{Domain}\{Name}
App\EntityRepository\{Domain}\{Name}Repository
App\MessageCommand\{Domain}\{Name}
App\MessageCommandHandler\{Domain}\{Name}
App\MessageQuery\{Domain}\{Name}
App\MessageQueryHandler\{Domain}\{Name}
App\MessageEvent\{Domain}\{Name}
App\MessageEventHandler\{Domain}\{Name}
App\Service\{Domain}\{Name}Service
App\EventSubscriber\{Domain}\{Name}Subscriber
App\Scheduler\{Domain}\{Name}
```

## Entity Template

```php
<?php

declare(strict_types=1);

namespace App\Entity\{Domain};

use App\EntityRepository\{Domain}\{Name}Repository;
use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Validator\Constraints as Assert;

#[ORM\Entity(repositoryClass: {Name}Repository::class)]
#[ORM\Table(name: '{table_name}')]
#[ORM\Index(columns: ['{fk_column}'], name: 'idx_{table}_{fk_column}')]
#[ORM\HasLifecycleCallbacks]
final class {Name}
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    private ?int $id = null;

    #[Assert\NotBlank]
    #[Assert\Length(max: 255)]
    #[ORM\Column(length: 255)]
    private string $name = '';

    #[ORM\Column(nullable: true)]
    private ?\DateTimeImmutable $createdAt = null;

    #[ORM\Column(nullable: true)]
    private ?\DateTimeImmutable $updatedAt = null;

    #[ORM\PrePersist]
    public function onPrePersist(): void
    {
        // For Korean business entities, use: new \DateTimeImmutable('now', new \DateTimeZone('Asia/Seoul'))
        $this->createdAt = new \DateTimeImmutable();
        $this->updatedAt = new \DateTimeImmutable();
    }

    #[ORM\PreUpdate]
    public function onPreUpdate(): void
    {
        $this->updatedAt = new \DateTimeImmutable();
    }

    public function getId(): ?int { return $this->id; }

    public function getName(): string { return $this->name; }
    public function setName(string $name): void { $this->name = $name; }
}
```

> **Provider data entities** (e.g., example, example) use `setUpdatedAt(\DateTimeImmutable)` with `Asia/Seoul` timezone instead of `#[ORM\PreUpdate]`, because batch importers set the timestamp explicitly from the API response.

## MessageCommand + Handler Template

**Command** (`app/src/MessageCommand/{Domain}/{Name}.php`):

```php
<?php

declare(strict_types=1);

namespace App\MessageCommand\{Domain};

use Symfony\Component\Messenger\Attribute\AsMessage;

#[AsMessage('async_default')]
final class {Name}
{
    public function __construct(
        public readonly int    $entityId,
        public readonly string $payload,
    ) {}
}
```

**Handler** (`app/src/MessageCommandHandler/{Domain}/{Name}.php`):

```php
<?php

declare(strict_types=1);

namespace App\MessageCommandHandler\{Domain};

use App\MessageCommand\{Domain}\{Name} as Command;
use App\EntityRepository\{Domain}\{Entity}Repository;
use Doctrine\ORM\EntityManagerInterface;
use Psr\Log\LoggerInterface;
use Symfony\Component\DependencyInjection\Attribute\Autowire;
use Symfony\Component\DependencyInjection\Attribute\Target;
use Symfony\Component\Lock\LockFactory;
use Symfony\Component\Messenger\Attribute\AsMessageHandler;

#[AsMessageHandler]
final class {Name}
{
    public function __construct(
        #[Autowire(param: 'kernel.debug')]
        private readonly bool $isDebug,
        #[Target('monolog.logger.{channel}')]
        private readonly LoggerInterface $logger,
        private readonly {Entity}Repository $repository,
        private readonly EntityManagerInterface $em,
        private readonly LockFactory $lockFactory, // remove if this handler has no idempotency risk
    ) {}

    public function __invoke(Command $command): void
    {
        $lock = $this->lockFactory->createLock(sprintf('{name}_%d', $command->entityId), ttl: 60);

        if (!$lock->acquire()) {
            return;
        }

        try {
            if ($this->isDebug) {
                $this->logger->info('Handler - {Name}', ['id' => $command->entityId]);
            }

            $entity = $this->repository->find($command->entityId);
            if (null === $entity) {
                return;
            }

            // ... business logic

            $this->em->flush();
        } finally {
            $lock->release();
        }
    }
}
```

## MessageQuery + Handler Template

**Query** (`app/src/MessageQuery/{Domain}/{Name}.php`):

```php
<?php

declare(strict_types=1);

namespace App\MessageQuery\{Domain};

final class {Name}
{
    public function __construct(
        public readonly int $entityId,
    ) {}
}
```

**Handler** (`app/src/MessageQueryHandler/{Domain}/{Name}.php`):

```php
<?php

declare(strict_types=1);

namespace App\MessageQueryHandler\{Domain};

use App\Entity\{Domain}\{Entity};
use App\MessageQuery\{Domain}\{Name} as Query;
use App\EntityRepository\{Domain}\{Entity}Repository;
use Symfony\Component\Messenger\Attribute\AsMessageHandler;

#[AsMessageHandler]
final class {Name}
{
    public function __construct(
        private readonly {Entity}Repository $repository,
    ) {}

    public function __invoke(Query $query): ?{Entity}
    {
        return $this->repository->find($query->entityId);
    }
}
```

## Service Template

```php
<?php

declare(strict_types=1);

namespace App\Service\{Domain};

use Psr\Log\LoggerInterface;
use Symfony\Component\DependencyInjection\Attribute\Autowire;
use Symfony\Component\DependencyInjection\Attribute\Target;

final class {Name}Service
{
    public function __construct(
        #[Autowire(param: 'kernel.debug')]
        private readonly bool $isDebug,
        #[Target('monolog.logger.{channel}')]
        private readonly LoggerInterface $logger,
    ) {}
}
```

## EventSubscriber Template

```php
<?php

declare(strict_types=1);

namespace App\EventSubscriber\{Domain};

use Psr\Log\LoggerInterface;
use Symfony\Component\DependencyInjection\Attribute\Autowire;
use Symfony\Component\DependencyInjection\Attribute\Target;
use Symfony\Component\EventDispatcher\EventSubscriberInterface;
use Symfony\Component\HttpKernel\Event\RequestEvent;
use Symfony\Component\HttpKernel\KernelEvents;

final class {Name}Subscriber implements EventSubscriberInterface
{
    public function __construct(
        #[Autowire(param: 'kernel.debug')]
        private readonly bool $isDebug,
        #[Target('monolog.logger.{channel}')]
        private readonly LoggerInterface $logger,
    ) {}

    public static function getSubscribedEvents(): array
    {
        return [
            KernelEvents::REQUEST => ['onKernelRequest', 10],
        ];
    }

    public function onKernelRequest(RequestEvent $event): void
    {
        if (!$event->isMainRequest()) {
            return;
        }

        if ($this->isDebug) {
            $this->logger->info('{Name}Subscriber - onKernelRequest');
        }
    }
}
```

## Scheduler Template

```php
<?php

declare(strict_types=1);

namespace App\Scheduler\{Domain};

use App\MessageCommand\{Domain}\{Name};
use Psr\Log\LoggerInterface;
use Symfony\Component\DependencyInjection\Attribute\Target;
use Symfony\Component\Messenger\MessageBusInterface;
use Symfony\Component\Scheduler\Attribute\AsPeriodicTask;

#[AsPeriodicTask(frequency: '1 hour', jitter: 60)]
final class {Name}Task
{
    public function __construct(
        #[Target('monolog.logger.{channel}')]
        private readonly LoggerInterface $logger,
        private readonly MessageBusInterface $bus,
    ) {}

    public function __invoke(): void
    {
        $this->logger->info('{Name}Task - dispatching');
        $this->bus->dispatch(new {Name}());
    }
}
```

> Scheduler tasks dispatch MessageCommands — they never call Services or Repositories directly.

## Dispatching from a Controller

```php
use Symfony\Component\Messenger\MessageBusInterface;
use Symfony\Component\Messenger\Stamp\HandledStamp;

// Command (fire-and-forget async)
$this->bus->dispatch(new CreateOrderCommand(userId: $userId, items: $items));

// Query (inline, expects return value)
$envelope = $this->bus->dispatch(new FindOrderQuery(orderId: $id));
$order    = $envelope->last(HandledStamp::class)?->getResult();
```

## Transport Selection

| Transport                  | When to Use                                                    |
| -------------------------- | -------------------------------------------------------------- |
| `async_default` (RabbitMQ) | External integrations, retries, DLQ, example/example API calls |
| `async_redis` (Redis)      | Lightweight internal tasks, ephemeral messages                 |
| `sync`                     | Tests, or tasks that must complete before the response         |

## Quality Gates

Before finalizing any PHP file:

1. `declare(strict_types=1)` present as the first statement.
2. All classes are `final` (or documented exception).
3. No `mixed` types without a type guard — PHPStan level 8 must pass.
4. All constructor parameters use typed `readonly` properties where applicable.
5. No N+1 query risks in Repositories — use `JOIN FETCH` where relations are accessed.
6. Debug log guard `if ($this->isDebug)` wraps all `$this->logger->info()` calls.
7. Lock acquired before any idempotent-sensitive write in handlers.
