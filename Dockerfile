# Gitea Mirror for Railway.
#
# Gitea Mirror (RayLabsHQ/gitea-mirror, AGPL-3.0) mirrors GitHub repositories, organisations and starred repos into a
# Gitea or Forgejo server. Three stock behaviours need changing for a public Railway domain deployed by an agent.
#
# 1. Upstream opens email sign-up to whoever reaches the page FIRST, so a fresh public deploy is claimed by the first
#    stranger who finds the URL, and an agent has no admin login. railway-entrypoint.sh creates the admin account from
#    ADMIN_EMAIL and ADMIN_PASSWORD through the app's own sign-up endpoint as soon as it is healthy, which closes
#    sign-up (upstream refuses any further account unless AUTH_ALLOW_SIGNUP=true).
# 2. Upstream runs as uid 1001 and Railway mounts the volume owned by uid 0, so the entrypoint chowns /app/data and
#    then drops to uid 1001 with setpriv before calling the stock entrypoint.
# 3. BETTER_AUTH_URL has to be the public origin or every cookie-authenticated POST is refused as a forged origin.
#
# The application and its behaviour are otherwise untouched.
FROM ghcr.io/raylabshq/gitea-mirror:v3.51.7@sha256:70a6a1913cae929260f8b59449613537b77ffd44398d9b8ff8a2ce935fc11d7b

USER 0:0
COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint.sh
COPY bootstrap-admin.js /app/bootstrap-admin.js
RUN chmod +x /usr/local/bin/railway-entrypoint.sh

EXPOSE 4321
ENTRYPOINT ["/usr/local/bin/railway-entrypoint.sh"]
