---
paths:
  - "app/tests/**/*"
---

# Testing Rules

These rules apply to all files under `app/tests/`.

@see https://symfony.com/doc/current/testing.html

## Test Layers

| Layer | Base Class | Directory | Boots Kernel | I/O |
|-------|------------|-----------|-------------|-----|
| Unit | `TestCase` | `app/tests/Unit/` | No | None |
| Integration | `KernelTestCase` | `app/tests/Integration/` | Yes | Real PostgreSQL + Redis |
| Functional | `WebTestCase` | `app/tests/Functional/` | Yes | HTTP layer |

- **Unit tests** must not touch the filesystem, database, cache, or network.
- **Integration tests** must use a **real PostgreSQL instance** — mocked databases are forbidden (prior incident: mock/prod divergence masked a broken migration).
- **Functional tests** assert HTTP responses, redirects, and rendered HTML — not internal service state.

## Namespace Convention

```
App\Tests\Unit\{Domain}\{ClassName}Test
App\Tests\Integration\{Domain}\{ClassName}Test
App\Tests\Functional\{Domain}\{ControllerName}Test
```

- Unit: `app/tests/Unit/{Domain}/{ClassName}Test.php`
- Integration: `app/tests/Integration/{Domain}/{ClassName}Test.php`
- Functional: `app/tests/Functional/{Domain}/{ControllerName}Test.php`
- Test method names: `it_{describes_behavior}()` (unit/integration), `test_{route}_{assertion}()` (functional).

## Unit Test Template

```php
<?php

declare(strict_types=1);

namespace App\Tests\Unit\{Domain};

use PHPUnit\Framework\TestCase;
use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\Attributes\Test;

final class {Name}Test extends TestCase
{
    #[Test]
    public function it_{describes_behavior}(): void
    {
        // Arrange
        // ...

        // Act
        // ...

        // Assert
        $this->assertSame(expected: ..., actual: ...);
    }

    #[DataProvider('provide{Scenarios}')]
    #[Test]
    public function it_{describes_data_driven_behavior}(mixed $input, mixed $expected): void
    {
        // ...
    }

    /** @return iterable<string, array{mixed, mixed}> */
    public static function provide{Scenarios}(): iterable
    {
        yield 'scenario description' => [$input, $expected];
    }
}
```

## Integration Test Template

```php
<?php

declare(strict_types=1);

namespace App\Tests\Integration\{Domain};

use Symfony\Bundle\FrameworkBundle\Test\KernelTestCase;
use Doctrine\ORM\EntityManagerInterface;

final class {Name}Test extends KernelTestCase
{
    private EntityManagerInterface $em;

    protected function setUp(): void
    {
        self::bootKernel();
        $this->em = self::getContainer()->get(EntityManagerInterface::class);
    }

    protected function tearDown(): void
    {
        parent::tearDown();
        $this->em->close();
    }
}
```

## Functional Test Template

```php
<?php

declare(strict_types=1);

namespace App\Tests\Functional\{Domain};

use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;

final class {Name}Test extends WebTestCase
{
    public function test_{route}_returns_{expected_status}(): void
    {
        $client = static::createClient();
        $client->request('GET', '/{route}');

        $this->assertResponseStatusCodeSame(200);
        $this->assertSelectorExists('h1');
    }
}
```

## PHPUnit Attributes (PHPUnit 12)

Use PHP Attributes — never docblock annotations:

```php
use PHPUnit\Framework\Attributes\CoversClass;
use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\Attributes\Test;

#[CoversClass(InvoiceCalculator::class)]
final class InvoiceCalculatorTest extends TestCase
{
    #[Test]
    public function it_applies_discount_for_premium_users(): void
    {
        // Arrange
        $calculator = new InvoiceCalculator();

        // Act
        $total = $calculator->calculate(amount: 100.0, isPremium: true);

        // Assert
        $this->assertSame(expected: 90.0, actual: $total);
    }

    #[DataProvider('provideDiscountScenarios')]
    #[Test]
    public function it_calculates_correct_discount(float $amount, bool $isPremium, float $expected): void
    {
        $this->assertSame($expected, (new InvoiceCalculator())->calculate($amount, $isPremium));
    }

    /** @return iterable<string, array{float, bool, float}> */
    public static function provideDiscountScenarios(): iterable
    {
        yield 'standard user — no discount' => [100.0, false, 100.0];
        yield 'premium user — 10% off'      => [100.0, true, 90.0];
        yield 'zero amount'                 => [0.0, true, 0.0];
    }
}
```

- Use `#[Test]`, `#[DataProvider]`, `#[CoversClass]`, `#[BeforeClass]`, `#[AfterClass]` — never docblock annotations.
- Never use `@covers` docblock annotations — use `#[CoversClass(MyClass::class)]` PHP attribute instead.
- One assertion per test when possible — multiple assertions are acceptable if they collectively prove one logical fact.
- Do **not** assert on implementation details (private method calls, exact SQL) — assert on observable outcomes (return values, side effects, HTTP responses).

## Smoke Tests (Required)

Every public URL must have a smoke test to catch 500 errors early:

```php
#[DataProvider('providePublicUrls')]
public function test_page_returns_successful_response(string $url): void
{
    $client = static::createClient();
    $client->request('GET', $url);

    $this->assertResponseIsSuccessful();
}

/** @return iterable<string, array{string}> */
public static function providePublicUrls(): iterable
{
    yield 'homepage'   => ['/'];
    yield 'post list'  => ['/post'];
    yield 'about page' => ['/about'];
}
```

## URL Hard-Coding in Functional Tests

Use **hardcoded URLs** — never call the router — so that route changes cause test failures, surfacing the need to set up redirects:

```php
// Correct — hardcoded URL
$client->request('GET', '/post/123');

// Wrong — hides route renames
$client->request('GET', $this->generateUrl('post_show', ['id' => 123]));
```

## Fixtures

- Fixtures live in `app/src/DataFixtures/` — mirror the domain namespace (`DataFixtures/{Domain}/`).
- Use `DependentFixtureInterface` to declare load order — never hard-code fixture dependencies by class name string.
- Load via `DoctrineFixturesBundle` with `--group` flags in test `setUp()` — not manual `persist()`/`flush()`.

## What Not to Mock

- **Database** — always hit real PostgreSQL.
- **Redis** — always hit real Redis in integration tests.
- **Symfony services** — prefer the real DI container; mock only external HTTP clients.
- **External HTTP clients** — mock via `symfony/http-client`'s `MockHttpClient` + `MockResponse` for provider API calls in integration tests.

@see https://symfony.com/doc/current/best_practices.html#tests

## Test Environment Configuration

- Use `.env.test` or `config/packages/test/` for test-specific settings.
- Use a dedicated test database (separate from dev).
- Run with `debug: false` on CI to improve performance.

```yaml
# config/packages/twig.yaml
when@test:
    twig:
        strict_variables: true  # immediately error on undefined variables
```

## Mocking Services in Tests

Retrieve services from the container in `KernelTestCase`, and replace them with mocks when needed:

```php
// Retrieve a real service in an integration test
self::bootKernel();
$service = static::getContainer()->get(MyService::class);

// Replace with a mock
$mock = $this->createMock(MailerInterface::class);
static::getContainer()->set(MailerInterface::class, $mock);
```

@see https://symfony.com/doc/current/testing.html#mocking-dependencies

## Functional Test Pattern

```php
final class PostControllerTest extends WebTestCase
{
    public function test_create_post_redirects_on_success(): void
    {
        $client = static::createClient();

        // Simulate an authenticated user
        $client->loginUser($user);

        // Submit the form
        $client->request('GET', '/post/new');
        $client->submitForm('Save', [
            'post[title]' => 'My Test Post',
        ]);

        // Assert PRG pattern
        $this->assertResponseRedirects('/post/');
        $client->followRedirect();
        $this->assertSelectorTextContains('h1', 'My Test Post');
    }
}
```
