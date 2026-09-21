-- Test/dev seed data. Safe to re-run: truncates and reloads every time.
-- Names, emails, and codes are deliberately obvious placeholders so this
-- data is never mistaken for something real.

TRUNCATE TABLE activities, entries, codes, users RESTART IDENTITY CASCADE;

WITH new_users AS (
    INSERT INTO users (email, name, role) VALUES
        ('test.admin@example.test', 'Test Admin', 'admin'),
        ('test.user1@example.test', 'Test User One', 'user'),
        ('test.user2@example.test', 'Test User Two', 'user')
    RETURNING user_id, email
),
new_codes AS (
    INSERT INTO codes (wem_code, wem_description) VALUES
        ('TEST-CODE-A', 'Test code A - seed description'),
        ('TEST-CODE-B', 'Test code B - seed description')
    RETURNING code_id, wem_code
),
new_entries AS (
    INSERT INTO entries (user_id, entry_text)
    SELECT new_users.user_id, t.entry_text
    FROM (VALUES
        ('test.user1@example.test', 'Test entry text - seed entry #1'),
        ('test.user1@example.test', 'Test entry text - seed entry #2'),
        ('test.user2@example.test', 'Test entry text - seed entry #3')
    ) AS t (email, entry_text)
    JOIN new_users USING (email)
    RETURNING entry_id, entry_text
)
INSERT INTO activities (entry_id, code_id)
SELECT new_entries.entry_id, new_codes.code_id
FROM (VALUES
    ('Test entry text - seed entry #1', 'TEST-CODE-A'),
    ('Test entry text - seed entry #2', 'TEST-CODE-B'),
    ('Test entry text - seed entry #3', 'TEST-CODE-A')
) AS t (entry_text, wem_code)
JOIN new_entries USING (entry_text)
JOIN new_codes USING (wem_code);
