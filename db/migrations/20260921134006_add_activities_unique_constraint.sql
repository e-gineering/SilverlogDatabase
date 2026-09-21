-- migrate:up

ALTER TABLE activities ADD CONSTRAINT activities_entry_id_code_id_key UNIQUE (entry_id, code_id);

-- migrate:down

ALTER TABLE activities DROP CONSTRAINT activities_entry_id_code_id_key;
