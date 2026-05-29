# Security Guidelines

Security is non-negotiable. Apply defense-in-depth at every layer.

## Authentication & Authorization
- Use Symfony Security with security.yaml voters and #[IsGranted] attributes.
- Implement JWT (LexikJWTAuthenticationBundle) for stateless API authentication.
- Apply the principle of least privilege.

## Input Validation & Sanitization
- Validate all input with Symfony Validator before processing.
- Never interpolate raw user input into Doctrine DQL/SQL.
- Sanitize HTML output in Twig.

## Secrets & Configuration
- Store all secrets in environment variables.
- Never commit .env.local, private keys, or credentials to version control.
