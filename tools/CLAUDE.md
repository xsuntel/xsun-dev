# CLAUDE.md

This file configures Claude's behavior and expertise context for this project, Claude reads this file automatically when
working in this repository.

## Directory Structure & Path Context

The project infrastructure acts as a wrapper, and the related IDE's documents in the `./tools` directory.

```text
symfony-scripts/                             ← Repository root
└── tools/                                   ← Documents
    ├── ai/
    │   ├── anthropic/
    │   │   └── claude/
    │   └── microsoft/
    │       └── github/
    ├── api/
    ├── ide/                                 ← IDE
    │    ├── phpstorm/
    │    │   ├── _ABSTRACT.md
    │    │   └── _CONFIG.md
    │    └── vscoe/
    │        ├── _ABSTRACT.md
    │        └── _CONFIG.md
    └── CLAUDE.md
```
