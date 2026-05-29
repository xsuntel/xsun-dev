---
name: Shell Scripts Style
description: 쉘 스크립트 작성 및 리뷰에 특화된 스타일. 안전성·이식성·가독성을 우선시한다.
keep-coding-instructions: true
---

# Shell Scripts Output Style

이 스타일은 `scripts/` 디렉터리의 Bash 스크립트를 작성하거나 검토할 때 적용된다.
코드의 **안전성(safety)**, **이식성(portability)**, **가독성(readability)** 을 항상 최우선 기준으로 삼는다.

---

## Response Format

- 코드 블록은 반드시 언어 식별자를 명시한다: ` ```bash ` 또는 ` ```sh `
- 스크립트 전체를 제공할 때는 파일 상단에 shebang과 설명 주석을 포함한다
- 스크립트 수정 시에는 변경 전/후를 명확히 구분하여 표시한다
- 위험하거나 주의가 필요한 명령은 코드 블록 아래에 `> ⚠️ 주의:` 형식으로 경고를 표시한다

---

## Coding Rules

### Shebang

| Script type | Shebang |
|-------------|---------|
| General project scripts (`deploy.sh`, `cache.sh`, …) | `#!/bin/bash` |
| Container entrypoint (`entrypoint.sh`) | `#!/bin/sh` |
| Portability-critical scripts (POSIX only) | `#!/bin/sh` |

**Do not** use `#!/usr/bin/env bash` — all target environments have a fixed Bash path.

### Header Format

All scripts follow this header structure:

```bash
#!/bin/bash

#set -euo pipefail
# ======================================================================================================================
# Scripts - {Category} - {Sub-Category} - {Description}
# ======================================================================================================================
```

The `set -euo pipefail` line is **intentionally commented out** in all project scripts.

> ⚠️ **Why `set -euo pipefail` is disabled**: This project uses a `source`-based modular architecture
> where sub-scripts are sourced rather than executed in subshells. Enabling `set -u` causes false
> positives for variables declared by other sourced scripts that load later. Interactive `select`
> menus also break under `set -e`. Keep the commented line as a visible reminder that the decision
> is intentional, not forgotten.

For standalone utility scripts that do **not** source other scripts and do **not** use interactive
menus, `set -euo pipefail` **may** be enabled:

```bash
#!/bin/bash
# ======================================================================================================================
# Scripts - Utility - {Description}
# ======================================================================================================================
set -euo pipefail
IFS=$'\n\t'
```

### Section Separators

Use three separator widths — 118 characters is the standard line length for this project:

```bash
# ======================================================================================================================
# Major section (top-level script division)
# ======================================================================================================================

# ----------------------------------------------------------------------------------------------------------------------
# Sub-section (component block inside a function)
# ----------------------------------------------------------------------------------------------------------------------

# >>>> Category - Item (inline label for a group of commands)
```

### Variable Rules

```bash
# Global constants — UPPER_CASE + underscore
PLATFORM_TYPE=$(uname -s)
PLATFORM_PROCESSOR=$(uname -m)
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Local variables inside functions — UPPER_CASE + underscore (project convention)
# Note: use 'local' to scope; always quote when expanding
local SUPERVISOR_STATUS
SUPERVISOR_STATUS=$(systemctl is-active supervisord)

# Always quote variable expansions
echo "${SUPERVISOR_STATUS}"
cp "${source_file}" "${dest_dir}/"

# Safe rm -rf: use :? to guard against empty variable
rm -rf "${BUILD_DIR:?BUILD_DIR is not set}"
```

### Function Naming Conventions

This project uses **two distinct naming conventions** for functions — apply the correct one by context:

| Convention | Usage | Examples |
|------------|-------|---------|
| `camelCase` | Lifecycle phase functions that orchestrate a deploy stage | `setStart`, `setEnd`, `setExit`, `setEnvironment`, `setPlatform`, `setProject`, `setPhp`, `setRedis`, `setNginx`, `setBuild`, `setDocker`, `setUtility`, `setTools` |
| `snake_case` | Utility / helper functions for reusable logic | `find_project_root`, `log_info`, `log_error`, `cleanup` |

```bash
# Lifecycle phase function (camelCase)
setPhp() {
  echo "---------------------------------------------------------------------------------------------------------------"
  echo "[ ${ENVIRONMENT_NAME} ] ${PLATFORM_TYPE} - App - PHP"
  echo "---------------------------------------------------------------------------------------------------------------"
  echo

  if [ -f "${PROJECT_PATH}/scripts/base/app/php/base/_install.sh" ]; then
    source "${PROJECT_PATH}/scripts/base/app/php/base/_install.sh"
  else
    echo "Please check a file : ./scripts/base/app/php/base/_install.sh" && exit
  fi
}

# Utility helper function (snake_case)
log_error() {
  local message="$1"
  echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') — ${message}" >&2
}
```

### Lifecycle Structure

All top-level scripts (`deploy.sh`, `cache.sh`, `status.sh`, …) follow this fixed lifecycle order:

```bash
# ======================================================================================================================
# START
# ======================================================================================================================

setStart          # Print start banner with timestamp

# Abstract
setEnvironment    # Select dev/prod via interactive menu
setPlatform       # Detect and configure OS-specific settings
setProject        # Source .env.app and prepare project directories

# Architecture (enable the components this script needs)
setPhp
#setRedis
#setPostgreSQL
#setRabbitMQ
#setNginx

# Build
setBuild

# Docker
setDocker

# Providers
#setProvider

# Utility
setUtility

# Tools
setTools

# ======================================================================================================================
# END
# ======================================================================================================================

setEnd            # Unset all exported variables and print end banner
```

Comment out phase functions that are not needed for a given script — this is the standard way to
opt out of a stage, not to delete the call.

### Project Root Detection

Every top-level script must locate the repository root before sourcing `_abstract.sh`. Use this
canonical function:

```bash
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
```

### Abstract Script Sourcing

Source `_abstract.sh` **immediately** after detecting the project root — it defines `setStart`,
`setEnd`, `setExit`, `PLATFORM_TYPE`, and `PLATFORM_PROCESSOR`:

```bash
if [ -f "${PROJECT_PATH}/scripts/base/_abstract.sh" ]; then
  source "${PROJECT_PATH}/scripts/base/_abstract.sh"
else
  echo "Please check a file : ./scripts/base/_abstract.sh" && exit
fi
```

Apply the same guard pattern for **every** sourced script — never use bare `source`:

```bash
if [ -f "${PROJECT_PATH}/scripts/base/_platform.sh" ]; then
  source "${PROJECT_PATH}/scripts/base/_platform.sh"
else
  echo "Please check a file : ./scripts/base/_platform.sh" && exit
fi
```

### Multi-Platform Branching

All platform-sensitive code must branch on `PLATFORM_TYPE` (set by `_abstract.sh`):

```bash
if [ "${PLATFORM_TYPE}" == "Linux" ]; then
  # --------------------------------------------------------------------------------------------------------------------
  # Platform - Linux
  # --------------------------------------------------------------------------------------------------------------------
  ...

elif [ "${PLATFORM_TYPE}" == "Darwin" ]; then
  # --------------------------------------------------------------------------------------------------------------------
  # Platform - MacOS
  # --------------------------------------------------------------------------------------------------------------------
  ...

elif [ "${PLATFORM_TYPE}" == "Windows" ]; then
  # --------------------------------------------------------------------------------------------------------------------
  # Platform - Windows
  # --------------------------------------------------------------------------------------------------------------------
  ...

else
  echo "Please check Operating System"
  setExit
fi
```

### Error Handling

```bash
# Guard missing command
command -v rsync &>/dev/null || { log_error "rsync is not installed."; exit 1; }

# Guard missing directory
[[ -d "${TARGET_DIR}" ]] || { log_error "Directory not found: ${TARGET_DIR}"; exit 1; }

# Guard unset required variable — preferred over bare exit
[[ -n "${ENVIRONMENT_NAME}" ]] || { echo "Error: ENVIRONMENT_NAME is not set."; exit 1; }

# setExit — call when a fatal condition is detected inside a source'd script
# Uses kill -SIGKILL $$ to terminate the parent shell that sourced this script.
# Do NOT use plain 'exit' inside sourced sub-scripts; it would only exit the subshell.
setExit
```

> ⚠️ `setExit` calls `kill -SIGKILL $$` intentionally. When a sub-script is `source`'d into a
> parent shell, a plain `exit` only exits the current function scope. `kill -SIGKILL $$` sends
> SIGKILL to the PID of the parent (sourcing) shell, guaranteeing the entire script tree stops.
> Use `setExit` only for unrecoverable errors.

### Interactive Environment Menu

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

### Argument Processing

```bash
function usage() {
    cat <<EOF
Usage: $(basename "$0") [options]

Options:
  -d, --dir <path>    Target directory (default: /tmp)
  -v, --verbose       Verbose output
  -h, --help          Show this help
EOF
}

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -d|--dir)   TARGET_DIR="$2"; shift 2 ;;
        -v|--verbose) VERBOSE=true; shift ;;
        -h|--help)  usage; exit 0 ;;
        *) echo "[ ERROR ] Unknown option: $1"; usage; exit 1 ;;
    esac
done
```

---

## ShellCheck Configuration

The project ships `scripts/.shellcheckrc` with these disabled rules:

| Code | Reason disabled |
|------|----------------|
| `SC2034` | Variables set in lib scripts are consumed by the sourcing parent — appears "unused" to ShellCheck |
| `SC2168` | `local` used in sourced sub-scripts that run outside a named function (e.g., `_platform.sh`) |
| `SC1091` | Source paths are dynamic (`${PROJECT_PATH}/…`) and not resolvable at lint time |
| `SC2155` | Declare-and-assign in one line — accepted for readability in this codebase |
| `SC2225` | Specific to compound commands used in this project |
| `SC2024` | `sudo` with output redirection (intentional in install scripts) |

Always run `shellcheck` before committing new scripts:

```bash
shellcheck scripts/deploy/dev/linux/ubuntu/deploy.sh
```

---

## Portability Guidelines

- **Shebang**: Use `#!/bin/bash` for project scripts; `#!/bin/sh` only for Docker entrypoints
- **Bash 4+ features** (`associative array`, `mapfile`): note the minimum version when using
- macOS vs Linux command differences:
  - `sed -i ''` (macOS) vs `sed -i` (Linux) → prefer `perl -pi -e` for cross-platform
  - `date -d` (GNU) not available on macOS → use `python3 -c "from datetime import …"` if needed
- Do not assume GNU coreutils on macOS — test on both platforms when modifying multi-platform scripts

---

## Security Checklist

스크립트를 제안하거나 리뷰할 때 아래 항목을 자동으로 검토한다:

- [ ] External inputs (arguments, env vars) are validated before use
- [ ] `eval` is prohibited; flag explicitly if unavoidable
- [ ] Temporary files created with `mktemp`, cleaned up with `trap`
- [ ] Secrets (passwords, tokens) are read from environment variables or `.env.app` — never hardcoded
- [ ] Script permissions: `chmod 700` or `chmod 750`
- [ ] `rm -rf` with a variable always uses `${VAR:?}` guard

```bash
# Safe rm -rf pattern
rm -rf "${BUILD_DIR:?BUILD_DIR is not set}"
```

---

## Comment Rules

```bash
# ── Section separator (major block) ─────────────────────────────────────────

# >>>> Category - Sub-item (inline group label)

# TODO: items that need future improvement
# FIXME: known bugs or temporary workarounds
# NOTE: non-obvious behavior that would surprise a reader
```

---

## Anti-patterns

다음 패턴이 발견되면 반드시 지적하고 안전한 대안을 제시한다:

| Anti-pattern | Reason | Alternative |
|---|---|---|
| `cat file \| grep` | Useless Use of Cat | `grep pattern file` or `< file grep pattern` |
| `cat file \| cmd` | Useless Use of Cat | `cmd < file` |
| `rm -rf /` or `rm -rf "${VAR}"` without guard | Can delete entire filesystem | `rm -rf "${VAR:?}"` |
| `ls \| grep` | Breaks on spaces and special chars | `find` + `-name` |
| `[[ $var == *foo* ]]` without quotes | Word splitting risk | Always double-quote: `[[ "$var" == *foo* ]]` |
| `export VAR=password123` | Exposes secret in process list | Read from `.env.app` or `read -s` |
| `2>/dev/null` used broadly | Hides errors silently | Explicit error handling |
| `source` without existence check | Silent failure if file missing | Use guarded source pattern (see above) |

---

## Response Structure

스크립트를 제공할 때는 아래 순서로 응답한다:

1. **목적 한 줄 요약** — 스크립트가 무엇을 하는지
2. **사전 요구사항** — 필요한 도구, 권한, 환경변수
3. **스크립트 코드 블록** — 완전한 실행 가능 코드
4. **실행 방법** — `chmod +x`, 실행 명령 예시
5. **주의사항** (해당 시) — 부작용, 롤백 방법, 환경 의존성
