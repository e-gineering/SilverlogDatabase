-- migrate:up

CREATE TYPE user_role AS ENUM ('admin', 'user');

CREATE TABLE users (
    user_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    role user_role NOT NULL DEFAULT 'user'
);

-- migrate:down

DROP TABLE users;
DROP TYPE user_role;
