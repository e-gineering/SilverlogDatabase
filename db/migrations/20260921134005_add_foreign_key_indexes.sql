-- migrate:up

CREATE INDEX entries_user_id_idx ON entries (user_id);
CREATE INDEX activities_code_id_idx ON activities (code_id);

-- migrate:down

DROP INDEX entries_user_id_idx;
DROP INDEX activities_code_id_idx;
