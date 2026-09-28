# Database — Setup Notes

## Setup steps

1. **Install the tools below if you don't already have them:**

   ```bash
   brew install --cask docker
   brew install dbmate libpq
   ```

   Homebrew itself: https://brew.sh if you don't have `brew`. Docker Desktop
   needs to actually be running (not just installed) before `docker
compose` works. `libpq` gives you `psql`.

2. **Clone the repo, then copy the env file:**

   ```bash
   cp .env.example .env
   ```

   The defaults in `.env.example` (`silverlog` / `changeme`) are fine for
   local dev — you don't need to change anything unless you want your own
   values.

3. **Start Postgres:**

   ```bash
   docker compose up -d
   ```

   Confirm it's healthy:

   ```bash
   docker compose ps
   ```

   You should see `postgres` listed as `healthy`. If it isn't, run
   `docker compose logs postgres` and check the error.

4. **Run migrations:**

   ```bash
   dbmate up
   ```

   This creates all tables (`users`, `entries`, `codes`, `activities`) and
   the `user_role` enum, and regenerates `db/schema.sql`.

5. **(Optional) Load seed data:**

   ```bash
   set -a && source .env && set +a
   psql "$DATABASE_URL" -f db/seed.sql
   ```

   Requires `psql` 17.6+ locally (see README's Prerequisites section for why).

6. **Verify you're up and migrated:**
   ```bash
   set -a && source .env && set +a
   psql "$DATABASE_URL" -c "\dt"
   ```
   You should see `activities`, `codes`, `entries`, `schema_migrations`, and
   `users`.

At this point the database is ready for the backend to connect to it — see
that repo's `SETUP_NOTES.md` for the next step.

## Setting up Neon

This is how the actual deployed database got set up — a managed Postgres
project on Neon, with no server of our own to run:

1. Sign up / log in at neon.tech.
2. **New Project** → give it a name, pick a region.
3. That's it — the project comes up with a ready-to-use Postgres database
   immediately.
4. Get connection strings any time from the project dashboard's **Connect**
   button — it gives you both a direct string and a pooled (`-pooler` host)
   one. Put whichever one you need into `.env` as `DATABASE_URL` in place of
   the local Postgres line; `.env.example` has a commented template for
   this. `sslmode=require` is mandatory for Neon's external connections.
5. Run `dbmate up` exactly as you would locally — same command, it just
   applies to whichever database `DATABASE_URL` currently points at.
