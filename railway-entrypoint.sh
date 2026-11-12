#!/bin/sh
set -e

# Railway mounts the volume owned by uid 0; the app runs as uid 1001.
mkdir -p /app/data
chown -R 1001:1001 /app/data
echo "railway-entrypoint: /app/data owner=$(stat -c %u:%g /app/data)"

# Public origin for cookies and CSRF checks.
if [ -z "$BETTER_AUTH_URL" ] && [ -n "$RAILWAY_PUBLIC_DOMAIN" ]; then
  export BETTER_AUTH_URL="https://$RAILWAY_PUBLIC_DOMAIN"
fi

# Create the admin account once the app answers; never blocks or fails the boot.
if [ -n "$ADMIN_EMAIL" ] && [ -n "$ADMIN_PASSWORD" ]; then
  (setpriv --reuid=1001 --regid=1001 --init-groups bun /app/bootstrap-admin.js || true) &
fi

exec setpriv --reuid=1001 --regid=1001 --init-groups ./docker-entrypoint.sh
