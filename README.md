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

3. The database will be available on `localhost:5432` by default (or the value of `POSTGRES_PORT` from `.env`) and the init script will create:
   - schema: `app`
   - table: `app.logs`

## .NET connection string

Use this connection string from your .NET backend:

```text
Host=localhost;Port=<POSTGRES_PORT>;Database=<POSTGRES_DB>;Username=<POSTGRES_USER>;Password=<POSTGRES_PASSWORD>
```

Example configuration:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Port=<POSTGRES_PORT>;Database=<POSTGRES_DB>;Username=<POSTGRES_USER>;Password=<POSTGRES_PASSWORD>"
  }
}
```

This setup is compatible with `Npgsql` and `Npgsql.EntityFrameworkCore.PostgreSQL`.
