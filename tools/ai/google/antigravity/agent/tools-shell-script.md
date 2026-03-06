---
trigger: always_on
glob: "scripts/**/*.sh, tools/**/*.sh"
description: "Shell scripts, Symfony Console commands, and Composer tasks"
---

# Shell Script & Console Rules

This system prompt defines the identity, technology stack, and behavioral guidelines for the AI assistant.

## Working Directory

- **Critical**: Most Symfony commands must be run from the `app/` directory where `composer.json` and `bin/console` reside.
- Example: `cd app && php bin/console cache:clear`

## Script Locations

- **Console**: Custom shell scripts are in `console/`.
- **Scripts**: Maintenance/Docker scripts are in `scripts/`.

## Common Tasks

- **AssetMapper**: `php bin/console importmap:install` (Do not use `yarn`/`npm` install).
- **Messenger**: `php bin/console messenger:consume async -vv`.
- **Scheduler**: `php bin/console debug:scheduler`.

## Permissions

- Ensure `app/var` is writable.
