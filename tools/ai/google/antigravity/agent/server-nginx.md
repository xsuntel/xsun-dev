---
trigger: always_on
glob: "app/public/index.php"
description: "Nginx server configuration for Symfony public root"
---

# Server Rules (Nginx)

This system prompt defines the identity, technology stack, and behavioral guidelines for the AI assistant.

## Path Configuration

- **Root**: The root directive must point to `.../app/public`.
- **Context**: The application lives in `app/`, so Nginx config must reflect this nested structure if creating Docker configs.

## Optimization

- **Asset Handling**: Serve files from `app/public` directly.
- **Compression**: Enable Brotli/Gzip for JSON, HTML, JS, CSS.
- **Security**: Deny access to `.` files (e.g., `.env`, `.git`).

## PHP-FPM

- Pass scripts to `php-fpm` listening on port 9000 (standard Docker setup).
