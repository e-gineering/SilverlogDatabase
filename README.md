# SilverlogDatabase

Basic PostgreSQL template for Silverlog that can be used by a .NET backend.

## Included

- `docker-compose.yml` to run PostgreSQL locally
- `.env.example` for local configuration
- `sql/init/001_init.sql` for initial schema creation

## Local setup

1. Copy the example environment file:

   ```bash
   cp .env.example .env
   ```

   Then update `POSTGRES_PASSWORD` in `.env` to a local password of your choice before starting the database.

2. Start PostgreSQL:

   ```bash
   docker compose up -d
   ```

3. The database will be available on `localhost:5432` by default (or the value of `POSTGRES_PORT` from `.env`) for applications running on your machine. Applications running in Docker on the same Compose network should use `Host=postgres` instead.

   The init script will create:
   - schema: `app`
   - table: `app.logs`

## .NET connection string

Use this connection string from your .NET backend when the backend runs on your machine:

Replace the remaining angle-bracket placeholders below with the values from your `.env` file.
If you change `POSTGRES_PORT` in `.env`, update the `Port=` value to match.

```text
Host=localhost;Port=5432;Database=<POSTGRES_DB>;Username=<POSTGRES_USER>;Password=<POSTGRES_PASSWORD>
```

Containerized backend configuration example:

If your .NET backend runs in Docker on the same Compose network, use `Host=postgres` and port `5432`.

Configure your backend with a connection string that uses the same database name, username, and password values that PostgreSQL was started with.

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=postgres;Port=5432;Database=__POSTGRES_DB__;Username=__POSTGRES_USER__;Password=__POSTGRES_PASSWORD__"
  }
}
```

This setup is compatible with `Npgsql` and `Npgsql.EntityFrameworkCore.PostgreSQL`.
