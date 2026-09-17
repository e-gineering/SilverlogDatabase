-- migrate:up

CREATE TABLE activities (
    activity_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    entry_id BIGINT NOT NULL REFERENCES entries (entry_id) ON DELETE CASCADE,
    code_id BIGINT NOT NULL REFERENCES codes (code_id) ON DELETE RESTRICT
);

-- migrate:down

DROP TABLE activities;
