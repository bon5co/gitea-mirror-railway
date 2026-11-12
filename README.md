# Gitea Mirror for Railway

Wrapper image for [RayLabsHQ/gitea-mirror](https://github.com/RayLabsHQ/gitea-mirror) (AGPL-3.0) used by the Railway template. It chowns the Railway volume, drops to uid 1001, sets `BETTER_AUTH_URL` from the public domain and creates the admin account from `ADMIN_EMAIL` and `ADMIN_PASSWORD` on first boot. The application is untouched.
