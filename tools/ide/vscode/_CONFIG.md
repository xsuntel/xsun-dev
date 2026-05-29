# Visual Studio Code

## Manage

### Extensions

* App
  * CSS
    * Tailwind CSS IntelliSense                (Tailwind Labs)
  * HTML
    * Auto Closing Tags                        (Codegyan)
  * Javascript
    * ESLint                                   (Microsoft)
    * Stimulus LSP                             (Marco Roth)
  * PHP
    * PHP Intelephense                         (Intelephense)
    * PHP Debug                                (Xdebug)
  * Symfony Framework
    * Symfony for VSCode (fixed)               (SplasHmiCH)
    * Symfony UX Twig Component                (Sander Verschoor)
    * Twig Language 2                          (mblode)
* Cache
  * Redis for VS Code                          (Redis)
* Database
  * PostgreSQL                                 (Microsoft)
* Tools
  * IDE
    * YAML                                     (RedHat)
    * DotENV                                   (mikestead)
    * Prettier - Code formatter                (Prettier)
    * Markdownlint                             (David Anson)
    * Material Icon Theme                      (Philipp Kief)
* Util
  * Draw.io Integration                        (Henning Dieterichs)

### Settings

* Application / Proxy

```text
Use Local Proxy Configuration - UnChecked
```

* Extensions / .ipynb Support

```text
Experimental: Serialization - UnChecked
```

#### Language

* PHP

```text
Manage / Settings / PHP Suggest Basic - false
```

#### Keyboard Shortcuts

* ibus

```bash
ibus restart

IBUS_ENABLE_SYNC_MODE=1 code
```

```bash
vi ~/.bashrc

export IBUS_ENABLE_SYNC_MODE=1
export GTK_IM_MODULE=ibus
export QT_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
```

```bash
vi ~/.profile

export IBUS_ENABLE_SYNC_MODE=1
export GTK_IM_MODULE=ibus
export QT_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
```

* keybinding

```bash
ls -la ~/.config/Code/User/keybindings.json

sudo chown $USER:$USER ~/.config/Code/User/keybindings.json
chmod 644 ~/.config/Code/User/keybindings.json
```

```bash
cp ~/.config/Code/User/keybindings.json ~/.config/Code/User/keybindings.json.bak

echo "[]" > ~/.config/Code/User/keybindings.json
```

#### Tools

* Code Runner

```text
Code-runner: Enable App Insights - false
Code-runner: Run In Terminal - true
```

#### Tools - Copilot

* Copilot

```text
Chat: Disable AI Features - Disable (Checked)
Pgsql › Copilot: Enable   - UnChecked
```

#### Tools - Gemini Code Assist

* Gemini Code Assist
  * Geminicodeassist: Rules

```text
항상 @workspace 루트의 GEMINI.md 파일을 읽고 답변하라
```

* Control + ,

```text
"geminicodeassist.updateChannel": Insiders,
"geminicodeassist.contextualAwareness.enabled": true,
"geminicodeassist.search.maxResults": 10
```

* Control + Shift + P

```text
Developer: Reload Window
```

### Tasks - ${PROJECT_PATH}/.vscode/.tasks.json

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "App - Console - Cache",
            "type": "shell",
            "command": "./scripts/base/app/symfony/cache.sh",
            "group": "build",
            "presentation": {
                "reveal": "always",
                "panel": "new"
        }
    ]
}
```

## Reference

### IDE

* [VSCode](https://code.visualstudio.com/docs/languages/php)
