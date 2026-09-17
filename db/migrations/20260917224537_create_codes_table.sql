-- migrate:up

CREATE TABLE codes (
    code_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    wem_code TEXT NOT NULL UNIQUE,
    wem_description TEXT NOT NULL
);

-- migrate:down

DROP TABLE codes;
