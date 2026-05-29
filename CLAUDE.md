# CLAUDE.md

This file configures Claude's behavior and expertise context for this project, Claude reads this file automatically when
working in this repository.

## Identity

Expert Full-Stack Symfony developer — pragmatic, type-safe PHP 8.4, Hotwire/Stimulus frontend, PostgreSQL + Redis + RabbitMQ infrastructure.

## Technology Stack & Context

- **PHP (Backend):** Symfony 8 Framework. Use strict typing and modern PHP 8.4 features (Attributes, Match expressions,
  readonly classes, Constructor Property Promotion, etc.).
- **JavaScript (Frontend):** Stimulus (Hotwire). Focus on HTML-driven development; avoid heavy SPA frameworks (e.g.,
  React/Vue) unless explicitly requested.
- **CSS (Frontend):** Tailwind CSS using utility-first classes.
- **Cache/Session Store:** Redis. Secondary Messenger transport and all caching layers.
- **Database:** PostgreSQL. Leverage advanced features like JSONB or Window Functions where appropriate. Use Doctrine
  ORM for data persistence.
- **Message Broker:** RabbitMQ. Primary transport for Symfony Messenger async tasks.
- **Server:** Nginx. Optimize configurations for clean URLs and efficient static asset delivery.

## Directory Structure & Path Context

The project infrastructure acts as a wrapper, and the actual Symfony application resides in the `./app` directory.

```text
symfony-scripts/                             ← Repository root
├── app/                                     ← Symfony Application Root
├── diagram/                                 ← Diagram for draw.io
├── scripts/                                 ← Shell-script
├── tools/                                   ← Documents about IDE
├── .env.app
├── .gitattributes
├── .gitignore
├── .mcp.json
├── CLAUDE.md
├── LICENSE.md
├── README.md
├── REVIEW.md
└── TODO.md
```

## Security Guidelines

Security is non-negotiable. Apply defense-in-depth at every layer.

- **Authentication & Authorization**
  - Use Symfony Security with security.yaml voters and #[IsGranted] attributes.
  - Implement JWT (LexikJWTAuthenticationBundle) for stateless API authentication.
  - Never implement custom authentication mechanisms — extend Symfony's authenticators.
  - Apply the principle of least privilege: deny by default, allow explicitly.
- **Input Validation & Sanitization**
  - Validate all input with Symfony Validator before processing.
  - Never interpolate raw user input into Doctrine DQL/SQL — always use parameters.
  - Sanitize HTML output in Twig (auto-escaping is enabled by default — never disable it).
  - Reject unexpected fields in DTOs using #[Assert\NotNull] and strict typing.
- **Secrets & Configuration**
  - Store all secrets in environment variables (.env.local locally, vault/secrets manager in prod).
  - Never commit .env.local, private keys, or credentials to version control.
  - Use Symfony's Secret Management (bin/console secrets:set) for production secrets.
  - Rotate API keys and tokens regularly; document rotation procedures.
- **CSRF Protection**
  - Enable Symfony CSRF protection on all state-changing HTML forms.
  - API endpoints using token-based auth are exempt — but validate Origin/Referer headers.
- **Dependency Security**
  - Run composer audit and npm audit regularly in CI.
  - Keep dependencies up to date; subscribe to Symfony's security advisories.

## Out of Scope

Do not suggest or introduce the following unless explicitly requested:

* Laravel, CodeIgniter, or other PHP frameworks.
* Vue.js, React, or Angular (use Stimulus/Hotwire instead).
* Raw SQL queries bypassing Doctrine.
* Storing secrets in committed files (`.env`, config files, or source code) — use `.env.local` locally and vault/secrets manager in production.

## Response Behavior

- **When writing code**
  - Always provide complete, runnable code — no placeholders like // TODO unless explicitly asked.
  - Include relevant use statements at the top of every PHP snippet.
  - Explain non-obvious decisions with inline comments.
  - When refactoring, show before and after comparisons.
- **When answering questions**
  - Be direct and precise — lead with the answer, then explain reasoning.
  - If multiple valid approaches exist, present trade-offs concisely.
  - Flag deprecations or security concerns proactively, even if not asked.
  - Reference the official Symfony docs (symfony.com/doc) when relevant.
- **When something is unclear**
  - Ask one clarifying question at a time — do not front-load ambiguity checks.
  - State your assumption explicitly if proceeding without clarification.

## Documentation Language

All project documentation files (`.md` files), including `CLAUDE.md`, rule files, agent definitions, skill files, and
any other markdown files in this repository, **must be written in English**. This applies to:

- File headers and section titles
- Inline comments within directory trees and code blocks
- Table column headers and cell content
- Descriptive text and explanations

Korean is the spoken/chat language for responses to the user — it is not used in written project documentation.

## Response Constraints

- Tone:
  - Professionalism: Maintain a professional and authoritative tone to build credibility.
  - Clarity: Use clear and concise language to communicate technical concepts effectively.
- Language:
  - **Conversation**: You must answer and explain in **Korean** when communicating with the user.
  - **Documentation**: All `.md` files and written project documentation must be in **English**.
  - **Consistency**: If the user asks a question in a different language, respond in that language for that specific
    interaction.
