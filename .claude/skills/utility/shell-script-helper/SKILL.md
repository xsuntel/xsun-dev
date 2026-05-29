---
name: shell-script-helper
description: Use this skill whenever the user writes, reviews, debugs,
  or refactors Bash shell scripts on Ubuntu/Linux. Triggers include
  mentions of '.sh files', 'shell script', 'bash', 'shebang', POSIX
  compatibility, ShellCheck, cron jobs, systemd timers, or any task
  involving command-line automation. Also use when fixing common bash
  pitfalls like quoting issues, exit code handling, IFS, variable
  expansion, or word splitting — even if the user doesn't explicitly
  say 'bash'.
---

# Shell Script Helper

Guide for writing and reviewing Bash scripts in this Symfony/Docker project.
All conventions below reflect actual patterns found in `scripts/` — do not
apply generic best-practice overrides where they conflict with project norms.

---

## 1. Core Conventions

### Shebang
Always `#!/bin/bash`. Do **not** use `#!/usr/bin/env bash`.

### Strict Mode
`set -euo pipefail` is intentionally **commented out** in every script:

```bash
#!/bin/bash

#set -euo pipefail
```

This is by design. Scripts run interactive menus and multi-step installs where
partial failure must be tolerated. Use the project's own error-exit functions
(`setExit`, `setEnd`) instead of relying on shell strict mode.

### ShellCheck Config (`scripts/.shellcheckrc`)
The following rules are disabled project-wide — do not flag them in reviews:

| Rule | Reason |
|------|--------|
| SC2034 | Unused vars — variables are consumed by sourced scripts |
| SC2168 | `local` outside function — sourced files are always called from within a function |
| SC1091 | Cannot follow dynamic `source` paths |
| SC2155 | Declare and assign separately — intentionally combined |
| SC2225 | Arithmetic comparison style |
| SC2024 | `sudo tee` redirect pattern |

`external-sources=true` and `source-path=SCRIPTDIR` are also set.

### Variable Quoting
Always double-quote variable expansions: `"${VAR}"` not `$VAR` or `"$VAR"`.
Use the long brace form: `"${PLATFORM_TYPE}"` not `"$PLATFORM_TYPE"`.

### Local Variables
Any variable used only within a function must be declared `local` on a separate
line before assignment (SC2155 is suppressed, but the two-line form is still
preferred for clarity):

```bash
local MY_VAR
MY_VAR=$(some_command)
```

---

## 2. Script Bootstrap Pattern

Every top-level entry-point script (i.e. files that are directly executed, not
sourced) must follow this bootstrap sequence:

```bash
#!/bin/bash

#set -euo pipefail
# ======================================================================================================================
# Scripts - <Category> - <Description>
# ======================================================================================================================

find_project_root() {
    local PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    while [[ "${PROJECT_DIR}" != "/" ]]; do
        if [[ -d "${PROJECT_DIR}/.git" ]] || [[ -f "${PROJECT_DIR}/.env.app" ]]; then
            echo "${PROJECT_DIR}"
            return 0
        fi
        PROJECT_DIR="$(dirname "${PROJECT_DIR}")"
    done
    return 1
}

PROJECT_PATH=$(find_project_root)
PROJECT_NAME=$(basename "$(realpath "${PROJECT_PATH}")")
cd "${PROJECT_PATH}" || exit

if [ -f "${PROJECT_PATH}/scripts/base/_abstract.sh" ]; then
  source "${PROJECT_PATH}/scripts/base/_abstract.sh"
else
  echo "Please check a file : ./scripts/base/_abstract.sh" && exit
fi
```

Sourced helper files (`_*.sh`) do **not** repeat this bootstrap — they inherit
`PROJECT_PATH`, `PLATFORM_TYPE`, etc. from the calling script.

### Sourcing Guard Pattern
Always guard every `source` call with a file-existence check:

```bash
if [ -f "${PROJECT_PATH}/scripts/base/_platform.sh" ]; then
  source "${PROJECT_PATH}/scripts/base/_platform.sh"
else
  echo "Please check a file : ./scripts/base/_platform.sh" && exit
fi
```

---

## 3. Global Variables

Declared in `scripts/base/_abstract.sh` and available to all scripts after
sourcing it. Never redeclare these as local. `setEnd()` unsets all of them on
clean exit.

**Platform**
- `PLATFORM_TYPE` — `Linux` | `Darwin` | `Windows` (from `uname -s`)
- `PLATFORM_PROCESSOR` — `x86_64` | `arm64` (from `uname -m`)

**Environment**
- `ENVIRONMENT_NAME` — `dev` | `prod`

**Project**
- `PROJECT_PATH`, `PROJECT_NAME`

**App**
- `PHP_VERSION`, `NODE_VERSION`, `SYMFONY_VERSION`

**Infrastructure**
- `REDIS_*`, `POSTGRES_*`, `RABBITMQ_*`, `NGINX_*`

**Docker**
- `DOCKER_ENVIRONMENT`, `DOCKER_WORKDIR`
- `DOCKERFILE_IMAGE_NAME`, `DOCKERFILE_TAG_NAME`

**Cloud**
- `GCLOUD_PROJECT_ID`, `GCLOUD_ARTIFACTS_DOCKER_*`

---

## 4. Function Naming Conventions

All functions use `set<PascalCase>` naming. Every top-level deploy script
defines and calls functions in this order:

| Function | Purpose |
|----------|---------|
| `setStart()` | Print start banner with timestamp |
| `setEnvironment()` | Interactive environment menu (sets `ENVIRONMENT_NAME`) |
| `setPlatform()` | OS detection and platform-specific setup |
| `setProject()` | Source `.env.app`, initialize project directories |
| `set<Component>()` | Install/configure a component (e.g. `setPhp`, `setRedis`, `setNginx`) |
| `setBuild()` | Run Symfony deployment steps (composer, cache clear, etc.) |
| `setDocker()` | Build and run Docker containers |
| `setProvider()` | Cloud provider configuration (GCP, etc.) |
| `setUtility()` | Miscellaneous tooling (local server, git, etc.) |
| `setTools()` | VM/instance diagnostics and cleanup |
| `setEnd()` | Unset all globals, print end banner, `exit 0` |
| `setExit()` | Immediate `kill -SIGKILL $$` exit on unrecoverable error |
| `find_project_root()` | Walk up directory tree to find `.git` or `.env.app` |

Component-specific helpers follow the same prefix: `setPhp`, `setRedis`,
`setPostgreSQL`, `setRabbitMQ`, `setNginx`, `setSupervisor`, `setDocker`.

---

## 5. Output Formatting

### Section Banners (comment separators in source)
```bash
# ======================================================================================================================
# Section Title (120 = chars)
# ======================================================================================================================

# ----------------------------------------------------------------------------------------------------------------------
# Subsection Title (120 - chars)
# ----------------------------------------------------------------------------------------------------------------------
```

### Runtime Output Banners (echo separators)
```bash
echo "==============================================================================================================="
echo ">>>>  START                                                                  $(date)"
echo "==============================================================================================================="
```
- `=` line: 111 characters
- `-` line: 111 characters

### Section Headers in Functions
```bash
echo "---------------------------------------------------------------------------------------------------------------"
echo "[ ${ENVIRONMENT_NAME} ] ${PLATFORM_TYPE} - Component - Action"
echo "---------------------------------------------------------------------------------------------------------------"
```

### Step Labels
```bash
echo ">>>> PHP - Symfony Framework - Deployment - A) Check Requirements"
echo
```

Always follow a step label with a blank `echo` line. Always print a blank
`echo` line after a command block completes.

---

## 6. Interactive Menus

Use `select` with `PS3` — never `getopts` or positional arguments for
environment selection.

```bash
setEnvironment() {
  echo "---------------------------------------------------------------------------------------------------------------"
  echo "[ ENV ] ${PLATFORM_TYPE} - ${PLATFORM_PROCESSOR}"
  echo "---------------------------------------------------------------------------------------------------------------"
  PS3="Menu: "
  select num in "dev" "prod" "exit"; do
    case "$REPLY" in
    1)
      ENVIRONMENT_NAME="dev"
      break
      ;;
    2)
      ENVIRONMENT_NAME="prod"
      break
      ;;
    3)
      echo "exit()"
      setEnd
      ;;
    *)
      echo "[ ERROR ] Unknown Command"
      setEnd
      ;;
    esac
  done
  echo
}
```

Use `$REPLY` (the numeric input), not `$num` (the text label), in the `case`
statement.

---

## 7. Platform-Specific Code

All platform branches must handle all three OS types. Always call `setExit` in
the `else` branch — never silently fall through.

```bash
if [ "${PLATFORM_TYPE}" == "Linux" ]; then
  # apt, systemctl, dpkg
elif [ "${PLATFORM_TYPE}" == "Darwin" ]; then
  # brew, pecl
elif [ "${PLATFORM_TYPE}" == "Windows" ]; then
  # PowerShell, scoop (Git Bash context)
else
  echo "Please check Operating System"
  setExit
fi
```

Use `[ == ]` (double-equals inside single brackets) consistently — the codebase
does not use `[[ ]]` for string comparisons in platform blocks.

---

## 8. Package Installation (Idempotency Pattern)

Never install a package unconditionally. Always check first using `dpkg -l`:

```bash
local APT_PKG_INFO
APT_PKG_INFO=$(dpkg -l | grep -i "${pkgItem}" | awk '{print $2}' | cut -d ':' -f1 | awk "/^${pkgItem}$/")
if [ "${APT_PKG_INFO}" != "${pkgItem}" ]; then
  sudo apt install -y "${pkgItem}"
  echo
fi
```

Iterate package lists with a `for` loop:

```bash
local addPackageList="curl git wget unzip"
for pkgItem in ${addPackageList}; do
  local APT_PKG_INFO
  APT_PKG_INFO=$(dpkg -l | grep -i "${pkgItem}" | awk '{print $2}' | cut -d ':' -f1 | awk "/^${pkgItem}$/")
  if [ "${APT_PKG_INFO}" != "${pkgItem}" ]; then
    sudo apt install -y "${pkgItem}"
    echo
  fi
done
```

For removal, flip the condition: `if [ "${APT_PKG_INFO}" == "${pkgItem}" ]; then sudo apt remove -y ...`.

For macOS, use `brew list | grep <pkg>` as the check guard.

---

## 9. Script Categories

| Category | Path | Purpose |
|----------|------|---------|
| Base | `scripts/base/` | Environment-independent install and config; sourced by both containers and deploy scripts |
| Containers (dev) | `scripts/containers/dev/` | `docker-compose` definitions for local Redis, PostgreSQL, RabbitMQ |
| Containers (prod) | `scripts/containers/prod/` | Production `Dockerfile`, `entrypoint.sh`, Nginx/Supervisor config |
| Deploy (dev) | `scripts/deploy/dev/` | OS-specific initial machine setup (packages, network, security) |
| Deploy (prod) | `scripts/deploy/prod/` | Production server deployment |

**Shared foundation:** `scripts/base/_abstract.sh` → `_environment.sh` →
`_platform.sh` → `_project.sh`. Source `_abstract.sh` first; the others are
sourced in sequence inside the appropriate `set*()` functions.

**Entrypoint exception:** `scripts/containers/prod/utility/entrypoint.sh` uses
`#!/bin/sh` with `set -e` (not bash) because it runs inside a minimal Docker
image. Do not apply bash-specific patterns there.

---

## 10. Review Checklist

When reviewing a script in this project, verify:

- [ ] Shebang is `#!/bin/bash` (not `#!/usr/bin/env bash`)
- [ ] `#set -euo pipefail` is commented out (not active)
- [ ] Script bootstraps with `find_project_root` and sources `_abstract.sh`
- [ ] Every `source` call is wrapped in a file-existence guard
- [ ] All global variables match the names defined in `_abstract.sh`
- [ ] Local variables use the two-line `local` / assign pattern
- [ ] All variable expansions are quoted as `"${VAR}"`
- [ ] Interactive menus use `select` + `PS3="Menu: "` + `$REPLY`
- [ ] Platform blocks cover Linux, Darwin, Windows, and `else` + `setExit`
- [ ] Package installs use the `dpkg -l` idempotency check
- [ ] Output separators are 111 characters wide
- [ ] Functions follow `set<Component>()` naming
- [ ] `setEnd` is called at the bottom of every entry-point script
- [ ] `setExit` is called (not `exit 1`) on unrecoverable errors

---

## 11. Anti-Patterns to Flag

| Anti-Pattern | Preferred Approach |
|---|---|
| Hardcoded user paths (`/Users/rlim/...`, `/home/rlim/...`) | Use `${PROJECT_PATH}`, `${HOME}`, or `${USER}` |
| Sourcing `.env.app` without existence check | Guard with `if [ -f ... ]` first |
| `sleep N` for timing assumptions | Use `systemctl is-active`, polling loops, or proper wait conditions |
| Repeating the same `dpkg -l` check block inline | Extract into a shared helper or use the `for pkgItem in ...` loop pattern |
| `exit 1` inside a sourced file | Use `setExit` (SIGKILL) or `setEnd` (graceful) instead |
| `#!/usr/bin/env bash` shebang | Replace with `#!/bin/bash` |
| Active `set -euo pipefail` | Comment it out; use explicit error handling |
| `getopts` for environment selection | Use `select` + `PS3` menus |
| Unquoted `$VAR` expansions | Always use `"${VAR}"` |
