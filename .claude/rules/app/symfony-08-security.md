---
paths:
  - "app/src/**/*.php"
---

# Security Rules

@see https://symfony.com/doc/current/security.html

## Firewall Configuration

- Maintain a **single `main` firewall** unless a separate authentication scheme is strictly required.
- Concentrate all security logic in one firewall — avoid splitting into `api` + `main` unless the auth mechanisms differ.

## Password Hashing

- Always use the `auto` hasher — it selects the best algorithm for the current PHP version.
- Never specify a concrete algorithm (`bcrypt`, `argon2id`) — let Symfony choose.

```yaml
# config/packages/security.yaml
security:
  password_hashers:
    App\Entity\Abstract\Users\User:
      algorithm: auto
```

## Authorization (Access Control)

- Implement complex permission logic in **Voter classes** — not in `#[Security]` expressions or `isGranted()` calls with long strings.
- Use `#[IsGranted]` on controller actions for simple role checks.
- Reserve `#[Security("...")]` for simple attribute expressions only — long expressions are a code smell.

```php
// Correct — delegate to Voter
#[IsGranted('POST_EDIT', subject: 'post')]
#[Route('/post/{id}/edit', name: 'post_edit', methods: ['GET', 'POST'])]
public function edit(Post $post): Response { ... }
```

```php
// PostVoter.php
final class PostVoter extends Voter
{
    protected function supports(string $attribute, mixed $subject): bool
    {
        return in_array($attribute, ['POST_EDIT', 'POST_DELETE'], true)
            && $subject instanceof Post;
    }

    protected function voteOnAttribute(string $attribute, mixed $subject, TokenInterface $token): bool
    {
        $user = $token->getUser();
        if (!$user instanceof User) {
            return false;
        }

        return match ($attribute) {
            'POST_EDIT'   => $subject->isOwnedBy($user),
            'POST_DELETE' => $subject->isOwnedBy($user) || $this->isGranted('ROLE_ADMIN'),
            default       => false,
        };
    }
}
```

## Access Control Priority

Apply access control in this order of preference:

1. `access_control` (config) — URL-pattern-based global rules.
2. `#[IsGranted('ROLE_ADMIN')]` — controller Attribute (preferred for most cases).
3. `$this->denyAccessUnlessGranted()` — inside conditional logic.
4. `{% if is_granted('ROLE_ADMIN') %}` — Twig templates for UI-only visibility.

```php
use Symfony\Component\Security\Http\Attribute\IsGranted;

#[IsGranted('ROLE_ADMIN')]
class AdminController extends AbstractController {}

// With Voter
#[IsGranted('POST_EDIT', subject: 'post')]
public function edit(Post $post): Response {}
```

@see https://symfony.com/doc/current/security.html#access-control-authorization

## Role Hierarchy

Use role hierarchy instead of simple string comparisons for permission management. Configure `ROLE_ADMIN` to automatically include `ROLE_USER`.

```yaml
# config/packages/security.yaml
security:
  role_hierarchy:
    ROLE_MODERATOR: ROLE_USER
    ROLE_ADMIN: [ROLE_MODERATOR, ROLE_USER]
    ROLE_SUPER_ADMIN: ROLE_ADMIN
```

@see https://symfony.com/doc/current/security.html#roles

## User Provider

Use the Doctrine entity-based provider. Specify the login identifier field via the `property` option. The `User` class must implement `UserInterface` (generate with `make:user`).

```yaml
security:
  providers:
    app_user_provider:
      entity:
        class: App\Entity\Abstract\Users\User
        property: email
```

@see https://symfony.com/doc/current/security.html#the-user

## CSRF Protection

- All state-mutating HTML form submissions must include `csrf_token()` in the template.
- Controller actions handling those forms must use `#[IsCsrfTokenValid('intention', '_token')]`.
- HTML form submissions: rely on Symfony Form's built-in CSRF protection (enabled by default).
- Custom POST actions without a Form: use `#[IsCsrfTokenValid('intention', '_token')]` on the action.
- AJAX requests: generate a token with `csrf_token('intention')` in Twig, send it in a custom header, validate in the controller.
- JWT-authenticated API endpoints are **exempt** from CSRF (cookie-based sessions are not used).

## Rate Limiting

Apply `symfony/rate-limiter` to all login, registration, password reset, and public POST endpoints.
Respond with HTTP 429 and a `Retry-After` header on limit exhaustion.

```php
#[RateLimiter('login')]
#[Route('/login', name: 'app_login', methods: ['POST'])]
public function login(): Response { ... }
```

## Input Handling

- **Never** access `$_POST`, `$_GET`, `$_REQUEST`, or `$request->get()` directly in Controllers.
- All user input must flow through Symfony Form types or DTO + Validator constraints.
- Validate at the boundary — before any Service or Repository is called.

## XSS

- Twig auto-escaping is always enabled — never disable it.
- **Never** use `{{ variable|raw }}` on any value that originates from user input or the database.
- Markdown rendering: use `league/commonmark` with HTML sanitization enabled.

## SQL Injection

- DQL + QueryBuilder parameter binding is safe — always use `:param` binding.
- Native SQL: use `$conn->executeQuery($sql, $params)` — **never** string interpolation.
- No raw SQL in Entities, Services, or Controllers — only in Repositories.

## JWT

- JWT signing and verification logic lives exclusively in a dedicated Service class.
- Never log JWT token values — log only the user identifier extracted from the token.
- Token expiry must be enforced — reject expired tokens at the EventSubscriber level.
- Refresh tokens must be rotated on each use.

## OAuth2 / Social Login

- State parameter validation is mandatory — the `knpuniversity/oauth2-client-bundle` handles this, do not bypass it.
- Never store OAuth access tokens in cookies — store in server-side session (Redis-backed).

## Sensitive Data

- Never log passwords, tokens, API keys, or PII.
- API keys for external providers (example, example) stored in encrypted JSONB columns or environment variables — never in plaintext entity columns.
- Use `#[Sensitive]` Attribute on DTO properties containing passwords or tokens (Symfony 6.2+).

## Security Headers

- Configured at Nginx level for production.
- In development, verify via `symfony/web-profiler-bundle` Security panel.

@see https://symfony.com/doc/current/security/voters.html
@see https://symfony.com/doc/current/security/csrf.html
@see https://symfony.com/doc/current/rate_limiter.html
