# Database — Setup Notes

Companion to `README.md`. That file is accurate and complete — this file just
adds the exact commands to go from clone to a running local database, plus a
list of known issues to be aware of while you work (see bottom).

## Setup steps

1. **Install and verify the tools below before doing anything else.** This
   is the step that's easy to skip and the one that causes the most
   confusing errors later -- a plain `command not found`, or a `docker
   compose` command that fails because Docker Desktop was never actually
   opened. Check each one; don't assume it's already there.

   **Homebrew** (macOS package manager -- everything else here installs
   through it):
   ```bash
   which brew
   ```
   If that prints nothing:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
   The installer prints its own final step to add Homebrew to your PATH
   (an `echo ... >> ~/.zshrc` line, slightly different on Intel vs. Apple
   Silicon Macs) -- run exactly what it tells you to, then open a new
   terminal tab before continuing.

   **Docker Desktop** (runs local Postgres via `docker compose`):
   ```bash
   which docker
   ```
   If that prints nothing:
   ```bash
   brew install --cask docker
   ```
   Installing it is not the same as it running. Docker Desktop has to be
   **open** (launch it from Applications or Spotlight, like any other app)
   before any `docker` command works -- if you ever see "Cannot connect to
   the Docker daemon," this is almost always the fix. It can take a few
   seconds after opening before it's actually ready.

   **dbmate** (runs migrations):
   ```bash
   which dbmate
   ```
   If that prints nothing:
   ```bash
   brew install dbmate
   ```

   **psql** (only needed if you want to run manual queries or load
   `db/seed.sql` yourself -- `dbmate up` doesn't need it):
   ```bash
   which psql
   ```
   If that prints nothing:
   ```bash
   brew install libpq
   ```
   `libpq` gives you `psql` without installing a full local Postgres
   server, but it doesn't add itself to your PATH automatically -- if
   `which psql` still comes up empty after installing, add it yourself:
   ```bash
   echo 'export PATH="/opt/homebrew/opt/libpq/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc
   ```
   (Intel Macs: use `/usr/local` instead of `/opt/homebrew` in that line.)

2. **Clone the repo, then copy the env file:**
   ```bash
   cp .env.example .env
   ```
   The defaults in `.env.example` (`silverlog` / `changeme`) are fine for
   local dev — you don't need to change anything unless you want your own
   values. See **Known Issues** below before you connect the backend to this
   database, though.

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

## Running migrations against Neon instead of local Postgres

For a Render deploy (or any time the database itself isn't local Postgres),
skip step 3 above (no Docker, no local Postgres server needed) -- migrations
still get run, just against Neon instead of a local database:

1. Get your Neon connection string from the Neon console's Connect button
   (the pooled/external one) and put it in `.env` as `DATABASE_URL`, in
   place of the local one. `.env.example` has a commented template for this.
   `sslmode=require` is mandatory for Neon's external connections; without
   it the connection is rejected outright, not just insecure.
2. Run migrations exactly the same way:
   ```bash
   dbmate up
   ```
   **This is the part that trips people up, so it's worth spelling out:**
   `dbmate` reads `.env` automatically -- you don't need to `export` or
   `source` anything for this step to work. If your `.env` has the right
   Neon URL in it, `dbmate up` just works, the same as it does locally.
3. `dbmate up` prints nothing on success -- no "5 tables created!" message,
   just your prompt back. That's normal, not a sign it silently failed.
   The real confirmation is in Neon itself: either the Neon console's own
   activity/monitoring will show a burst of queries right after you run it,
   or query the SQL Editor there directly:
   ```sql
   SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';
   ```
4. If you want to verify locally with `psql` instead (or run `db/seed.sql`
   against Neon), remember `psql` does *not* read `.env` the way `dbmate`
   does -- it only sees real shell environment variables. Export it first:
   ```bash
   export $(grep '^DATABASE_URL=' .env | xargs)
   echo $DATABASE_URL   # confirm it actually printed your Neon URL, not blank
   psql "$DATABASE_URL" -c "\dt"
   ```
   An empty `echo $DATABASE_URL` here means the export didn't take (a typo
   in the `.env` line, or a stray space) -- fix that before assuming
   anything's wrong with Neon or the migrations themselves.

---

## Known Issues

- **Backend password mismatch.** This repo's `.env.example` defaults to
  `POSTGRES_USER=silverlog` / `POSTGRES_PASSWORD=changeme`, but the backend
  repo's committed `appsettings.Development.json` hardcodes
  `Username=postgres;Password=postgres`. Whoever sets up the backend will get
  a connection failure unless one side is changed to match the other. Pick
  one convention and update both repos.

- **`users` table is missing a column the backend code expects.**
  `Silverlog.Services/AuthService.cs` reads and writes `user.LastLoginDate`
  (declared on the `User` entity in `Silverlog.Data/Entities/User.cs`), but no
  migration in `db/migrations/` ever adds a `last_login_date` column, and it
  isn't in the current `db/schema.sql`. As it stands, the first real Google
  sign-in against a freshly migrated database will throw at the database
  layer. A new migration is needed:
  ```bash
  dbmate new add_last_login_date_to_users
  ```
  adding something like:
  ```sql
  -- migrate:up
  ALTER TABLE users ADD COLUMN last_login_date timestamptz;

  -- migrate:down
  ALTER TABLE users DROP COLUMN last_login_date;
  ```

- **Enum mapping relies on a naming convention, not an explicit name.**
  The database README's own example code registers the enum explicitly
  (`dataSourceBuilder.MapEnum<UserRole>("user_role")`), but the backend's
  actual `Program.cs` calls `dataSourceBuilder.MapEnum<UserRole>()` with no
  name argument. This currently works because Npgsql's default naming
  convention happens to snake_case `UserRole` into `user_role`, but it's
  fragile — renaming the C# enum type would silently break the mapping with
  no compile-time warning. Worth making explicit to match the documented
  intent.
