# Kaihai

A quiet community platform — spaces for posts, events, and polls, with
admin-issued invitations and self-hostable deployment.

Built for small, calm communities. No public sign-ups; new members arrive
through admin invitations. Open to host yourself.

## Getting started

### Self-host in production

You'll need a Linux server with Docker and an SSH key registered, plus a
container registry account (GitHub Container Registry, Docker Hub, etc.).
Then:

```bash
bin/kamal setup
```

[Kamal](https://kamal-deploy.org) builds the image, ships it to your
server, and serves it behind an auto-renewing Let's Encrypt certificate.
Subsequent updates are `bin/kamal deploy`.

Configure your server's host, registry, and domain in
[`config/deploy.yml`](config/deploy.yml) before the first run. The first
visit to your domain opens the setup wizard — set a community name and
create the founding admin.

### Run with Docker

If you'd rather skip Kamal — for a single-machine deployment, a VPS test,
or just to kick the tyres:

```bash
docker build -t kaihai .
docker run -d -p 80:80 \
  -e RAILS_MASTER_KEY="$(cat config/master.key)" \
  -v kaihai-data:/rails/storage \
  --name kaihai kaihai
```

- `RAILS_MASTER_KEY` decrypts `config/credentials.yml.enc` — keep its
  value secret.
- The `kaihai-data` volume preserves the SQLite database and uploads
  across container restarts.
- Add your own SSL termination (Caddy, Cloudflare, nginx) if exposing
  it on the internet — the image itself serves plain HTTP.

### Run locally

```bash
bin/setup
```

Installs dependencies, prepares the database, and starts a development
server on `http://localhost:3000`.

## License

Released under the [O'Saasy License](LICENSE.md) — free for any use except
running as a competing SaaS. Bundled third-party assets (icons, fonts) are
credited in [NOTICES.md](NOTICES.md).
