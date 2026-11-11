-- DEMO ONLY: run against the isolated campus_connect_preview database.
-- Every inserted record is marked isDemo=true and is safe to remove by that flag.
USE campus_connect_preview;

SET @preview_owner = (
    SELECT id
    FROM users
    WHERE JSON_UNQUOTE(JSON_EXTRACT(payload, '$.email'))
        = 'preview.64526e30e8434dd48e5d9cb07199871f@example.edu'
    LIMIT 1
);
SET @preview_owner_oid = IF(@preview_owner IS NULL, NULL, JSON_OBJECT('$oid', @preview_owner));
SET @sample_date = DATE_FORMAT(UTC_TIMESTAMP(), '%Y-%m-%dT%H:%i:%s.000Z');

INSERT INTO notes (id, payload) VALUES
('d00000000000000000000001', JSON_OBJECT(
    '_id', JSON_OBJECT('$oid', 'd00000000000000000000001'),
    'ownerId', @preview_owner_oid, 'authorId', @preview_owner_oid,
    'title', 'A visual guide to data structures',
    'description', 'A concise, illustrated revision guide covering trees, graphs, queues, and the trade-offs behind common data structures.',
    'subject', 'Data Structures', 'category', 'Computer Science',
    'resourceType', 'GUIDE', 'resourceUrl', 'https://www.geeksforgeeks.org/data-structures/',
    'tags', JSON_ARRAY('revision', 'computer science', 'visual guide'),
    'status', 'ACTIVE', 'isDemo', TRUE, 'createdAt', @sample_date
)),
('d00000000000000000000002', JSON_OBJECT(
    '_id', JSON_OBJECT('$oid', 'd00000000000000000000002'),
    'ownerId', @preview_owner_oid, 'authorId', @preview_owner_oid,
    'title', 'Database systems: joins & indexing',
    'description', 'Class notes on reading query plans, choosing indexes, and understanding relational joins.',
    'subject', 'Database Systems', 'category', 'Study notes',
    'resourceType', 'NOTES', 'resourceUrl', 'https://dev.mysql.com/doc/',
    'tags', JSON_ARRAY('SQL', 'databases', 'study group'),
    'status', 'ACTIVE', 'isDemo', TRUE, 'createdAt', @sample_date
)),
('d00000000000000000000003', JSON_OBJECT(
    '_id', JSON_OBJECT('$oid', 'd00000000000000000000003'),
    'ownerId', @preview_owner_oid, 'authorId', @preview_owner_oid,
    'title', 'Preparing for your first project showcase',
    'description', 'A practical checklist for explaining a technical project clearly, from problem statement to demo.',
    'subject', 'Project Skills', 'category', 'Career skills',
    'resourceType', 'GUIDE', 'resourceUrl', 'https://github.com/readme/guides',
    'tags', JSON_ARRAY('projects', 'presentation', 'portfolio'),
    'status', 'ACTIVE', 'isDemo', TRUE, 'createdAt', @sample_date
))
ON DUPLICATE KEY UPDATE payload = VALUES(payload);

INSERT INTO questions (id, payload) VALUES
('d10000000000000000000001', JSON_OBJECT(
    '_id', JSON_OBJECT('$oid', 'd10000000000000000000001'),
    'ownerId', @preview_owner_oid, 'authorId', @preview_owner_oid,
    'title', 'When should I choose an index over a table scan?',
    'description', 'I understand the basic idea of indexes, but I am unsure how table size and query selectivity change the decision. What practical signs do you look for?',
    'category', 'Database Systems', 'tags', JSON_ARRAY('databases', 'SQL', 'indexes'),
    'status', 'OPEN', 'isDemo', TRUE, 'createdAt', @sample_date
)),
('d10000000000000000000002', JSON_OBJECT(
    '_id', JSON_OBJECT('$oid', 'd10000000000000000000002'),
    'ownerId', @preview_owner_oid, 'authorId', @preview_owner_oid,
    'title', 'How do you divide work on a small team project?',
    'description', 'Looking for a fair way to split design, implementation, and testing while keeping everyone in sync.',
    'category', 'Project Collaboration', 'tags', JSON_ARRAY('teamwork', 'projects', 'planning'),
    'status', 'OPEN', 'isDemo', TRUE, 'createdAt', @sample_date
)),
('d10000000000000000000003', JSON_OBJECT(
    '_id', JSON_OBJECT('$oid', 'd10000000000000000000003'),
    'ownerId', @preview_owner_oid, 'authorId', @preview_owner_oid,
    'title', 'What helped recursion finally click for you?',
    'description', 'A visual explanation or small practice exercise would help me connect the call stack to the base case.',
    'category', 'Programming', 'tags', JSON_ARRAY('Java', 'recursion', 'peer learning'),
    'status', 'OPEN', 'isDemo', TRUE, 'createdAt', @sample_date
))
ON DUPLICATE KEY UPDATE payload = VALUES(payload);

INSERT INTO projects (id, payload) VALUES
('d20000000000000000000001', JSON_OBJECT(
    '_id', JSON_OBJECT('$oid', 'd20000000000000000000001'),
    'ownerId', @preview_owner_oid, 'authorId', @preview_owner_oid,
    'title', 'Campus accessibility map',
    'description', 'Build a student-maintained map of step-free routes, accessible entrances, and quiet study areas.',
    'category', 'Civic technology', 'skills', 'Java, mapping, user research',
    'tags', JSON_ARRAY('accessibility', 'campus', 'mapping'),
    'memberCount', 3, 'status', 'OPEN', 'isDemo', TRUE, 'createdAt', @sample_date
)),
('d20000000000000000000002', JSON_OBJECT(
    '_id', JSON_OBJECT('$oid', 'd20000000000000000000002'),
    'ownerId', @preview_owner_oid, 'authorId', @preview_owner_oid,
    'title', 'Study room availability board',
    'description', 'Explore a small, privacy-friendly way to share quiet rooms and study spaces across campus.',
    'category', 'Student tools', 'skills', 'UI design, Java, research',
    'tags', JSON_ARRAY('study', 'design', 'campus tools'),
    'memberCount', 2, 'status', 'OPEN', 'isDemo', TRUE, 'createdAt', @sample_date
))
ON DUPLICATE KEY UPDATE payload = VALUES(payload);

INSERT INTO products (id, payload) VALUES
('d30000000000000000000001', JSON_OBJECT(
    '_id', JSON_OBJECT('$oid', 'd30000000000000000000001'),
    'ownerId', @preview_owner_oid, 'sellerId', @preview_owner_oid, 'authorId', @preview_owner_oid,
    'name', 'Calculus: Early Transcendentals',
    'description', 'Gently used edition, clean pages, and a few pencil annotations. A useful find for a student taking first-year calculus.',
    'category', 'Textbooks', 'condition', 'VERY_GOOD', 'price', 450,
    'imageUrl', '/campus-connect/assets/images/study-resources.jpg',
    'status', 'ACTIVE', 'sold', FALSE, 'isDemo', TRUE, 'createdAt', @sample_date
)),
('d30000000000000000000002', JSON_OBJECT(
    '_id', JSON_OBJECT('$oid', 'd30000000000000000000002'),
    'ownerId', @preview_owner_oid, 'sellerId', @preview_owner_oid, 'authorId', @preview_owner_oid,
    'name', 'Scientific calculator',
    'description', 'A dependable, pre-owned scientific calculator in good condition.',
    'category', 'Electronics', 'condition', 'GOOD', 'price', 650,
    'imageUrl', '/campus-connect/assets/images/campus-community.jpg',
    'status', 'ACTIVE', 'sold', FALSE, 'isDemo', TRUE, 'createdAt', @sample_date
)),
('d30000000000000000000003', JSON_OBJECT(
    '_id', JSON_OBJECT('$oid', 'd30000000000000000000003'),
    'ownerId', @preview_owner_oid, 'sellerId', @preview_owner, 'authorId', @preview_owner_oid,
    'name', 'Engineering drawing set',
    'description', 'A complete drawing kit ready for its next studio session.',
    'category', 'Supplies', 'condition', 'GOOD', 'price', 300,
    'imageUrl', '/campus-connect/assets/images/campus-classroom.jpg',
    'status', 'ACTIVE', 'sold', FALSE, 'isDemo', TRUE, 'createdAt', @sample_date
))
ON DUPLICATE KEY UPDATE payload = VALUES(payload);

INSERT INTO campus_events (id, payload) VALUES
('d40000000000000000000001', JSON_OBJECT(
    '_id', JSON_OBJECT('$oid', 'd40000000000000000000001'),
    'ownerId', @preview_owner_oid, 'authorId', @preview_owner_oid,
    'title', 'Design & build: student project showcase',
    'description', 'An informal afternoon to share works in progress, meet collaborators, and exchange feedback.',
    'category', 'Showcase', 'eventType', 'EVENT',
    'location', 'Innovation studio', 'date', 'Friday · 3:30 PM',
    'startsAt', @sample_date, 'isDemo', TRUE, 'createdAt', @sample_date
)),
('d40000000000000000000002', JSON_OBJECT(
    '_id', JSON_OBJECT('$oid', 'd40000000000000000000002'),
    'ownerId', @preview_owner_oid, 'authorId', @preview_owner_oid,
    'title', 'Peer-led database revision circle',
    'description', 'Bring a question and work through SQL and database concepts with classmates.',
    'category', 'Study circle', 'eventType', 'EVENT',
    'location', 'Library · Collaboration room 2', 'date', 'Saturday · 11:00 AM',
    'startsAt', @sample_date, 'isDemo', TRUE, 'createdAt', @sample_date
)),
('d40000000000000000000003', JSON_OBJECT(
    '_id', JSON_OBJECT('$oid', 'd40000000000000000000003'),
    'ownerId', @preview_owner_oid, 'authorId', @preview_owner_oid,
    'title', 'Library extended-hours update',
    'description', 'The second-floor group study rooms are open later this week during project reviews.',
    'category', 'Campus notice', 'eventType', 'NOTICE',
    'location', 'Main library', 'date', 'This week',
    'startsAt', @sample_date, 'isDemo', TRUE, 'createdAt', @sample_date
))
ON DUPLICATE KEY UPDATE payload = VALUES(payload);

INSERT INTO activity (id, payload) VALUES
('d50000000000000000000001', JSON_OBJECT(
    '_id', JSON_OBJECT('$oid', 'd50000000000000000000001'),
    'actorId', @preview_owner_oid, 'actorName', 'Campus community',
    'action', 'SHARED', 'module', 'notes',
    'title', 'A visual guide to data structures',
    'description', 'A revision guide has been added to the shared campus library.',
    'isDemo', TRUE, 'createdAt', @sample_date
)),
('d50000000000000000000002', JSON_OBJECT(
    '_id', JSON_OBJECT('$oid', 'd50000000000000000000002'),
    'actorId', @preview_owner_oid, 'actorName', 'Campus community',
    'action', 'OPENED', 'module', 'projects',
    'title', 'Campus accessibility map',
    'description', 'A campus mapping project is welcoming collaborators.',
    'isDemo', TRUE, 'createdAt', @sample_date
)),
('d50000000000000000000003', JSON_OBJECT(
    '_id', JSON_OBJECT('$oid', 'd50000000000000000000003'),
    'actorId', @preview_owner_oid, 'actorName', 'Campus community',
    'action', 'ASKED', 'module', 'questions',
    'title', 'What helped recursion finally click for you?',
    'description', 'A student is looking for a visual explanation of recursion.',
    'isDemo', TRUE, 'createdAt', @sample_date
))
ON DUPLICATE KEY UPDATE payload = VALUES(payload);

INSERT INTO assignments (id, payload) VALUES
('d60000000000000000000001', JSON_OBJECT(
    '_id', JSON_OBJECT('$oid', 'd60000000000000000000001'),
    'ownerId', @preview_owner_oid, 'authorId', @preview_owner_oid,
    'title', 'Peer study: introductory Java',
    'description', 'Looking for a classmate to work through methods, arrays, and debugging basics together.',
    'category', 'Programming', 'skills', 'Java, debugging, beginner friendly',
    'deadline', DATE_FORMAT(DATE_ADD(UTC_DATE(), INTERVAL 14 DAY), '%Y-%m-%d'),
    'supportMode', 'PEER_EXCHANGE', 'status', 'OPEN',
    'isDemo', TRUE, 'createdAt', @sample_date
)),
('d60000000000000000000002', JSON_OBJECT(
    '_id', JSON_OBJECT('$oid', 'd60000000000000000000002'),
    'ownerId', @preview_owner_oid, 'authorId', @preview_owner_oid,
    'title', 'Peer review: project presentations',
    'description', 'Swap a practice run with another student and share constructive presentation feedback.',
    'category', 'Communication', 'skills', 'Presentations, feedback',
    'deadline', DATE_FORMAT(DATE_ADD(UTC_DATE(), INTERVAL 21 DAY), '%Y-%m-%d'),
    'supportMode', 'PEER_EXCHANGE', 'status', 'OPEN',
    'isDemo', TRUE, 'createdAt', @sample_date
))
ON DUPLICATE KEY UPDATE payload = VALUES(payload);
