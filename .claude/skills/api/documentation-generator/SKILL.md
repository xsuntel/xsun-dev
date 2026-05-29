---
name: api-documentation-generator
description: Use when auto-generating API endpoint documentation, writing OpenAPI specs, or producing request/response examples for external provider integrations
---

# API Documentation Generation

## Accuracy Principles

For any information that cannot be verified from the current codebase or official documentation, use hedged language:

- "This configuration value requires verification against the official documentation."
- "Behaviour may differ across versions — consult the release notes."
- "This behaviour may vary depending on the environment."

Never assert version numbers, default values, or error codes that have not been confirmed from the source.

## Prohibited Practices

- Do not state unverified API version information as fact.
- Do not present untested configuration values as defaults.
- Do not fabricate error codes or response schemas based on guesswork.
- Do not document endpoints that do not exist in the current codebase or official provider docs.

## Endpoint Discovery

Before writing any documentation, locate the actual implementation:

1. Find the `MessageCommandHandler` that calls the endpoint via `HttpClientInterface`.
2. Identify the scoped HTTP client in `config/packages/framework.yaml` (`framework.http_client.scoped_clients`).
3. Read the provider DTO used to deserialize the response.
4. Read the matching `Entity` to understand which fields are persisted.
