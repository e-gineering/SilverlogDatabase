# Database — Setup Notes

Companion to `README.md`. That file is accurate and complete — this file just
adds the exact commands to go from clone to a running local database, plus a
list of known issues to be aware of while you work (see bottom).

## Setup steps

1. **Clone the repo, then copy the env file:**
   ```bash
   cp .env.example .env
   ```
   The defaults in `.env.example` (`silverlog` / `changeme`) are fine for
   local dev — you don't need to change anything unless you want your own
   values. See **Known Issues** below before you connect the backend to this
   database, though.

2. **Install dbmate** (if you don't have it):
   ```bash
   brew install dbmate
   ```

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
