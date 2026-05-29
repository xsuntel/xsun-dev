#!/bin/sh
set -e

# >>>> PHP-FPM - Background
echo "[ Entrypoint ] Starting PHP..."
php-fpm -D

# >>>> Supervisor
echo "[ Entrypoint ] Starting Supervisor..."
/usr/bin/supervisord -c /etc/supervisord.conf

# >>>> Nginx   - Forground
echo "[ Entrypoint ] Starting Nginx..."
nginx -g "daemon off;"
