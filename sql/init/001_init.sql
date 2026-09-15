CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE SCHEMA IF NOT EXISTS app;

CREATE TABLE IF NOT EXISTS app.logs (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    level varchar(20) NOT NULL DEFAULT 'Information',
    message text NOT NULL,
    created_utc timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_logs_created_utc
    ON app.logs (created_utc DESC);
