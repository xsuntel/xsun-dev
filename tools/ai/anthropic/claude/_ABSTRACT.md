# Claude Code

## Platform

* Linux - Ubuntu
  * install

    ```bash
    curl -fsSL https://claude.ai/install.sh | bash
    ```

* MacOS
  * install

    ```bash
    curl -fsSL https://claude.ai/install.sh | bash
    ```

* Windows
  * install

    ```bash
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    ```

    ```bash
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    ```

    ```bash
    Restart-Computer
    ```

    ```bash
    wsl --update
    ```

    ```bash
    wsl --set-default-version 2
    ```

    ```bash
    wsl --list --online
    ```

    ```bash
    wsl --install Ubuntu-24.04
    ```

    ```bash
    curl -0- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
    ```

    ```bash
    \. "$HOME/.nvm/nvm.sh"
    ```

    ```bash
    nvm install 24
    ```

    ```bash
    node -v
    npm -v
    ```

    ```bash
    npm install -g @anthropic-ai/claude-code
    ```

## Project

* Global settings

    ```bash
    vi ~/.claude/settings.json

    {
        "includeCoAuthoredBy": false
    }
    ```

## Tools

* Packages - uvx

    ```bash
    curl -LsSf https://astral.sh/uv/install.sh | sh
    ```

## Reference

* Claude
  * [Code](https://claude.com/product/claude-code)
    * Developing inside a container - [Document](https://docs.anthropic.com/en/docs/claude-code/devcontainer)
    * [Compound Engineering](https://github.com/EveryInc/compound-engineering-plugin)
  * Reference
    * GitHub
      * [claude-cmd](https://github.com/kiliczsh/claude-cmd)
* VSCode
  * Developing inside a Container - [Document](https://code.visualstudio.com/docs/devcontainers/containers)
    * Development Containers - [Document](https://containers.dev/)
