-- Test/dev seed data. Safe to re-run: truncates and reloads every time.
-- Names, emails, and codes are deliberately obvious placeholders so this
-- data is never mistaken for something real.

TRUNCATE TABLE activities, entries, codes, users RESTART IDENTITY CASCADE;

INSERT INTO users (email, name, role) VALUES
    ('test.admin@example.test', 'Test Admin', 'admin'),
    ('test.user1@example.test', 'Test User One', 'user'),
    ('test.user2@example.test', 'Test User Two', 'user');

INSERT INTO codes (wem_code, wem_description) VALUES
    ('TEST-CODE-A', 'Test code A - seed description'),
    ('TEST-CODE-B', 'Test code B - seed description');

INSERT INTO entries (user_id, entry_text) VALUES
    ((SELECT user_id FROM users WHERE email = 'test.user1@example.test'), 'Test entry text - seed entry #1'),
    ((SELECT user_id FROM users WHERE email = 'test.user1@example.test'), 'Test entry text - seed entry #2'),
    ((SELECT user_id FROM users WHERE email = 'test.user2@example.test'), 'Test entry text - seed entry #3');

INSERT INTO activities (entry_id, code_id) VALUES
    ((SELECT entry_id FROM entries WHERE entry_text = 'Test entry text - seed entry #1'), (SELECT code_id FROM codes WHERE wem_code = 'TEST-CODE-A')),
    ((SELECT entry_id FROM entries WHERE entry_text = 'Test entry text - seed entry #2'), (SELECT code_id FROM codes WHERE wem_code = 'TEST-CODE-B')),
    ((SELECT entry_id FROM entries WHERE entry_text = 'Test entry text - seed entry #3'), (SELECT code_id FROM codes WHERE wem_code = 'TEST-CODE-A'));
