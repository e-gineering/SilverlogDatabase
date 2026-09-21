-- migrate:up

ALTER TABLE users DROP CONSTRAINT users_email_key;
CREATE UNIQUE INDEX users_email_unique_idx ON users (lower(email));

-- migrate:down

DROP INDEX users_email_unique_idx;
ALTER TABLE users ADD CONSTRAINT users_email_key UNIQUE (email);
