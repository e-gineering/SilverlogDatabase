-- migrate:up

ALTER TYPE user_role RENAME VALUE 'user' TO 'student';
ALTER TABLE users ALTER COLUMN role SET DEFAULT 'student';

-- migrate:down

ALTER TABLE users ALTER COLUMN role SET DEFAULT 'user';
ALTER TYPE user_role RENAME VALUE 'student' TO 'user';
