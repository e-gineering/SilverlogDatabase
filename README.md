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

Replace the angle-bracket placeholders below with the values from your `.env` file.

```text
Host=localhost;Port=<POSTGRES_PORT>;Database=<POSTGRES_DB>;Username=<POSTGRES_USER>;Password=<POSTGRES_PASSWORD>
```

Template configuration example:

If your .NET backend runs in Docker on the same Compose network, use `Host=postgres` and port `5432`.

Replace the `__POSTGRES_*__` tokens with the same values from your `.env` file.

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Port=__POSTGRES_PORT__;Database=__POSTGRES_DB__;Username=__POSTGRES_USER__;Password=__POSTGRES_PASSWORD__"
  }
}
```

This setup is compatible with `Npgsql` and `Npgsql.EntityFrameworkCore.PostgreSQL`.
