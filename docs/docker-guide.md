# Docker + Postgres Reference Guide

Personal reference notes for how this project's local Postgres setup works.
Circle back here when you're ready to actually learn/tweak the Docker side.

## Why Docker for the database at all?

- Anyone (you, a teammate, CI) can run `docker compose up` and get an
  identical Postgres instance, without installing/configuring Postgres
  natively on their machine.
- It mirrors production: on Render, the backend and the database are also
  separate, independently-deployed services talking over a network
  connection — not sharing a process or a filesystem. Developing that way
  locally avoids "works on my machine because it's not really isolated"
  surprises.

## The two files

- **`.env`** — actual secrets/config for your machine. **Never committed**
  (it's in `.gitignore`).
- **`.env.example`** — a checked-in template showing which variables are
  needed, with placeholder/dummy values, so anyone cloning the repo knows
  what `.env` they need to create.
- **`docker-compose.yml`** — the service definition. Committed. Reads its
  actual values from `.env` at runtime — never hardcode secrets in here.

## Anatomy of the `docker-compose.yml`

| Key | Purpose |
|---|---|
| `image: postgres:16` | Official Postgres image. Version is **pinned** (not `latest`) so local behavior matches what you deploy — an unplanned major-version upgrade can change defaults or break compatibility. |
| `env_file: .env` | Postgres's official image reads `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB` on first startup to create the superuser role and initial database. `env_file` injects these into the container from `.env` instead of hardcoding them in the committed YAML. |
| `ports: ["127.0.0.1:${POSTGRES_PORT:-5432}:5432"]` | `host:container`. Maps a port on your machine to Postgres's port inside the container, so tools on your host (`psql`, your .NET app, DBeaver/TablePlus) can reach it at `localhost:<port>` (`POSTGRES_PORT` from `.env`, defaulting to `5432`). The `127.0.0.1` prefix restricts this to your own machine — without it, Postgres would be reachable from any other device on your network. |
| `volumes` | Containers are ephemeral by default — deleting/recreating the container wipes its filesystem. A **named volume** mounted at `/var/lib/postgresql/data` (Postgres's data directory) persists your data across `docker compose down` / restarts. Only `docker compose down -v` (note the `-v`) destroys it. |
| `healthcheck` | Runs `pg_isready` on an interval so Docker (and later, dependent services) know when Postgres is actually accepting connections, not just "the container process started." Startup and "ready" are not the same moment for Postgres. |
| `restart: unless-stopped` | Container restarts automatically after a crash or machine reboot, but stays down if you deliberately `docker compose stop` it. |

## Everyday commands

```bash
# Start the database in the background
docker compose up -d

# View logs (useful when it won't start)
docker compose logs -f postgres

# Check running containers + health status
docker compose ps

# Connect with the Postgres CLI client
psql "postgresql://<user>:<password>@localhost:<port>/<db>"

# Stop the container but KEEP the data volume
docker compose stop

# Stop and remove the container (data volume still persists)
docker compose down

# Stop and WIPE the data volume too (fresh start / nuke local data)
docker compose down -v
```

## Local vs. Render (deployment)

- Locally: Postgres runs as a container defined by `docker-compose.yml`,
  and you connect to it at `localhost:<port>`.
- On Render: you'll provision a **Render Postgres** instance (a managed
  database, not a container you define yourself) or run Postgres as its
  own Render service. Either way, your backend connects to it via a
  connection string supplied through Render's environment variables —
  same idea as `.env` locally, just injected by Render instead of read
  from a file.
- The actual **schema** (tables, migrations) is what travels between
  environments — you'll run the same migration files against local
  Postgres and against the Render database to keep them in sync.

## Things to double check when you circle back

- [ ] Is `.env` actually excluded by `.gitignore`? (`git status` should
      never show it as trackable)
- [ ] Does `docker compose ps` show the container as `healthy`, not just
      `running`?
- [ ] Can you connect with `psql` using the credentials from `.env`?
- [ ] Does data survive a `docker compose down` + `docker compose up -d`
      (without `-v`)?
