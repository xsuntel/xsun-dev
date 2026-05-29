# Server Rules (Nginx)

This system prompt defines the identity, technology stack, and behavioral guidelines for the AI assistant. Nginx is the primary web server for serving the Symfony application, and its configuration is crucial for performance, security, and correct routing.

## 1. Document Root & Entry Point

- **Document Root**: The Nginx `root` directive **must always point to the `app/public` directory** of the Symfony application. This ensures that only publicly accessible files are served directly and prevents direct access to sensitive application files.
    - **Example**: `root /path/to/xsun-app/app/public;`
- **Front Controller**: All requests that are not for existing static files must be rewritten to `app/public/index.php`. This is the single entry point for the Symfony application.

## 2. Request Handling & Routing

- **`try_files` Directive**: Use `try_files` to efficiently serve static assets and pass dynamic requests to the Symfony front controller.
    - **Standard Configuration**:
        ```nginx
        location / {
            try_files $uri /index.php$is_args$args;
        }
        ```
    - This attempts to serve the requested URI as a file, then as a directory, and finally falls back to `index.php` with the original arguments.

## 3. PHP-FPM Integration

- **FastCGI Pass**: Nginx communicates with PHP-FPM using the FastCGI protocol.
- **Socket/Port**: PHP-FPM should typically listen on a Unix socket (e.g., `unix:/var/run/php/php8.4-fpm.sock`) or a TCP port (e.g., `127.0.0.1:9000`). Unix sockets are generally preferred for performance when Nginx and PHP-FPM are on the same host.
- **Configuration Example**:
    ```nginx
    location ~ ^/index\.php(/|$) {
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock; # Or 127.0.0.1:9000
        fastcgi_split_path_info ^(.+\.php)(/.*)$;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        fastcgi_param DOCUMENT_ROOT $realpath_root;
        internal;
    }
    ```

## 4. Security Best Practices

- **Deny Access to Sensitive Files**: Prevent direct access to configuration files, `.env` files, `.git` directories, and other sensitive application files.
    ```nginx
    location ~ /\.env { deny all; }
    location ~ /\.git { deny all; }
    location ~ \.yaml$ { deny all; }
    # ... other sensitive files
    ```
- **Restrict Methods**: Only allow necessary HTTP methods (GET, POST, PUT, DELETE) for dynamic content.
- **HTTPS**: Always enforce HTTPS for all traffic in production environments.

## 5. Performance Optimization

- **Static Asset Caching**: Configure appropriate `expires` headers for static assets (CSS, JS, images) to leverage browser caching.
    ```nginx
    location ~* \.(css|js|gif|jpe?g|png)$ {
        expires 1y;
        add_header Cache-Control "public";
    }
    ```
- **Gzip/Brotli Compression**: Enable Gzip or Brotli compression for text-based assets (HTML, CSS, JavaScript, JSON) to reduce bandwidth usage.
    ```nginx
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
    # brotli on; (if available and configured)
    ```
- **Logging**: Configure access and error logs appropriately for monitoring and debugging.
    - `access_log /var/log/nginx/access.log;`
    - `error_log /var/log/nginx/error.log warn;`
