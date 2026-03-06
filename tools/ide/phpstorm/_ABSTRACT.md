# Tools - IDE

## PhpStorm

### Config

#### Plugin

* Downloaded
  * PHP Annotations
  * Symfony Plugin
* Database
  * Database Tools and SQL
* HTML and XML
  * HTML Tools
* Javascript Frameworks and Tools
  * Javascript and TypeScript
  * Javascript Debugger
  * Javascript intention Power Pack
  * Nodejs
  * Prettier
* Languages
  * Ini
  * JSON
  * markdown
  * PHP
  * PHP Architecture
  * PHPT Support
  * Shell Script
  * YAML
* SpellChecker
  * Hunspell
* Style Sheet
  * CSS
* Template Languages
  * Twig
* Test Tools
  * PHPSpec BDD Framework
* Version Control
  * Git
* Other Tools
  * PHPStan Support
  * Psalm Support
  * Terminal

#### Settings

* Disable some configurations

```text
Settings / Appearance & Behavior / System Settings / Autosave / Sync external changes:


Settings / Appearance & Behavior / System Settings / HTTP Proxy
```

* Configure some configurations related Symfony Framework

```text
Settings / PHP / Symfony / Container:

HTTP Profiler - https://127.0.0.1:8080
```

```text
Settings / PHP / Symfony / Routing:

app/var/cache/dev/url_generating_routes.php
```

```text
Settings / PHP / Symfony / Profiler:

HTTP Profiler - https://127.0.0.1:8080
```

#### Menu / Help

* Edit Custom Properties

```text
# 수정된 권장 설정
idea.max.content.load.filesize=20000
idea.max.intellisense.filesize=2500
idea.cycle.buffer.size=1024

# VCS 파일 로드 제한 (너무 크면 인덱싱 시 버벅임 발생)
idea.max.vcs.loaded.size.kb=20480

# 타이핑 지연 최소화 (유지)
editor.zero.latency.typing=true

# 리눅스 환경에서의 렌더링 최적화
sun.java2d.pmoffscreen=false
```

* Edit Custom VM Options

```text
# 메모리 할당: 16GB RAM 기준 (8GB라면 -Xmx4096m 유지)
-Xms2048m
-Xmx4096m
-XX:ReservedCodeCacheSize=512m

# 최신 JVM 핵심 GC 설정 (G1GC 최적화)
-XX:+UseG1GC
-XX:SoftRefLRUPolicyMSPerMB=50
-XX:CICompilerCount=4
-XX:+HeapDumpOnOutOfMemoryError
-XX:-OmitStackTraceInFastThrow
-XX:+IgnoreUnrecognizedVMOptions

# 성능 및 안정성 보완
-XX:+TieredCompilation
-XX:+UseCompressedOops
-XX:+AlwaysPreTouch
-Dsun.io.useCanonCaches=false
-Dsun.java2d.metal=false
-Djava.net.preferIPv4Stack=true
-Dfile.encoding=UTF-8

# 리눅스/Ubuntu 전용 그래픽 가속 (하드웨어 사양에 따라 조정)
-Dsun.java2d.opengl=true

# 불필요한 로그 출력 억제 (성능 향상)
-XX:-PrintGCDetails
-XX:-PrintFlagsFinal
```

## Reference

* IDE
  * [PhpStorm](https://www.jetbrains.com/phpstorm)
    * Settings
      * PHP
        * Xdebug - [Configuration](https://www.jetbrains.com/help/phpstorm/debugging-with-phpstorm-ultimate-guide.html)
      * Deployment - [Deploying application](https://www.jetbrains.com/help/phpstorm/deploying-applications.html)
      * [Symfony Framework](https://www.jetbrains.com/help/phpstorm/symfony-support.html#use_symfony_cli)
    * Plugin
      * draw.io - [Integration](https://plugins.jetbrains.com/plugin/15635-diagrams-net-integration)
