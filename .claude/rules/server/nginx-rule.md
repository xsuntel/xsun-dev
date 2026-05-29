# Server Rules

@see https://symfony.com/doc/current/setup/web_server_configuration.html
@see https://symfony.com/doc/current/setup/web_server_configuration.html#nginx
@see https://nginx.org/en/docs/

## General Rules

- Never run nginx as `user root;` — use `user www-data;` in Ubuntu base configs; remove the `user`
  directive entirely in the Alpine production container (Alpine's nginx default is already non-root).
- Always set `server_tokens off;` explicitly in every `server {}` block — never rely on a global default.
- Always validate config with `nginx -t` before reloading; in Docker: `docker exec <container> nginx -t`.
- Never edit nginx config files inside a running container — always modify the source under
  `scripts/containers/prod/server/nginx/` and rebuild the image.
- Keep base/dev (`scripts/base/server/nginx/`) and prod (`scripts/containers/prod/server/nginx/`)
  location blocks in sync — they must implement identical Symfony routing logic; only `fastcgi_pass`
  socket path and `listen` address differ between environments.
- Never put `proxy_buffering off;` in a `server {}` block — it is an HTTP proxy directive with no
  effect in a direct nginx→php-fpm setup; scope `fastcgi_buffering` directives inside the
  `location ~ ^/index\.php` block instead.
- Never expose the PHP-FPM status page (`pm.status_path`) publicly — gate it with
  `allow 127.0.0.1; deny all;` if monitoring requires it.

## Directory Structure

| File                                                             | Environment          | Role                                     |
| ---------------------------------------------------------------- | -------------------- | ---------------------------------------- |
| `scripts/base/server/nginx/nginx.conf`                           | Base / Ubuntu dev    | Main http context (Ubuntu package paths) |
| `scripts/base/server/nginx/conf.d/symfony.conf`                  | Base / Ubuntu dev    | Virtual host, port 80, Unix socket       |
| `scripts/containers/prod/server/nginx/etc/nginx/nginx.conf`      | Production container | Alpine http context                      |
| `scripts/containers/prod/server/nginx/etc/nginx/http.d/www.conf` | Production container | Virtual host, port 8080, TCP socket      |

**Dockerfile note:** The production Dockerfile copies only `http.d/www.conf` (line 128). The
`nginx.conf` COPY is commented out — changes to `nginx.conf` require uncommenting line 127 and
rebuilding the image.

**TLS note:** External TLS termination is handled by the host reverse proxy on port 443. The
container exposes port 8080 internally and does not terminate SSL itself.

## Nginx Configuration

### Base / Dev

Corrected, annotated `scripts/base/server/nginx/nginx.conf`:

```nginx
user www-data;                          # Never root
worker_processes auto;
worker_rlimit_nofile 65535;             # Required for high-concurrency
error_log /var/log/nginx/error.log warn;
pid /run/nginx.pid;

include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
    multi_accept on;
}

http {
    sendfile        on;
    tcp_nopush      on;
    tcp_nodelay     on;
    keepalive_timeout 65;
    types_hash_max_size 4096;

    include         /etc/nginx/mime.types;
    default_type    application/octet-stream;

    gzip on;
    gzip_disable "msie6";
    gzip_comp_level 6;                  # Balanced CPU vs compression ratio
    gzip_min_length 1024;               # Never compress tiny responses
    gzip_vary on;                       # Required for CDN/proxy correctness
    gzip_types
        text/plain text/css text/xml text/javascript
        application/json application/javascript        # Not x-javascript (deprecated)
        application/xml application/xml+rss
        application/x-font-ttf font/opentype
        image/svg+xml image/x-icon;

    server_names_hash_max_size    512;
    server_names_hash_bucket_size 128;

    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    access_log /var/log/nginx/access.log main;

    include /etc/nginx/conf.d/*.conf;
}
```

Corrected, annotated `scripts/base/server/nginx/conf.d/symfony.conf`:

```nginx
server {
    listen 80;
    server_name localhost;
    server_tokens off;

    root /var/www/app/public;
    index index.php;

    client_max_body_size 128M;           # Intentional override — file uploads require this
    keepalive_timeout 5;
    send_timeout 10s;
    client_header_buffer_size 8k;
    large_client_header_buffers 8 32k;   # Sized for Symfony session tokens + JWT headers

    # Security headers — required on every server block
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    # Do NOT add Content-Security-Policy here — manage it in Symfony (NelmioSecurityBundle)

    # Health check — short-circuit before any PHP processing
    location = /healthcheck.php {
        allow all;
        log_not_found off;
        access_log off;
        return 200;
        break;
    }

    location = /robots.txt  { allow all; log_not_found off; access_log off; break; }
    location = /sitemap.xml { allow all; log_not_found off; access_log off; break; }

    # AssetMapper versioned assets — content-hashed filenames, 1-year immutable cache
    location /assets {
        allow all;
        log_not_found off;
        access_log off;
        expires 1y;
        add_header Cache-Control "public, immutable";
        break;
    }

    # Symfony bundle assets — not content-hashed, moderate TTL
    location /bundles {
        try_files $uri =404;
        expires 7d;
        add_header Cache-Control "public";
    }

    # Symfony front controller routing
    location / {
        try_files $uri /index.php$is_args$args;
    }

    location ~ ^/index\.php(/|$) {
        fastcgi_buffering on;
        fastcgi_buffers 16 32k;
        fastcgi_buffer_size 64k;

        fastcgi_connect_timeout 10s;    # Connect must be fast — 180s masks FPM pool exhaustion
        fastcgi_send_timeout 60s;
        fastcgi_read_timeout 180s;      # Long read permitted for heavy financial data requests

        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
        fastcgi_split_path_info ^(.+\.php)(/.*)$;
        include fastcgi_params;

        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        fastcgi_param DOCUMENT_ROOT $realpath_root;
        fastcgi_hide_header X-Powered-By;
        fastcgi_intercept_errors off;

        internal;
    }

    # Block all other .php files
    location ~ \.php$ {
        return 404;
    }

    # Block sensitive file types
    location ~ \.(env|sh|ini|local|pwd|yml|cgi|jsp|asp|aspx|perl|py|tar|git|sql|log|bak|swp)$ {
        deny all;
        log_not_found off;
        access_log off;
    }

    access_log /var/log/nginx/www_access.log;
    error_log  /var/log/nginx/www_error.log warn;
}
```

### Production Container

Corrected, annotated `scripts/containers/prod/server/nginx/etc/nginx/nginx.conf`:

```nginx
# user directive omitted — Alpine nginx default is non-root

worker_processes auto;
worker_rlimit_nofile 65535;
pcre_jit on;

error_log /var/log/nginx/error.log warn;

include /etc/nginx/modules/*.conf;
include /etc/nginx/conf.d/*.conf;

events {
    worker_connections 1024;
    multi_accept on;
}

http {
    include      /etc/nginx/mime.types;
    default_type application/octet-stream;

    server_tokens off;
    client_max_body_size 1m;            # http-level default; overridden per server block

    sendfile   on;
    tcp_nopush on;
    tcp_nodelay on;

    # TLS — TLSv1.1 removed (deprecated RFC 8996)
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384';
    ssl_prefer_server_ciphers on;
    ssl_dhparam /etc/ssl/nginx/dh2048.pem;   # Generate before first deployment (see checklist)
    ssl_session_cache shared:SSL:2m;
    ssl_session_timeout 1h;
    ssl_session_tickets off;                 # Session tickets are insecure

    gzip on;                            # Was commented out — must be enabled
    gzip_disable "msie6";
    gzip_comp_level 6;
    gzip_min_length 1024;
    gzip_vary on;
    gzip_types
        text/plain text/css text/xml text/javascript
        application/json application/javascript
        application/xml application/xml+rss
        application/x-font-ttf font/opentype
        image/svg+xml image/x-icon;

    # WebSocket upgrade map — used in proxy locations if needed
    map $http_upgrade $connection_upgrade {
        default upgrade;
        ''      close;
    }

    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    access_log /var/log/nginx/access.log main;

    include /etc/nginx/http.d/*.conf;
}
```

Corrected, annotated `scripts/containers/prod/server/nginx/etc/nginx/http.d/www.conf`:

```nginx
server {
    listen 0.0.0.0:8080;
    server_name example.ai example.blog example.dev example.tv example.kr;
    server_tokens off;

    # sendfile off — intentional for Docker volume compatibility
    # Change to 'on' only on production bare-metal (not in containers with volume mounts)
    sendfile off;

    root /var/www/app/public;
    index index.php;

    client_max_body_size 128M;
    keepalive_timeout 5;
    send_timeout 10s;
    client_header_buffer_size 8k;
    large_client_header_buffers 8 32k;

    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    location = /healthcheck.php {
        allow all;
        log_not_found off;
        access_log off;
        return 200;
        break;
    }

    location = /robots.txt  { allow all; log_not_found off; access_log off; break; }
    location = /sitemap.xml { allow all; log_not_found off; access_log off; break; }

    location /assets {
        allow all;
        log_not_found off;
        access_log off;
        expires 1y;
        add_header Cache-Control "public, immutable";
        break;
    }

    location /bundles {
        try_files $uri =404;
        expires 7d;
        add_header Cache-Control "public";
    }

    location / {
        try_files $uri /index.php$is_args$args;
    }

    location ~ ^/index\.php(/|$) {
        fastcgi_buffering on;
        fastcgi_buffers 16 32k;
        fastcgi_buffer_size 64k;

        fastcgi_connect_timeout 10s;
        fastcgi_send_timeout 60s;
        fastcgi_read_timeout 180s;

        fastcgi_pass 127.0.0.1:9000;    # TCP — php-fpm and nginx share the same container
        fastcgi_split_path_info ^(.+\.php)(/.*)$;
        include fastcgi_params;

        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        fastcgi_param DOCUMENT_ROOT $realpath_root;
        fastcgi_hide_header X-Powered-By;
        fastcgi_intercept_errors off;

        internal;
    }

    location ~ \.php$ {
        return 404;
    }

    location ~ \.(env|sh|ini|local|pwd|yml|cgi|jsp|asp|aspx|perl|py|tar|git|sql|log|bak|swp)$ {
        deny all;
        log_not_found off;
        access_log off;
    }

    access_log /var/log/nginx/access.log;
    error_log  /var/log/nginx/error.log warn;
}
```

## Symfony Routing

@see https://symfony.com/doc/current/setup/web_server_configuration.html#nginx

The canonical three-location pattern — order is significant; never reorder these blocks:

```nginx
# 1. Serve static files directly; fall through to index.php if not found
location / {
    try_files $uri /index.php$is_args$args;
}

# 2. Route all PHP through the front controller only
location ~ ^/index\.php(/|$) {
    fastcgi_pass unix:/run/php/php8.4-fpm.sock;  # dev
    # fastcgi_pass 127.0.0.1:9000;               # prod container
    fastcgi_split_path_info ^(.+\.php)(/.*)$;
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
    fastcgi_param DOCUMENT_ROOT $realpath_root;
    internal;
}

# 3. Block all other .php files
location ~ \.php$ {
    return 404;
}
```

- Never omit `internal;` — it prevents direct browser requests to `/index.php`
- Never add `$uri/` to the `try_files` fallback — a directory listing fallback is not needed
- Never change the `fastcgi_split_path_info` regex — it handles Symfony PATH_INFO correctly
- Always use `$realpath_root` (not `$document_root`) — prevents OPcache path issues when deploying
  with symlink switching

## PHP-FPM Connection

@see https://www.php.net/manual/en/install.fpm.configuration.php

| Environment          | FPM `listen`               | nginx `fastcgi_pass`            |
| -------------------- | -------------------------- | ------------------------------- |
| Base / Ubuntu dev    | `/run/php/php8.4-fpm.sock` | `unix:/run/php/php8.4-fpm.sock` |
| Production container | `127.0.0.1:9000`           | `127.0.0.1:9000`                |

- Prefer Unix socket in the Ubuntu dev environment — lower latency, no TCP overhead, same host
- Use TCP in the Alpine production container — the Alpine php-fpm default pool uses `127.0.0.1:9000`
- Never bind PHP-FPM to `0.0.0.0` — always use `127.0.0.1` for TCP
- When nginx sits behind an SSL-terminating reverse proxy, add the following to `fastcgi_params`
  so Symfony generates correct HTTPS URLs:
  ```nginx
  fastcgi_param HTTPS on;
  fastcgi_param HTTP_X_FORWARDED_PROTO https;
  ```
- Keep `fastcgi_read_timeout` shorter than PHP-FPM's `request_terminate_timeout` (120s in the
  production pool) — nginx must not wait longer than FPM will run a request

## Static Asset Delivery

### AssetMapper Versioned Assets (`/assets/`)

`asset-map:compile` outputs content-hashed filenames (e.g., `app-abc123def.js`). A short TTL
defeats this versioning strategy — always use `1y` with `immutable`:

```nginx
location /assets {
    expires 1y;
    add_header Cache-Control "public, immutable";
    log_not_found off;
    access_log off;
}
```

- Never set a TTL shorter than 1 year for `/assets/` — the hash in the filename is the cache buster
- The `immutable` directive tells browsers to skip revalidation entirely for the asset's lifetime

### Bundle Assets (`/bundles/`)

Bundle assets are not content-hashed — use a moderate TTL:

```nginx
location /bundles {
    try_files $uri =404;
    expires 7d;
    add_header Cache-Control "public";
}
```

### Public Metadata

```nginx
location = /robots.txt  { allow all; log_not_found off; access_log off; }
location = /sitemap.xml { allow all; log_not_found off; access_log off; }
```

## Security Directives

### Server Identity

- Always set `server_tokens off;` in every `server {}` block
- Always add `fastcgi_hide_header X-Powered-By;` inside the `location ~ ^/index\.php` block
- Never add a custom `Server:` response header — `server_tokens off` is sufficient

### File Type Blocking

Always place this block **after** `location ~ \.php$`:

```nginx
location ~ \.(env|sh|ini|local|pwd|yml|cgi|jsp|asp|aspx|perl|py|tar|git|sql|log|bak|swp)$ {
    deny all;
    log_not_found off;
    access_log off;
}
```

### Security Response Headers

Always include in every `server {}` block:

```nginx
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
```

- Do **not** add `Content-Security-Policy` in nginx — CSP is application-specific; manage it in
  Symfony (NelmioSecurityBundle) or via response headers in controllers

### SSL / TLS (Production `nginx.conf`)

```nginx
ssl_protocols TLSv1.2 TLSv1.3;          # TLSv1.1 removed — deprecated per RFC 8996
ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384';
ssl_prefer_server_ciphers on;
ssl_dhparam /etc/ssl/nginx/dh2048.pem;  # Must exist before deployment
ssl_session_cache shared:SSL:2m;
ssl_session_timeout 1h;
ssl_session_tickets off;                # Session tickets are insecure
```

Generate the DH parameters file once on the production server before first deployment:

```bash
openssl dhparam -out /etc/ssl/nginx/dh2048.pem 2048
```

## Performance Tuning

### Gzip

```nginx
gzip on;
gzip_disable "msie6";
gzip_comp_level 6;        # Level 6 is the standard balanced value
gzip_min_length 1024;     # Skip compression on responses smaller than 1 KB
gzip_vary on;             # Add Vary: Accept-Encoding — required for CDN correctness
gzip_types
    text/plain text/css text/xml text/javascript
    application/json application/javascript
    application/xml application/xml+rss
    application/x-font-ttf font/opentype
    image/svg+xml image/x-icon;
```

- Never use `application/x-javascript` — it is deprecated; use `application/javascript`
- Never add image formats (`image/jpeg`, `image/png`, `image/gif`) — they are already compressed
- `gzip on;` in the production `nginx.conf` was commented out — always enable it

### sendfile and TCP

- Use `sendfile on; tcp_nopush on;` at http level — they must be paired; `tcp_nopush` has no
  effect without `sendfile`
- `sendfile off;` in `http.d/www.conf` intentionally overrides the http-level setting for Docker
  volume compatibility; change to `on` only on production bare-metal deployments
- Add `tcp_nodelay on;` at http level for responsive interactive connections

### FastCGI Buffering

- Always keep `fastcgi_buffering on;` inside the PHP location — buffering lets nginx release
  php-fpm workers as soon as the full response is received
- `fastcgi_buffers 16 32k; fastcgi_buffer_size 64k;` — sized for Symfony toolbar HTML; do not
  reduce without profiling
- `fastcgi_connect_timeout 10s;` — connection to a running FPM process is near-instant; a value
  of 180s silently masks php-fpm pool exhaustion
- `fastcgi_read_timeout 180s;` — acceptable for heavy financial data aggregation requests in this
  project

## WebSocket and Turbo Streams

### Turbo Stream HTTP Responses

Turbo Streams are delivered as standard HTTP responses with
`Content-Type: text/vnd.turbo-stream.html`. No special nginx configuration is required — they
traverse the standard `try_files` → `index.php` path. Keep `fastcgi_buffering on;` for these
responses; PHP assembles the full stream fragment before sending.

### SSE / EventSource (for future Mercure hub integration)

When adding SSE endpoints, add a dedicated location block **before** the main PHP block to disable
buffering for that path only:

```nginx
# Never set fastcgi_buffering off at the server level — scope it to SSE locations only
location ~ ^/(api/events|\.well-known/mercure) {
    fastcgi_buffering off;
    fastcgi_read_timeout 3600s;          # SSE connections are long-lived
    fastcgi_pass unix:/run/php/php8.4-fpm.sock;
    fastcgi_split_path_info ^(.+\.php)(/.*)$;
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME $realpath_root/index.php;
    fastcgi_param DOCUMENT_ROOT $realpath_root;
    internal;
}
```

### WebSocket Proxy (for future use)

The `map $http_upgrade $connection_upgrade` block is already present in the production `nginx.conf`.
Use it with a dedicated proxy location:

```nginx
location /ws/ {
    proxy_pass http://127.0.0.1:8000;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection $connection_upgrade;
    proxy_set_header Host $host;
    proxy_read_timeout 3600s;
}
```

**Note:** Current Ratchet/Pawl WebSocket connections (example, example) are **outbound** from
PHP worker processes — they do not require any nginx WebSocket proxy configuration.

### Live Components

Live Component requests (`/{_locale}/_components/...`) are standard AJAX/POST requests. They
traverse the standard `try_files` → `index.php` path with no special nginx handling required.

## Health Check Endpoint

```nginx
location = /healthcheck.php {
    allow all;
    log_not_found off;
    access_log off;    # Suppress probe log noise — health checks run every few seconds
    return 200;
    break;
}
```

- Always suppress access logging on health check locations
- `return 200;` short-circuits PHP — `app/public/healthcheck.php` does not execute
- Never place PHP-blocking rules before this location
- Docker health check command: `curl -f http://localhost:8080/healthcheck.php || exit 1`

## Production Optimization Checklist

```bash
# ── 1. Environment ─────────────────────────────────────────────────────────
APP_ENV=prod
APP_DEBUG=false

# Compile .env files into .env.local.php — faster than runtime .env parsing
cd app && APP_ENV=prod APP_DEBUG=0 composer dump-env prod

# ── 2. Dependencies ─────────────────────────────────────────────────────────
cd app && composer install --no-dev --optimize-autoloader --classmap-authoritative

# ── 3. Symfony Cache ────────────────────────────────────────────────────────
cd app && php bin/console cache:clear --no-warmup --env=prod
cd app && php bin/console cache:warmup --env=prod

# ── 4. AssetMapper + Tailwind ───────────────────────────────────────────────
cd app && symfony console tailwind:build --minify
cd app && symfony console asset-map:compile   # Outputs content-hashed files to app/public/assets/

# ── 5. Doctrine Migrations (run for each affected EntityManager) ────────────
cd app && php bin/console doctrine:migrations:migrate --no-interaction --em=abstract --env=prod
# Repeat --em=<name> for each EntityManager with schema changes in this release

# ── 6. Nginx ────────────────────────────────────────────────────────────────
nginx -t                  # Always validate before reloading
nginx -s reload           # Zero-downtime reload (in Docker: kill -HUP 1)

# ── 7. PHP OPcache ──────────────────────────────────────────────────────────
# Restart FPM to clear OPcache after deployment
kill -USR2 $(cat /var/run/php/php8.4-fpm.pid)

# ── 8. DH Parameters (first deployment only) ────────────────────────────────
openssl dhparam -out /etc/ssl/nginx/dh2048.pem 2048
```

## Deployment Rules

@see https://symfony.com/doc/current/deployment.html

- Exclude `var/cache/`, `var/log/`, and `var/sessions/` from deployment archives — they are runtime
  artifacts, not source files.
- Never commit `.env.local` or `.env.prod.local` — inject secrets via Docker environment variables
  or a secrets manager in production.
- Always run `doctrine:migrations:migrate --no-interaction --em=<name>` for each EntityManager that
  has schema changes in the release.
- Use zero-downtime deployment: build the Docker image → run `cache:warmup` inside the container →
  switch traffic to the new container.
- Always run `nginx -t` before `nginx -s reload` — a syntax error in the config will cause nginx to
  stop serving all requests on reload.
- Always run `asset-map:compile` before building the Docker image — compiled assets must be baked
  into the image, not mounted as a volume at runtime.
- Never deploy with `APP_DEBUG=true` — it disables OPcache file override and exposes full stack
  traces in HTTP responses.
- Ensure `fastcgi_read_timeout` is shorter than PHP-FPM's `request_terminate_timeout` — nginx must
  not wait longer than FPM will run a given request.
- The production Dockerfile copies only `http.d/www.conf` (line 128). Changes to `nginx.conf`
  require uncommenting line 127 and rebuilding the image.
- After adding a new AssetMapper import path, run `asset-map:compile` locally and verify the
  generated `manifest.json` contains the expected entries before deploying.
