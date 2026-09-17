-- migrate:up

CREATE TABLE entries (
    entry_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users (user_id) ON DELETE CASCADE,
    entry_text TEXT NOT NULL,
    entry_date TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- migrate:down

DROP TABLE entries;
