-- ============================================================
--  SMART MENTORING PLATFORM — Developer Seed Data
--  Run AFTER mentoring_platform_schema.sql
--
--  Covers all 28 tables with realistic, interconnected data.
--  All passwords are: Password@123
--  Hash below is bcrypt cost-12 of that string.
--
--  Cast of characters (22 users):
--    1  Counselling Head
--    2  Professional Counsellors
--    2  Committee Mentors
--    3  Postgraduate Mentors
--    3  Senior UG Mentors (3rd/4th year)
--    4  Junior UG Mentors (2nd year)
--    7  Mentees (1st year)
--
--  Scenarios exercised:
--    • Full onboarding flow (all stages present)
--    • ML prediction → committee approval → group assignment
--    • Manual mentor override by committee
--    • Public issue: open → in_discussion → resolved → closed
--    • Private issue: open → assigned → resolved
--    • Ultra-private issue: open → needs_escalation (active)
--    • Public issue with threaded comments
--    • Mentor ratings + stats refresh
--    • Audit log entries for sensitive actions
--    • Mix of read/unread notifications
-- ============================================================

BEGIN;

-- ============================================================
-- SECTION 1: REFERENCE / LOOKUP DATA
-- ============================================================

-- Interest tags
INSERT INTO interest_tags (id, name, category) VALUES
    (1,  'Data Structures & Algorithms', 'academic'),
    (2,  'Machine Learning',             'academic'),
    (3,  'Web Development',              'academic'),
    (4,  'VLSI & Embedded Systems',      'academic'),
    (5,  'Thermodynamics',               'academic'),
    (6,  'Research & Publications',      'career'),
    (7,  'Internship Guidance',          'career'),
    (8,  'Higher Studies Abroad',        'career'),
    (9,  'Competitive Exams (GATE/GRE)', 'career'),
    (10, 'Placement Preparation',        'career'),
    (11, 'Stress & Anxiety Management',  'personal'),
    (12, 'Time Management',              'personal'),
    (13, 'Homesickness & Adjustment',    'personal'),
    (14, 'Peer Relationships',           'personal'),
    (15, 'Financial Concerns',           'personal'),
    (16, 'Open Source Contributions',    'academic'),
    (17, 'Entrepreneurship',             'career'),
    (18, 'Mental Health Awareness',      'personal');
SELECT setval('interest_tags_id_seq', 18);

-- Languages
INSERT INTO languages (id, code, name) VALUES
    (1, 'en', 'English'),
    (2, 'hi', 'Hindi'),
    (3, 'mr', 'Marathi'),
    (4, 'ta', 'Tamil'),
    (5, 'te', 'Telugu'),
    (6, 'kn', 'Kannada'),
    (7, 'ml', 'Malayalam'),
    (8, 'gu', 'Gujarati'),
    (9, 'bn', 'Bengali');
SELECT setval('languages_id_seq', 9);

-- Issue categories
INSERT INTO issue_categories (id, name, description, default_visibility, requires_escalation) VALUES
    (1, 'Academic',       'Coursework, backlogs, exam prep, lab difficulties',          'public',        FALSE),
    (2, 'Career',         'Internships, placements, higher studies, skill-building',    'public',        FALSE),
    (3, 'Personal',       'Homesickness, peer conflict, social adjustment',             'private',       FALSE),
    (4, 'Mental Health',  'Stress, anxiety, depression, burnout, crisis situations',   'ultra_private', TRUE),
    (5, 'Administrative', 'Hostel, fees, scholarships, grievances',                    'public',        FALSE),
    (6, 'Ragging / Harassment', 'Bullying, discrimination, misconduct reports',        'ultra_private', TRUE);
SELECT setval('issue_categories_id_seq', 6);

-- Issue labels
INSERT INTO issue_labels (id, name, color) VALUES
    (1,  'urgent',          '#E24B4A'),
    (2,  'first-year',      '#378ADD'),
    (3,  'exam-stress',     '#BA7517'),
    (4,  'placement',       '#1D9E75'),
    (5,  'backlog',         '#D4537E'),
    (6,  'good-first-issue','#639922'),
    (7,  'needs-resources', '#534AB7'),
    (8,  'escalated',       '#993C1D'),
    (9,  'resolved',        '#0F6E56'),
    (10, 'mental-health',   '#A32D2D');
SELECT setval('issue_labels_id_seq', 10);

-- ============================================================
-- SECTION 2: USERS
-- All passwords = Password@123
-- Hash: $2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/KeSpb2n8WqBNnLcFW
-- ============================================================

-- Shorthand: static dev hash for all users
DO $$ BEGIN
    PERFORM set_config('app.dev_pw_hash',
        '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/KeSpb2n8WqBNnLcFW',
        TRUE);
END $$;

INSERT INTO users (id, email, password_hash, is_email_verified, status, onboarding_status, last_login_at, created_at) VALUES
-- ── Counselling Head ──────────────────────────────────────────────────────────
('a1000001-0000-0000-0000-000000000001',
 'meera.iyer@college.edu',
 '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/KeSpb2n8WqBNnLcFW',
 TRUE, 'active', 'verified',
 NOW() - INTERVAL '2 hours',
 NOW() - INTERVAL '180 days'),

-- ── Professional Counsellors ──────────────────────────────────────────────────
('a2000001-0000-0000-0000-000000000001',
 'rahul.sharma@college.edu',
 '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/KeSpb2n8WqBNnLcFW',
 TRUE, 'active', 'verified',
 NOW() - INTERVAL '1 day',
 NOW() - INTERVAL '160 days'),
('a2000002-0000-0000-0000-000000000001',
 'priya.nair@college.edu',
 '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/KeSpb2n8WqBNnLcFW',
 TRUE, 'active', 'verified',
 NOW() - INTERVAL '3 hours',
 NOW() - INTERVAL '155 days'),

-- ── Committee Mentors ─────────────────────────────────────────────────────────
('a3000001-0000-0000-0000-000000000001',
 'arjun.menon@college.edu',
 '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/KeSpb2n8WqBNnLcFW',
 TRUE, 'active', 'verified',
 NOW() - INTERVAL '5 hours',
 NOW() - INTERVAL '400 days'),
('a3000002-0000-0000-0000-000000000001',
 'sneha.kulkarni@college.edu',
 '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/KeSpb2n8WqBNnLcFW',
 TRUE, 'active', 'verified',
 NOW() - INTERVAL '12 hours',
 NOW() - INTERVAL '390 days'),

-- ── Postgraduate Mentors ──────────────────────────────────────────────────────
('a4000001-0000-0000-0000-000000000001',
 'vikram.patel@college.edu',
 '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/KeSpb2n8WqBNnLcFW',
 TRUE, 'active', 'verified',
 NOW() - INTERVAL '6 hours',
 NOW() - INTERVAL '300 days'),
('a4000002-0000-0000-0000-000000000001',
 'divya.rao@college.edu',
 '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/KeSpb2n8WqBNnLcFW',
 TRUE, 'active', 'verified',
 NOW() - INTERVAL '2 days',
 NOW() - INTERVAL '290 days'),
('a4000003-0000-0000-0000-000000000001',
 'rohit.joshi@college.edu',
 '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/KeSpb2n8WqBNnLcFW',
 TRUE, 'active', 'verified',
 NOW() - INTERVAL '1 day',
 NOW() - INTERVAL '280 days'),

-- ── Senior UG Mentors (3rd / 4th year) ───────────────────────────────────────
('a5000001-0000-0000-0000-000000000001',
 'ananya.singh@college.edu',
 '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/KeSpb2n8WqBNnLcFW',
 TRUE, 'active', 'verified',
 NOW() - INTERVAL '4 hours',
 NOW() - INTERVAL '500 days'),
('a5000002-0000-0000-0000-000000000001',
 'karan.mehta@college.edu',
 '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/KeSpb2n8WqBNnLcFW',
 TRUE, 'active', 'verified',
 NOW() - INTERVAL '8 hours',
 NOW() - INTERVAL '510 days'),
('a5000003-0000-0000-0000-000000000001',
 'pooja.desai@college.edu',
 '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/KeSpb2n8WqBNnLcFW',
 TRUE, 'active', 'verified',
 NOW() - INTERVAL '1 day',
 NOW() - INTERVAL '480 days'),

-- ── Junior UG Mentors (2nd year) ──────────────────────────────────────────────
('a6000001-0000-0000-0000-000000000001',
 'nikhil.verma@college.edu',
 '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/KeSpb2n8WqBNnLcFW',
 TRUE, 'active', 'verified',
 NOW() - INTERVAL '3 hours',
 NOW() - INTERVAL '250 days'),
('a6000002-0000-0000-0000-000000000001',
 'tanvi.shah@college.edu',
 '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/KeSpb2n8WqBNnLcFW',
 TRUE, 'active', 'verified',
 NOW() - INTERVAL '7 hours',
 NOW() - INTERVAL '240 days'),
('a6000003-0000-0000-0000-000000000001',
 'aditya.kumar@college.edu',
 '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/KeSpb2n8WqBNnLcFW',
 TRUE, 'active', 'verified',
 NOW() - INTERVAL '10 hours',
 NOW() - INTERVAL '245 days'),
('a6000004-0000-0000-0000-000000000001',
 'riya.bose@college.edu',
 '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/KeSpb2n8WqBNnLcFW',
 TRUE, 'active', 'verified',
 NOW() - INTERVAL '2 days',
 NOW() - INTERVAL '230 days'),

-- ── Mentees (1st year) ────────────────────────────────────────────────────────
('a7000001-0000-0000-0000-000000000001',
 'ishaan.gupta@college.edu',
 '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/KeSpb2n8WqBNnLcFW',
 TRUE, 'active', 'matched',
 NOW() - INTERVAL '1 hour',
 NOW() - INTERVAL '45 days'),
('a7000002-0000-0000-0000-000000000001',
 'shreya.pillai@college.edu',
 '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/KeSpb2n8WqBNnLcFW',
 TRUE, 'active', 'matched',
 NOW() - INTERVAL '4 hours',
 NOW() - INTERVAL '42 days'),
('a7000003-0000-0000-0000-000000000001',
 'dev.malhotra@college.edu',
 '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/KeSpb2n8WqBNnLcFW',
 TRUE, 'active', 'matched',
 NOW() - INTERVAL '2 hours',
 NOW() - INTERVAL '40 days'),
('a7000004-0000-0000-0000-000000000001',
 'aisha.khan@college.edu',
 '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/KeSpb2n8WqBNnLcFW',
 TRUE, 'active', 'matched',
 NOW() - INTERVAL '6 hours',
 NOW() - INTERVAL '38 days'),
('a7000005-0000-0000-0000-000000000001',
 'rohan.tiwari@college.edu',
 '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/KeSpb2n8WqBNnLcFW',
 TRUE, 'active', 'profile_complete',   -- pending match
 NOW() - INTERVAL '1 day',
 NOW() - INTERVAL '35 days'),
('a7000006-0000-0000-0000-000000000001',
 'pritha.banerjee@college.edu',
 '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/KeSpb2n8WqBNnLcFW',
 TRUE, 'active', 'profile_complete',
 NOW() - INTERVAL '2 days',
 NOW() - INTERVAL '30 days'),
('a7000007-0000-0000-0000-000000000001',
 'mihir.jain@college.edu',
 '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/KeSpb2n8WqBNnLcFW',
 FALSE, 'pending_verification', 'role_selected',  -- freshly signed up
 NULL,
 NOW() - INTERVAL '2 hours');

-- ============================================================
-- SECTION 3: USER ROLES
-- ============================================================

-- Head verified by itself (bootstrap)
INSERT INTO user_roles (user_id, role_id, assigned_by, is_active, verified_at, verified_by) VALUES
('a1000001-0000-0000-0000-000000000001', 7, NULL, TRUE, NOW() - INTERVAL '180 days', 'a1000001-0000-0000-0000-000000000001');

-- Professional counsellors verified by head
INSERT INTO user_roles (user_id, role_id, assigned_by, is_active, verified_at, verified_by) VALUES
('a2000001-0000-0000-0000-000000000001', 6, 'a1000001-0000-0000-0000-000000000001', TRUE, NOW() - INTERVAL '158 days', 'a1000001-0000-0000-0000-000000000001'),
('a2000002-0000-0000-0000-000000000001', 6, 'a1000001-0000-0000-0000-000000000001', TRUE, NOW() - INTERVAL '153 days', 'a1000001-0000-0000-0000-000000000001');

-- Committee mentors verified by head
INSERT INTO user_roles (user_id, role_id, assigned_by, is_active, verified_at, verified_by) VALUES
('a3000001-0000-0000-0000-000000000001', 5, 'a1000001-0000-0000-0000-000000000001', TRUE, NOW() - INTERVAL '398 days', 'a1000001-0000-0000-0000-000000000001'),
('a3000002-0000-0000-0000-000000000001', 5, 'a1000001-0000-0000-0000-000000000001', TRUE, NOW() - INTERVAL '388 days', 'a1000001-0000-0000-0000-000000000001');

-- PG mentors verified by committee
INSERT INTO user_roles (user_id, role_id, assigned_by, is_active, verified_at, verified_by) VALUES
('a4000001-0000-0000-0000-000000000001', 4, 'a3000001-0000-0000-0000-000000000001', TRUE, NOW() - INTERVAL '298 days', 'a3000001-0000-0000-0000-000000000001'),
('a4000002-0000-0000-0000-000000000001', 4, 'a3000001-0000-0000-0000-000000000001', TRUE, NOW() - INTERVAL '288 days', 'a3000001-0000-0000-0000-000000000001'),
('a4000003-0000-0000-0000-000000000001', 4, 'a3000002-0000-0000-0000-000000000001', TRUE, NOW() - INTERVAL '278 days', 'a3000002-0000-0000-0000-000000000001');

-- Senior UG mentors verified by committee
INSERT INTO user_roles (user_id, role_id, assigned_by, is_active, verified_at, verified_by) VALUES
('a5000001-0000-0000-0000-000000000001', 3, 'a3000001-0000-0000-0000-000000000001', TRUE, NOW() - INTERVAL '498 days', 'a3000001-0000-0000-0000-000000000001'),
('a5000002-0000-0000-0000-000000000001', 3, 'a3000001-0000-0000-0000-000000000001', TRUE, NOW() - INTERVAL '508 days', 'a3000001-0000-0000-0000-000000000001'),
('a5000003-0000-0000-0000-000000000001', 3, 'a3000002-0000-0000-0000-000000000001', TRUE, NOW() - INTERVAL '478 days', 'a3000002-0000-0000-0000-000000000001');

-- Junior UG mentors verified by committee
INSERT INTO user_roles (user_id, role_id, assigned_by, is_active, verified_at, verified_by) VALUES
('a6000001-0000-0000-0000-000000000001', 2, 'a3000001-0000-0000-0000-000000000001', TRUE, NOW() - INTERVAL '248 days', 'a3000001-0000-0000-0000-000000000001'),
('a6000002-0000-0000-0000-000000000001', 2, 'a3000002-0000-0000-0000-000000000001', TRUE, NOW() - INTERVAL '238 days', 'a3000002-0000-0000-0000-000000000001'),
('a6000003-0000-0000-0000-000000000001', 2, 'a3000001-0000-0000-0000-000000000001', TRUE, NOW() - INTERVAL '243 days', 'a3000001-0000-0000-0000-000000000001'),
('a6000004-0000-0000-0000-000000000001', 2, 'a3000002-0000-0000-0000-000000000001', TRUE, NOW() - INTERVAL '228 days', 'a3000002-0000-0000-0000-000000000001');

-- Mentees self-selected role
INSERT INTO user_roles (user_id, role_id, assigned_by, is_active, verified_at) VALUES
('a7000001-0000-0000-0000-000000000001', 1, NULL, TRUE, NOW() - INTERVAL '44 days'),
('a7000002-0000-0000-0000-000000000001', 1, NULL, TRUE, NOW() - INTERVAL '41 days'),
('a7000003-0000-0000-0000-000000000001', 1, NULL, TRUE, NOW() - INTERVAL '39 days'),
('a7000004-0000-0000-0000-000000000001', 1, NULL, TRUE, NOW() - INTERVAL '37 days'),
('a7000005-0000-0000-0000-000000000001', 1, NULL, TRUE, NOW() - INTERVAL '34 days'),
('a7000006-0000-0000-0000-000000000001', 1, NULL, TRUE, NOW() - INTERVAL '29 days'),
('a7000007-0000-0000-0000-000000000001', 1, NULL, FALSE, NULL);  -- not yet verified

-- ============================================================
-- SECTION 4: USER PROFILES (common fields)
-- ============================================================

INSERT INTO user_profiles (user_id, full_name, college_email, department, year_or_designation, short_bio, is_complete) VALUES
-- Head
('a1000001-0000-0000-0000-000000000001',
 'Dr. Meera Iyer', 'meera.iyer@college.edu',
 'Counselling & Student Wellness', 'Counselling Head',
 'PhD in Clinical Psychology. 15+ years of experience in student mental health, crisis intervention, and institutional counselling policy.', TRUE),

-- Professional counsellors
('a2000001-0000-0000-0000-000000000001',
 'Dr. Rahul Sharma', 'rahul.sharma@college.edu',
 'Counselling & Student Wellness', 'Professional Counsellor',
 'M.Phil Clinical Psychology, specialising in anxiety, academic pressure, and transition difficulties in young adults.', TRUE),
('a2000002-0000-0000-0000-000000000001',
 'Dr. Priya Nair', 'priya.nair@college.edu',
 'Counselling & Student Wellness', 'Professional Counsellor',
 'Certified CBT practitioner with 8 years of campus counselling experience. Focus areas: depression, self-harm prevention, identity concerns.', TRUE),

-- Committee mentors
('a3000001-0000-0000-0000-000000000001',
 'Arjun Menon', 'arjun.menon@college.edu',
 'Computer Science & Engineering', '4th Year B.Tech',
 'CSE final year. Passionate about peer mentoring and mental health destigmatisation. Placed at Flipkart. Happy to guide on careers and adjusting to college life.', TRUE),
('a3000002-0000-0000-0000-000000000001',
 'Sneha Kulkarni', 'sneha.kulkarni@college.edu',
 'Electronics & Communication Engineering', '3rd Year B.Tech',
 'ECE third year. Involved in the counselling committee since 2nd year. Areas: academic planning, hostel adjustment, women-in-tech support.', TRUE),

-- PG mentors
('a4000001-0000-0000-0000-000000000001',
 'Vikram Patel', 'vikram.patel@college.edu',
 'Computer Science & Engineering', 'M.Tech – Machine Learning',
 'M.Tech researcher in ML/NLP. Can guide on research methodology, GATE prep strategy, and transitioning from UG to PG life.', TRUE),
('a4000002-0000-0000-0000-000000000001',
 'Divya Rao', 'divya.rao@college.edu',
 'Electrical Engineering', 'PhD Scholar',
 'PhD in Power Systems. 3 published papers. Guide on research writing, conference participation, and balancing PhD pressure.', TRUE),
('a4000003-0000-0000-0000-000000000001',
 'Rohit Joshi', 'rohit.joshi@college.edu',
 'Mechanical Engineering', 'M.Tech – Thermal Engineering',
 'M.Tech with a background in PCM. Helps with engineering maths, thermodynamics, and first-year academic blues.', TRUE),

-- Senior UG mentors
('a5000001-0000-0000-0000-000000000001',
 'Ananya Singh', 'ananya.singh@college.edu',
 'Computer Science & Engineering', '3rd Year B.Tech',
 'CSE junior. Microsoft intern. Loves DSA, open source, and helping first years not panic about competitive programming.', TRUE),
('a5000002-0000-0000-0000-000000000001',
 'Karan Mehta', 'karan.mehta@college.edu',
 'Electronics & Communication Engineering', '4th Year B.Tech',
 'ECE senior with PCM background. Cleared GATE 2024 (AIR 340). Guides on academics, exam strategy, and higher studies.', TRUE),
('a5000003-0000-0000-0000-000000000001',
 'Pooja Desai', 'pooja.desai@college.edu',
 'Mechanical Engineering', '3rd Year B.Tech',
 'Mech junior. Diploma-to-B.Tech lateral entry. I know the extra pressure lateral entry students face — happy to help navigate it.', TRUE),

-- Junior UG mentors
('a6000001-0000-0000-0000-000000000001',
 'Nikhil Verma', 'nikhil.verma@college.edu',
 'Computer Science & Engineering', '2nd Year B.Tech',
 'CSE sophomore from PCM background. Cleared first year with 9.1 CGPA. Interested in web dev and helping batch-mates find their footing.', TRUE),
('a6000002-0000-0000-0000-000000000001',
 'Tanvi Shah', 'tanvi.shah@college.edu',
 'Civil Engineering', '2nd Year B.Tech',
 'Civil sophomore. Gujarati. Was very homesick in first year — now want to make the transition easier for others.', TRUE),
('a6000003-0000-0000-0000-000000000001',
 'Aditya Kumar', 'aditya.kumar@college.edu',
 'Computer Science & Engineering', '2nd Year B.Tech',
 'CSE sophomore with strong interest in competitive coding and hackathons. Can help with study habits and time management.', TRUE),
('a6000004-0000-0000-0000-000000000001',
 'Riya Bose', 'riya.bose@college.edu',
 'Electrical Engineering', '2nd Year B.Tech',
 'EE sophomore from PCB background. Made the PCB → engineering shift — understand how daunting physics/maths can be at first.', TRUE),

-- Mentees
('a7000001-0000-0000-0000-000000000001',
 'Ishaan Gupta', 'ishaan.gupta@college.edu',
 'Computer Science & Engineering', '1st Year B.Tech',
 'CSE fresher from Delhi. PCM background. Interested in ML and competitive programming but feeling overwhelmed by the pace.', TRUE),
('a7000002-0000-0000-0000-000000000001',
 'Shreya Pillai', 'shreya.pillai@college.edu',
 'Electronics & Communication Engineering', '1st Year B.Tech',
 'ECE fresher from Kerala. Malayalam-speaking. Adjusting to Hindi-heavy hostel environment. Interested in VLSI.', TRUE),
('a7000003-0000-0000-0000-000000000001',
 'Dev Malhotra', 'dev.malhotra@college.edu',
 'Mechanical Engineering', '1st Year B.Tech',
 'Mech fresher. Diploma background (Polytechnic, Chandigarh). Finding B.Tech pace very different from diploma.', TRUE),
('a7000004-0000-0000-0000-000000000001',
 'Aisha Khan', 'aisha.khan@college.edu',
 'Computer Science & Engineering', '1st Year B.Tech',
 'CSE fresher interested in web dev and design. Mild anxiety about fitting in with the coding-heavy culture.', TRUE),
('a7000005-0000-0000-0000-000000000001',
 'Rohan Tiwari', 'rohan.tiwari@college.edu',
 'Civil Engineering', '1st Year B.Tech',
 'Civil fresher. Struggling with engineering maths. Looking for study guidance and time management help.', TRUE),
('a7000006-0000-0000-0000-000000000001',
 'Pritha Banerjee', 'pritha.banerjee@college.edu',
 'Electrical Engineering', '1st Year B.Tech',
 'EE fresher from Kolkata. Bengali-speaking. PCB background — circuit theory is new and intimidating.', TRUE),
-- Mihir: profile incomplete (only bio filled partially, is_complete = FALSE)
('a7000007-0000-0000-0000-000000000001',
 'Mihir Jain', 'mihir.jain@college.edu',
 'Computer Science & Engineering', '1st Year B.Tech',
 NULL, FALSE);

-- ============================================================
-- SECTION 5: ROLE-SPECIFIC PROFILES
-- ============================================================

-- Professional / Head
INSERT INTO professional_profiles (user_id, qualification, years_of_experience, specialization_areas, is_emergency_available, can_escalate_to_external, escalation_permissions, license_number) VALUES
('a1000001-0000-0000-0000-000000000001',
 'PhD Clinical Psychology, RCI Registered',
 15, ARRAY['Crisis Intervention','Trauma Counselling','Institutional Policy'],
 TRUE, TRUE, ARRAY['external_referral','police_escalation','medical_referral'], 'RCI/2009/00421'),
('a2000001-0000-0000-0000-000000000001',
 'M.Phil Clinical Psychology, RCI Registered',
 8, ARRAY['Anxiety & Stress','Academic Counselling','CBT'],
 FALSE, FALSE, ARRAY['external_referral'], 'RCI/2016/00887'),
('a2000002-0000-0000-0000-000000000001',
 'M.Sc Psychology, PGDip CBT, RCI Registered',
 9, ARRAY['Depression','Self-Harm Prevention','Identity & Gender Counselling'],
 TRUE, FALSE, ARRAY['external_referral','medical_referral'], 'RCI/2015/01023');

-- UG/PG mentor profiles
INSERT INTO mentor_ug_pg_profiles (user_id, academic_background, mentoring_domains, past_experience_desc, max_mentees, current_mentees_count, is_accepting_mentees) VALUES
-- Committee mentors
('a3000001-0000-0000-0000-000000000001',
 'PCM', ARRAY['academics','career','mental_health','adjustment'],
 'Peer mentor for 1.5 years. Handled 12 mentees across two batches. Trained in active listening by the counselling committee.',
 5, 3, TRUE),
('a3000002-0000-0000-0000-000000000001',
 'PCM', ARRAY['academics','adjustment','women_in_stem','career'],
 'Joined the counselling committee in 2nd year. Volunteer at the campus womens cell. Comfortable with hostel adjustment issues.',
 4, 2, TRUE),
-- PG mentors
('a4000001-0000-0000-0000-000000000001',
 'PCM', ARRAY['academics','research','career','gate_prep'],
 'Was a peer mentor in UG (2 years). Guided 8 juniors on GATE preparation and MTech/PhD applications.',
 4, 2, TRUE),
('a4000002-0000-0000-0000-000000000001',
 'PCM', ARRAY['research','academics','mental_health'],
 'PhD mentor programme volunteer. Published researcher — can guide on journal submissions and research stress.',
 3, 1, TRUE),
('a4000003-0000-0000-0000-000000000001',
 'PCM', ARRAY['academics','adjustment','career'],
 'Diploma background (Polytechnic) before B.Tech and now M.Tech. Strong empathy for diploma lateral-entry students.',
 4, 2, TRUE),
-- Senior UG mentors
('a5000001-0000-0000-0000-000000000001',
 'PCM', ARRAY['academics','career','competitive_coding','open_source'],
 'Mentored 5 first-years last year informally. Helped 3 get their first OSS contributions.',
 5, 3, TRUE),
('a5000002-0000-0000-0000-000000000001',
 'PCM', ARRAY['academics','gate_prep','higher_studies','career'],
 'Cleared GATE 2024. Can share strategy, resources, and mindset for entrance exams alongside B.Tech.',
 4, 1, TRUE),
('a5000003-0000-0000-0000-000000000001',
 'Diploma', ARRAY['academics','adjustment','diploma_lateral_entry'],
 'Lateral entry from diploma. Understand the unique pressures of catching up with PCM batch-mates.',
 4, 2, TRUE),
-- Junior UG mentors
('a6000001-0000-0000-0000-000000000001',
 'PCM', ARRAY['academics','web_development','career','time_management'],
 'First year as a mentor. Enthusiastic. Was mentored myself and want to pay it forward.',
 4, 2, TRUE),
('a6000002-0000-0000-0000-000000000001',
 'PCM', ARRAY['adjustment','academics','homesickness'],
 'Overcame severe homesickness in first year. Want to help others feel at home faster.',
 3, 1, TRUE),
('a6000003-0000-0000-0000-000000000001',
 'PCM', ARRAY['academics','competitive_coding','time_management'],
 NULL,
 4, 2, TRUE),
('a6000004-0000-0000-0000-000000000001',
 'PCB', ARRAY['academics','adjustment','pcb_to_engineering'],
 'PCB background — know exactly how scary circuit theory and engineering maths are at first.',
 3, 1, FALSE);  -- currently at capacity

-- Mentee profiles
INSERT INTO mentee_profiles (user_id, academic_background, current_challenges, preferred_mentor_background, preferred_mentor_domain, communication_preference) VALUES
('a7000001-0000-0000-0000-000000000001',
 'PCM', ARRAY['keeping_up_with_pace','competitive_coding','time_management'],
 'PCM', ARRAY['academics','competitive_coding'], 'chat'),
('a7000002-0000-0000-0000-000000000001',
 'PCM', ARRAY['language_barrier','homesickness','vlsi_coursework'],
 'PCM', ARRAY['academics','adjustment'], 'both'),
('a7000003-0000-0000-0000-000000000001',
 'Diploma', ARRAY['different_pace_from_batch','engineering_maths','self_doubt'],
 'Diploma', ARRAY['academics','adjustment','diploma_lateral_entry'], 'call'),
('a7000004-0000-0000-0000-000000000001',
 'PCM', ARRAY['social_anxiety','imposter_syndrome','finding_interest'],
 'PCM', ARRAY['academics','career','adjustment'], 'chat'),
('a7000005-0000-0000-0000-000000000001',
 'PCM', ARRAY['engineering_maths','time_management','study_habits'],
 NULL, ARRAY['academics','time_management'], 'both'),
('a7000006-0000-0000-0000-000000000001',
 'PCB', ARRAY['pcb_to_engineering_transition','circuit_theory','homesickness'],
 'PCB', ARRAY['academics','adjustment','pcb_to_engineering'], 'chat'),
('a7000007-0000-0000-0000-000000000001',
 'PCM', ARRAY['just_joined'], NULL, NULL, 'both');

-- ============================================================
-- SECTION 6: AVAILABILITY SLOTS
-- ============================================================

INSERT INTO availability_slots (user_id, day_of_week, start_time, end_time, is_recurring) VALUES
-- Arjun (committee) – Mon/Wed evenings, Sat mornings
('a3000001-0000-0000-0000-000000000001', 1, '18:00', '20:00', TRUE),
('a3000001-0000-0000-0000-000000000001', 3, '18:00', '20:00', TRUE),
('a3000001-0000-0000-0000-000000000001', 6, '10:00', '13:00', TRUE),
-- Ananya (senior UG) – Tue/Thu evenings
('a5000001-0000-0000-0000-000000000001', 2, '17:30', '19:30', TRUE),
('a5000001-0000-0000-0000-000000000001', 4, '17:30', '19:30', TRUE),
-- Nikhil (junior UG) – Mon-Fri lunch hour, Sat
('a6000001-0000-0000-0000-000000000001', 1, '12:30', '13:30', TRUE),
('a6000001-0000-0000-0000-000000000001', 3, '12:30', '13:30', TRUE),
('a6000001-0000-0000-0000-000000000001', 5, '12:30', '13:30', TRUE),
('a6000001-0000-0000-0000-000000000001', 6, '09:00', '12:00', TRUE),
-- Vikram (PG) – flexible weekday evenings
('a4000001-0000-0000-0000-000000000001', 1, '19:00', '21:00', TRUE),
('a4000001-0000-0000-0000-000000000001', 4, '19:00', '21:00', TRUE),
-- Dr. Rahul (professional) – Mon-Fri daytime
('a2000001-0000-0000-0000-000000000001', 1, '10:00', '13:00', TRUE),
('a2000001-0000-0000-0000-000000000001', 2, '10:00', '13:00', TRUE),
('a2000001-0000-0000-0000-000000000001', 3, '10:00', '13:00', TRUE),
('a2000001-0000-0000-0000-000000000001', 4, '10:00', '13:00', TRUE),
('a2000001-0000-0000-0000-000000000001', 5, '10:00', '12:00', TRUE);

-- ============================================================
-- SECTION 7: USER INTERESTS & LANGUAGES
-- ============================================================

INSERT INTO user_interests (user_id, tag_id) VALUES
('a5000001-0000-0000-0000-000000000001', 1),   -- Ananya: DSA
('a5000001-0000-0000-0000-000000000001', 2),   -- Ananya: ML
('a5000001-0000-0000-0000-000000000001', 16),  -- Ananya: OSS
('a5000001-0000-0000-0000-000000000001', 7),   -- Ananya: Internships
('a4000001-0000-0000-0000-000000000001', 2),   -- Vikram: ML
('a4000001-0000-0000-0000-000000000001', 6),   -- Vikram: Research
('a4000001-0000-0000-0000-000000000001', 9),   -- Vikram: GATE/GRE
('a6000001-0000-0000-0000-000000000001', 3),   -- Nikhil: Web dev
('a6000001-0000-0000-0000-000000000001', 12),  -- Nikhil: Time mgmt
('a7000001-0000-0000-0000-000000000001', 1),   -- Ishaan: DSA
('a7000001-0000-0000-0000-000000000001', 2),   -- Ishaan: ML
('a7000001-0000-0000-0000-000000000001', 12),  -- Ishaan: Time mgmt
('a7000002-0000-0000-0000-000000000001', 4),   -- Shreya: VLSI
('a7000002-0000-0000-0000-000000000001', 13),  -- Shreya: Homesickness
('a7000003-0000-0000-0000-000000000001', 12),  -- Dev: Time mgmt
('a7000003-0000-0000-0000-000000000001', 11),  -- Dev: Stress mgmt
('a7000004-0000-0000-0000-000000000001', 3),   -- Aisha: Web dev
('a7000004-0000-0000-0000-000000000001', 17),  -- Aisha: Entrepreneurship
('a7000005-0000-0000-0000-000000000001', 12),  -- Rohan: Time mgmt
('a7000006-0000-0000-0000-000000000001', 11),  -- Pritha: Stress mgmt
('a7000006-0000-0000-0000-000000000001', 13);  -- Pritha: Homesickness

INSERT INTO user_languages (user_id, language_id, proficiency) VALUES
-- Ananya – Hindi native, English fluent
('a5000001-0000-0000-0000-000000000001', 2, 'native'),
('a5000001-0000-0000-0000-000000000001', 1, 'fluent'),
-- Vikram – Gujarati native, Hindi + English fluent
('a4000001-0000-0000-0000-000000000001', 8, 'native'),
('a4000001-0000-0000-0000-000000000001', 2, 'fluent'),
('a4000001-0000-0000-0000-000000000001', 1, 'fluent'),
-- Nikhil – Hindi native, English fluent
('a6000001-0000-0000-0000-000000000001', 2, 'native'),
('a6000001-0000-0000-0000-000000000001', 1, 'fluent'),
-- Tanvi – Gujarati native, Hindi + English fluent
('a6000002-0000-0000-0000-000000000001', 8, 'native'),
('a6000002-0000-0000-0000-000000000001', 2, 'fluent'),
('a6000002-0000-0000-0000-000000000001', 1, 'fluent'),
-- Riya – Bengali native, Hindi + English fluent
('a6000004-0000-0000-0000-000000000001', 9, 'native'),
('a6000004-0000-0000-0000-000000000001', 2, 'fluent'),
('a6000004-0000-0000-0000-000000000001', 1, 'fluent'),
-- Shreya – Malayalam native, English fluent, Hindi intermediate
('a7000002-0000-0000-0000-000000000001', 7, 'native'),
('a7000002-0000-0000-0000-000000000001', 1, 'fluent'),
('a7000002-0000-0000-0000-000000000001', 2, 'intermediate'),
-- Dev – Hindi native, English intermediate
('a7000003-0000-0000-0000-000000000001', 2, 'native'),
('a7000003-0000-0000-0000-000000000001', 1, 'intermediate'),
-- Pritha – Bengali native, Hindi intermediate, English fluent
('a7000006-0000-0000-0000-000000000001', 9, 'native'),
('a7000006-0000-0000-0000-000000000001', 1, 'fluent'),
('a7000006-0000-0000-0000-000000000001', 2, 'intermediate'),
-- Ishaan, Aisha, Rohan, Mihir – Hindi + English
('a7000001-0000-0000-0000-000000000001', 2, 'native'),
('a7000001-0000-0000-0000-000000000001', 1, 'fluent'),
('a7000004-0000-0000-0000-000000000001', 2, 'fluent'),
('a7000004-0000-0000-0000-000000000001', 1, 'fluent'),
('a7000005-0000-0000-0000-000000000001', 2, 'native'),
('a7000005-0000-0000-0000-000000000001', 1, 'intermediate');

-- ============================================================
-- SECTION 8: ML MATCH PREDICTIONS
-- ============================================================
-- Score breakdown fields: background, domain, language, availability

INSERT INTO ml_match_predictions
    (id, mentee_id, mentor_id, match_score, score_breakdown, model_version, predicted_at)
VALUES
-- Ishaan (CSE, PCM, DSA/ML) → top matches
('e0000001-0000-0000-0000-000000000001',
 'a7000001-0000-0000-0000-000000000001',
 'a5000001-0000-0000-0000-000000000001',  -- Ananya (CSE, PCM, DSA/ML/OSS)
 0.9214,
 '{"background":0.95,"domain":0.96,"language":0.90,"availability":0.88}',
 'v1.2.0', NOW() - INTERVAL '40 days'),
('e0000001-0000-0000-0000-000000000002',
 'a7000001-0000-0000-0000-000000000001',
 'a6000001-0000-0000-0000-000000000001',  -- Nikhil (CSE, PCM, web/time mgmt)
 0.8477,
 '{"background":0.90,"domain":0.82,"language":0.90,"availability":0.93}',
 'v1.2.0', NOW() - INTERVAL '40 days'),
('e0000001-0000-0000-0000-000000000003',
 'a7000001-0000-0000-0000-000000000001',
 'a4000001-0000-0000-0000-000000000001',  -- Vikram (PG, ML/research)
 0.8103,
 '{"background":0.88,"domain":0.90,"language":0.85,"availability":0.74}',
 'v1.2.0', NOW() - INTERVAL '40 days'),

-- Shreya (ECE, PCM, VLSI, Malayalam) → top matches
('e0000002-0000-0000-0000-000000000001',
 'a7000002-0000-0000-0000-000000000001',
 'a5000002-0000-0000-0000-000000000001',  -- Karan (ECE, PCM, GATE)
 0.8899,
 '{"background":0.92,"domain":0.88,"language":0.88,"availability":0.90}',
 'v1.2.0', NOW() - INTERVAL '38 days'),
('e0000002-0000-0000-0000-000000000002',
 'a7000002-0000-0000-0000-000000000001',
 'a3000002-0000-0000-0000-000000000001',  -- Sneha (ECE, women support)
 0.8541,
 '{"background":0.90,"domain":0.87,"language":0.82,"availability":0.84}',
 'v1.2.0', NOW() - INTERVAL '38 days'),

-- Dev (Mech, Diploma background) → top matches
('e0000003-0000-0000-0000-000000000001',
 'a7000003-0000-0000-0000-000000000001',
 'a5000003-0000-0000-0000-000000000001',  -- Pooja (Mech, Diploma)
 0.9441,
 '{"background":1.00,"domain":0.93,"language":0.90,"availability":0.92}',
 'v1.2.0', NOW() - INTERVAL '36 days'),
('e0000003-0000-0000-0000-000000000002',
 'a7000003-0000-0000-0000-000000000001',
 'a4000003-0000-0000-0000-000000000001',  -- Rohit (M.Tech Mech, Diploma empathy)
 0.8918,
 '{"background":0.95,"domain":0.88,"language":0.88,"availability":0.86}',
 'v1.2.0', NOW() - INTERVAL '36 days'),

-- Aisha (CSE, PCM, web dev, anxiety) → top matches
('e0000004-0000-0000-0000-000000000001',
 'a7000004-0000-0000-0000-000000000001',
 'a6000001-0000-0000-0000-000000000001',  -- Nikhil (CSE, web dev)
 0.8760,
 '{"background":0.90,"domain":0.88,"language":0.92,"availability":0.88}',
 'v1.2.0', NOW() - INTERVAL '34 days'),

-- Rohan (Civil, PCM, maths struggles) → top matches
('e0000005-0000-0000-0000-000000000001',
 'a7000005-0000-0000-0000-000000000001',
 'a6000002-0000-0000-0000-000000000001',  -- Tanvi (Civil, adjustment)
 0.8654,
 '{"background":0.88,"domain":0.85,"language":0.80,"availability":0.90}',
 'v1.2.0', NOW() - INTERVAL '32 days'),

-- Pritha (EE, PCB, Bengali) → top matches
('e0000006-0000-0000-0000-000000000001',
 'a7000006-0000-0000-0000-000000000001',
 'a6000004-0000-0000-0000-000000000001',  -- Riya (EE, PCB, Bengali)
 0.9338,
 '{"background":1.00,"domain":0.92,"language":0.98,"availability":0.85}',
 'v1.2.0', NOW() - INTERVAL '28 days');

-- ============================================================
-- SECTION 9: MATCH APPROVALS
-- ============================================================

INSERT INTO match_approvals
    (id, prediction_id, reviewed_by, status, override_mentor_id, reviewer_notes, actioned_at)
VALUES
-- Ishaan → Ananya: APPROVED (top prediction accepted as-is)
('f0000001-0000-0000-0000-000000000001',
 'e0000001-0000-0000-0000-000000000001',
 'a3000001-0000-0000-0000-000000000001',
 'approved', NULL,
 'Top prediction with strong background + domain match. Ananya has capacity and same department.',
 NOW() - INTERVAL '38 days'),

-- Aisha → Nikhil: OVERRIDDEN by committee (assigned Ananya instead, better for imposter syndrome support)
('f0000004-0000-0000-0000-000000000001',
 'e0000004-0000-0000-0000-000000000001',
 'a3000002-0000-0000-0000-000000000001',
 'overridden', 'a5000001-0000-0000-0000-000000000001',
 'Nikhil is a good match on domain but Aisha notes social anxiety and imposter syndrome. Ananya has prior experience supporting students with these concerns and is a stronger fit.',
 NOW() - INTERVAL '32 days'),

-- Dev → Pooja: APPROVED
('f0000003-0000-0000-0000-000000000001',
 'e0000003-0000-0000-0000-000000000001',
 'a3000001-0000-0000-0000-000000000001',
 'approved', NULL,
 'Perfect background match (Diploma→Mech). Highest confidence score in this batch.',
 NOW() - INTERVAL '34 days'),

-- Shreya → Karan: APPROVED
('f0000002-0000-0000-0000-000000000001',
 'e0000002-0000-0000-0000-000000000001',
 'a3000002-0000-0000-0000-000000000001',
 'approved', NULL,
 'Good ECE + GATE domain match. Sneha is second option if Karan fills up.',
 NOW() - INTERVAL '36 days'),

-- Pritha → Riya: APPROVED
('f0000006-0000-0000-0000-000000000001',
 'e0000006-0000-0000-0000-000000000001',
 'a3000002-0000-0000-0000-000000000001',
 'approved', NULL,
 'Near-perfect score. Same department, same academic background, shared native language. Strong fit.',
 NOW() - INTERVAL '26 days'),

-- Rohan pending review
('f0000005-0000-0000-0000-000000000001',
 'e0000005-0000-0000-0000-000000000001',
 'a3000001-0000-0000-0000-000000000001',
 'pending', NULL, NULL, NULL);

-- ============================================================
-- SECTION 10: MENTOR GROUPS & MEMBERSHIPS
-- ============================================================

INSERT INTO mentor_groups (id, mentor_id, group_name, max_capacity, current_count, is_active, created_by) VALUES
('d0000001-0000-0000-0000-000000000001',
 'a5000001-0000-0000-0000-000000000001',  -- Ananya
 'Ananya''s CSE Batch-2024 Group', 5, 3, TRUE,
 'a3000001-0000-0000-0000-000000000001'),
('d0000002-0000-0000-0000-000000000001',
 'a5000003-0000-0000-0000-000000000001',  -- Pooja
 'Pooja''s Mech Lateral Entry Group', 4, 2, TRUE,
 'a3000001-0000-0000-0000-000000000001'),
('d0000003-0000-0000-0000-000000000001',
 'a5000002-0000-0000-0000-000000000001',  -- Karan
 'Karan''s ECE Batch-2024 Group', 4, 1, TRUE,
 'a3000002-0000-0000-0000-000000000001'),
('d0000004-0000-0000-0000-000000000001',
 'a6000004-0000-0000-0000-000000000001',  -- Riya
 'Riya''s EE Group', 3, 1, TRUE,
 'a3000002-0000-0000-0000-000000000001');

INSERT INTO mentor_group_members
    (group_id, mentee_id, added_by, approval_ref_id, status, match_status, joined_at)
VALUES
-- Ananya's group: Ishaan (ML-approved), Aisha (committee override)
('d0000001-0000-0000-0000-000000000001', 'a7000001-0000-0000-0000-000000000001',
 'a3000001-0000-0000-0000-000000000001', 'f0000001-0000-0000-0000-000000000001',
 'active', 'assigned', NOW() - INTERVAL '37 days'),
('d0000001-0000-0000-0000-000000000001', 'a7000004-0000-0000-0000-000000000001',
 'a3000002-0000-0000-0000-000000000001', 'f0000004-0000-0000-0000-000000000001',
 'active', 'assigned', NOW() - INTERVAL '31 days'),
-- Pooja's group: Dev
('d0000002-0000-0000-0000-000000000001', 'a7000003-0000-0000-0000-000000000001',
 'a3000001-0000-0000-0000-000000000001', 'f0000003-0000-0000-0000-000000000001',
 'active', 'assigned', NOW() - INTERVAL '33 days'),
-- Karan's group: Shreya
('d0000003-0000-0000-0000-000000000001', 'a7000002-0000-0000-0000-000000000001',
 'a3000002-0000-0000-0000-000000000001', 'f0000002-0000-0000-0000-000000000001',
 'active', 'assigned', NOW() - INTERVAL '35 days'),
-- Riya's group: Pritha
('d0000004-0000-0000-0000-000000000001', 'a7000006-0000-0000-0000-000000000001',
 'a3000002-0000-0000-0000-000000000001', 'f0000006-0000-0000-0000-000000000001',
 'active', 'assigned', NOW() - INTERVAL '25 days');

-- ============================================================
-- SECTION 11: ISSUES
-- 6 issues covering all visibility levels, statuses, and scenarios
-- ============================================================

INSERT INTO issues (id, title, description, creator_id, category_id, visibility, is_anonymous, status, created_at, updated_at, closed_at) VALUES

-- Issue 1: PUBLIC, CLOSED (fully resolved)
('b0000001-0000-0000-0000-000000000001',
 'How do I get started with competitive programming as a CSE fresher?',
 'I joined CSE this year and everyone around me seems to already know Codeforces and LeetCode. I have basic C++ knowledge from school but have no idea how to structure my learning. Where do I start, how much time should I spend daily, and does it hurt my CGPA if I focus on CP?',
 'a7000001-0000-0000-0000-000000000001', 1, 'public', FALSE, 'closed',
 NOW() - INTERVAL '35 days', NOW() - INTERVAL '20 days', NOW() - INTERVAL '20 days'),

-- Issue 2: PUBLIC, IN_DISCUSSION (active thread)
('b0000002-0000-0000-0000-000000000001',
 'Struggling with Engineering Mathematics in 1st semester — any tips?',
 'The pace of Maths-1 (Calculus + Linear Algebra) is way faster than +2 level. I cleared my boards with 91% but here I feel completely lost after just three weeks. Is this normal? How do I manage without falling behind in other subjects too?',
 'a7000005-0000-0000-0000-000000000001', 1, 'public', FALSE, 'in_discussion',
 NOW() - INTERVAL '10 days', NOW() - INTERVAL '1 day', NULL),

-- Issue 3: PUBLIC, OPEN (no assignment yet — good "good-first-issue" candidate)
('b0000003-0000-0000-0000-000000000001',
 'Resources for GATE ECE preparation starting from 2nd year?',
 'I want to keep GATE as a backup option alongside placements. Are there any seniors who started GATE prep in 2nd year? Which subjects to focus on first, and how to balance it with regular coursework?',
 'a7000002-0000-0000-0000-000000000001', 2, 'public', FALSE, 'open',
 NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days', NULL),

-- Issue 4: PRIVATE, RESOLVED
('b0000004-0000-0000-0000-000000000001',
 'Feeling like I don''t belong here — everyone seems smarter than me',
 'I came through diploma lateral entry into 2nd year Mech. Most of my classmates have been together since 1st year and I feel completely out of the loop both academically and socially. I''m starting to think I made a mistake coming here. I feel isolated and behind on most subjects.',
 'a7000003-0000-0000-0000-000000000001', 3, 'private', FALSE, 'resolved',
 NOW() - INTERVAL '28 days', NOW() - INTERVAL '10 days', NULL),

-- Issue 5: ULTRA_PRIVATE, NEEDS_ESCALATION (active crisis)
('b0000005-0000-0000-0000-000000000001',
 'I haven''t been able to sleep or eat properly for 3 weeks',
 'I don''t know how to say this but things have gotten really bad. I have not slept more than 3 hours in the past three weeks. I stopped going to the mess because I feel sick around people. I cry a lot and don''t know why. I don''t think I can continue like this. I''m scared to tell anyone in person.',
 'a7000004-0000-0000-0000-000000000001', 4, 'ultra_private', TRUE, 'needs_escalation',
 NOW() - INTERVAL '5 days', NOW() - INTERVAL '4 days', NULL),

-- Issue 6: PUBLIC, OPEN (administrative)
('b0000006-0000-0000-0000-000000000001',
 'Scholarship renewal process — documentation required for NSP?',
 'I am a National Scholarship Portal (NSP) scholarship recipient. The renewal deadline is coming up and I am confused about which documents are needed from the college side. Who do I contact and what is the timeline?',
 'a7000005-0000-0000-0000-000000000001', 5, 'public', FALSE, 'open',
 NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day', NULL);

-- Issue labels
INSERT INTO issue_tag_map (issue_id, label_id) VALUES
('b0000001-0000-0000-0000-000000000001', 2),   -- first-year
('b0000001-0000-0000-0000-000000000001', 9),   -- resolved
('b0000002-0000-0000-0000-000000000001', 2),   -- first-year
('b0000002-0000-0000-0000-000000000001', 3),   -- exam-stress
('b0000003-0000-0000-0000-000000000001', 6),   -- good-first-issue
('b0000003-0000-0000-0000-000000000001', 7),   -- needs-resources
('b0000004-0000-0000-0000-000000000001', 2),   -- first-year
('b0000004-0000-0000-0000-000000000001', 9),   -- resolved
('b0000005-0000-0000-0000-000000000001', 1),   -- urgent
('b0000005-0000-0000-0000-000000000001', 8),   -- escalated
('b0000005-0000-0000-0000-000000000001', 10);  -- mental-health

-- ============================================================
-- SECTION 12: ISSUE ASSIGNMENTS
-- ============================================================

INSERT INTO issue_assignments (issue_id, mentor_id, assigned_by, is_primary, assigned_at, unassigned_at) VALUES
-- Issue 1 (closed): Ananya was primary, Nikhil supporting
('b0000001-0000-0000-0000-000000000001',
 'a5000001-0000-0000-0000-000000000001',
 'a3000001-0000-0000-0000-000000000001', TRUE,
 NOW() - INTERVAL '34 days', NULL),
('b0000001-0000-0000-0000-000000000001',
 'a6000001-0000-0000-0000-000000000001',
 'a3000001-0000-0000-0000-000000000001', FALSE,
 NOW() - INTERVAL '34 days', NULL),
-- Issue 2 (in_discussion): Arjun assigned
('b0000002-0000-0000-0000-000000000001',
 'a3000001-0000-0000-0000-000000000001',
 'a3000001-0000-0000-0000-000000000001', TRUE,
 NOW() - INTERVAL '9 days', NULL),
-- Issue 4 (resolved): Pooja primary
('b0000004-0000-0000-0000-000000000001',
 'a5000003-0000-0000-0000-000000000001',
 'a3000001-0000-0000-0000-000000000001', TRUE,
 NOW() - INTERVAL '27 days', NULL),
-- Issue 5 (escalated): Dr. Priya assigned, Dr. Meera supporting
('b0000005-0000-0000-0000-000000000001',
 'a2000002-0000-0000-0000-000000000001',
 'a1000001-0000-0000-0000-000000000001', TRUE,
 NOW() - INTERVAL '4 days', NULL),
('b0000005-0000-0000-0000-000000000001',
 'a1000001-0000-0000-0000-000000000001',
 'a1000001-0000-0000-0000-000000000001', FALSE,
 NOW() - INTERVAL '4 days', NULL);

-- ============================================================
-- SECTION 13: ISSUE COMMENTS (threaded)
-- ============================================================

INSERT INTO issue_comments (id, issue_id, author_id, body, parent_comment_id, is_internal_note, is_resolution_note, created_at) VALUES

-- ─── Issue 1 thread (CP question, now closed) ────────────────────────────────
('c0010001-0000-0000-0000-000000000001',
 'b0000001-0000-0000-0000-000000000001',
 'a5000001-0000-0000-0000-000000000001',
 'Great question — and very normal to feel behind! The good news is almost everyone is starting from zero in competitive programming even if they''re doing Codeforces in their free time. Here''s what I suggest: Start with Codeforces Div 3 contests to get a feel, do 30 min of problem-solving daily (not more in first sem), and don''t sacrifice CGPA — 6.0+ in 1st sem matters for internships later. SPOJ''s classical problems are a good structured starting point.',
 NULL, FALSE, FALSE, NOW() - INTERVAL '33 days'),
('c0010002-0000-0000-0000-000000000001',
 'b0000001-0000-0000-0000-000000000001',
 'a7000001-0000-0000-0000-000000000001',
 'Thank you! Should I do LeetCode or Codeforces? I keep seeing both recommended.',
 'c0010001-0000-0000-0000-000000000001', FALSE, FALSE, NOW() - INTERVAL '33 days'),
('c0010003-0000-0000-0000-000000000001',
 'b0000001-0000-0000-0000-000000000001',
 'a5000001-0000-0000-0000-000000000001',
 'For pure CP (contests, logic), Codeforces is the standard. LeetCode is more DSA-interview focused. In first year I''d go with Codeforces. Once placements are closer in 3rd year, switch to LeetCode seriously. You don''t need to do both at the same time.',
 'c0010002-0000-0000-0000-000000000001', FALSE, FALSE, NOW() - INTERVAL '32 days'),
('c0010004-0000-0000-0000-000000000001',
 'b0000001-0000-0000-0000-000000000001',
 'a6000001-0000-0000-0000-000000000001',
 'Also from my experience: do NOT grind problems randomly. Follow a structured sheet — I used Love Babbar''s DSA sheet in first year, it covers all patterns. Takes ~6 months at your own pace.',
 NULL, FALSE, FALSE, NOW() - INTERVAL '31 days'),
('c0010005-0000-0000-0000-000000000001',
 'b0000001-0000-0000-0000-000000000001',
 'a7000001-0000-0000-0000-000000000001',
 'This is really helpful, thank you both! Going to try Div 3 this weekend.',
 'c0010003-0000-0000-0000-000000000001', FALSE, FALSE, NOW() - INTERVAL '28 days'),
-- Resolution note (internal)
('c0010006-0000-0000-0000-000000000001',
 'b0000001-0000-0000-0000-000000000001',
 'a5000001-0000-0000-0000-000000000001',
 'Ishaan has participated in two Codeforces Div 3 rounds and reported feeling more comfortable. Issue addressed comprehensively. Closing.',
 NULL, FALSE, TRUE, NOW() - INTERVAL '20 days'),

-- ─── Issue 2 thread (Maths, in_discussion) ───────────────────────────────────
('c0020001-0000-0000-0000-000000000001',
 'b0000002-0000-0000-0000-000000000001',
 'a3000001-0000-0000-0000-000000000001',
 'This is completely normal and you are definitely not alone — I''d estimate 60-70% of the batch feels exactly this in the first 4 weeks. The jump from board-level maths to college-level is significant. A few things that helped me: (1) Attend tutorials without fail — the practice problems there are closer to exam level. (2) Get the previous year question papers from the department and reverse-engineer what topics are actually tested. (3) Don''t try to read the textbook linearly — use YouTube for concept first, then the textbook for problems.',
 NULL, FALSE, FALSE, NOW() - INTERVAL '9 days'),
('c0020002-0000-0000-0000-000000000001',
 'b0000002-0000-0000-0000-000000000001',
 'a7000005-0000-0000-0000-000000000001',
 'Which YouTube channel do you recommend for the linear algebra part?',
 'c0020001-0000-0000-0000-000000000001', FALSE, FALSE, NOW() - INTERVAL '9 days'),
('c0020003-0000-0000-0000-000000000001',
 'b0000002-0000-0000-0000-000000000001',
 'a3000001-0000-0000-0000-000000000001',
 '3Blue1Brown''s "Essence of Linear Algebra" series is the best visual intuition builder I know. After that, MIT OCW 18.06 for actual problem-solving. Also, Khan Academy is underrated for filling specific gaps quickly.',
 'c0020002-0000-0000-0000-000000000001', FALSE, FALSE, NOW() - INTERVAL '8 days'),
('c0020004-0000-0000-0000-000000000001',
 'b0000002-0000-0000-0000-000000000001',
 'a6000003-0000-0000-0000-000000000001',
 'Adding to this: form a study group of 3-4 people. We did this in our first year and it helped a lot. You end up teaching each other which cements the concept better than reading alone.',
 NULL, FALSE, FALSE, NOW() - INTERVAL '7 days'),
-- Internal mentor note
('c0020005-0000-0000-0000-000000000001',
 'b0000002-0000-0000-0000-000000000001',
 'a3000001-0000-0000-0000-000000000001',
 'Rohan is responding positively. Will follow up in 1 week. Check if he needs to be connected to the maths TAs directly.',
 NULL, TRUE, FALSE, NOW() - INTERVAL '6 days'),
('c0020006-0000-0000-0000-000000000001',
 'b0000002-0000-0000-0000-000000000001',
 'a7000005-0000-0000-0000-000000000001',
 'Started watching 3B1B, it''s making much more sense now. Still struggling with some calculus topics though. Is it okay to reach out to the TA directly?',
 'c0020003-0000-0000-0000-000000000001', FALSE, FALSE, NOW() - INTERVAL '1 day'),

-- ─── Issue 4 thread (private, Dev's isolation — resolved) ────────────────────
('c0040001-0000-0000-0000-000000000001',
 'b0000004-0000-0000-0000-000000000001',
 'a5000003-0000-0000-0000-000000000001',
 'Dev, I''m really glad you shared this. I want to tell you something personal: I was a diploma lateral entry student too, and my first two months in the direct 2nd year batch were the loneliest I''ve felt. Every single thing you described, I felt. It does get better — but more importantly, the gap you''re feeling academically is real but also temporary and fixable. Can we set up a call this week? I''d like to understand where you''re stuck specifically.',
 NULL, FALSE, FALSE, NOW() - INTERVAL '27 days'),
('c0040002-0000-0000-0000-000000000001',
 'b0000004-0000-0000-0000-000000000001',
 'a7000003-0000-0000-0000-000000000001',
 'I didn''t expect a mentor to say they felt the same. Yes, I''d like to talk. How do we set it up?',
 'c0040001-0000-0000-0000-000000000001', FALSE, FALSE, NOW() - INTERVAL '26 days'),
('c0040003-0000-0000-0000-000000000001',
 'b0000004-0000-0000-0000-000000000001',
 'a5000003-0000-0000-0000-000000000001',
 'I''ve sent you a calendar invite on your college email for Thursday 6pm. We can do a voice call or meet at the counselling room, whichever you''re comfortable with.',
 'c0040002-0000-0000-0000-000000000001', FALSE, FALSE, NOW() - INTERVAL '26 days'),
-- Resolution note
('c0040004-0000-0000-0000-000000000001',
 'b0000004-0000-0000-0000-000000000001',
 'a5000003-0000-0000-0000-000000000001',
 'We had three sessions over two weeks. Dev has been connected with two other lateral entry students in his batch (introductions made via me). He''s feeling more settled and has a study group for Thermodynamics now. Marking as resolved. He knows to reopen if things slip again.',
 NULL, FALSE, TRUE, NOW() - INTERVAL '10 days'),

-- ─── Issue 5 (ultra-private, crisis — escalation comment by Dr. Priya) ───────
('c0050001-0000-0000-0000-000000000001',
 'b0000005-0000-0000-0000-000000000001',
 'a2000002-0000-0000-0000-000000000001',
 'Thank you for trusting the platform with this. What you''re describing — not sleeping, avoiding eating, crying, feeling unable to continue — are serious signs that you need and deserve professional support right now, not later. I am Dr. Priya and I am a counsellor here. You are not in trouble. I want to meet with you at a time and place entirely of your choosing. Please reply here or email me directly at priya.nair@college.edu. If you are in immediate distress please go to the college health centre — they are available 24x7.',
 NULL, FALSE, FALSE, NOW() - INTERVAL '4 days'),
-- Internal escalation note
('c0050002-0000-0000-0000-000000000001',
 'b0000005-0000-0000-0000-000000000001',
 'a2000002-0000-0000-0000-000000000001',
 'Escalated to Dr. Meera per protocol. Creator is anonymous but group membership data may allow identification — checking with committee. No response yet from the student. Will attempt to reach via group mentor (Ananya) if creator is in a known group.',
 NULL, TRUE, FALSE, NOW() - INTERVAL '4 days');

-- ============================================================
-- SECTION 14: ISSUE STATUS HISTORY
-- ============================================================

INSERT INTO issue_status_history (issue_id, old_status, new_status, changed_by, note, changed_at) VALUES
-- Issue 1: open → in_discussion → resolved → closed
('b0000001-0000-0000-0000-000000000001', 'open',          'in_discussion', 'a5000001-0000-0000-0000-000000000001', 'Mentor assigned, discussion started.',              NOW() - INTERVAL '34 days'),
('b0000001-0000-0000-0000-000000000001', 'in_discussion',  'resolved',     'a5000001-0000-0000-0000-000000000001', 'Student confirmed problem resolved.',               NOW() - INTERVAL '21 days'),
('b0000001-0000-0000-0000-000000000001', 'resolved',       'closed',       'a3000001-0000-0000-0000-000000000001', 'Closed by committee after 24hr review period.',     NOW() - INTERVAL '20 days'),
-- Issue 2: open → in_discussion
('b0000002-0000-0000-0000-000000000001', 'open',           'in_discussion','a3000001-0000-0000-0000-000000000001', 'Mentor self-assigned and responded.',               NOW() - INTERVAL '9 days'),
-- Issue 4: open → in_discussion → resolved
('b0000004-0000-0000-0000-000000000001', 'open',           'in_discussion','a5000003-0000-0000-0000-000000000001', 'Mentor assigned, first session scheduled.',         NOW() - INTERVAL '27 days'),
('b0000004-0000-0000-0000-000000000001', 'in_discussion',  'resolved',     'a5000003-0000-0000-0000-000000000001', 'Three sessions completed, student stable.',         NOW() - INTERVAL '10 days'),
-- Issue 5: open → needs_escalation
('b0000005-0000-0000-0000-000000000001', 'open',           'needs_escalation','a2000002-0000-0000-0000-000000000001', 'Crisis indicators present. Escalated per mental health protocol.', NOW() - INTERVAL '4 days');

-- ============================================================
-- SECTION 15: ISSUE RESOLUTIONS
-- ============================================================

INSERT INTO issue_resolutions (issue_id, resolved_by, resolution_summary, contributing_mentors, can_reopen, closed_at) VALUES
-- Issue 1
('b0000001-0000-0000-0000-000000000001',
 'a5000001-0000-0000-0000-000000000001',
 'Student received a structured CP learning plan. Started with Codeforces Div 3 contests and Love Babbar DSA sheet. Completed two rounds with positive feedback. No longer feeling behind peers.',
 ARRAY['a5000001-0000-0000-0000-000000000001'::UUID, 'a6000001-0000-0000-0000-000000000001'::UUID],
 TRUE, NOW() - INTERVAL '20 days'),
-- Issue 4
('b0000004-0000-0000-0000-000000000001',
 'a5000003-0000-0000-0000-000000000001',
 'Three one-on-one sessions conducted. Student connected with two other lateral-entry peers and formed a study group. Thermodynamics study sessions scheduled. Academic isolation addressed. Emotional check-in planned for next month.',
 ARRAY['a5000003-0000-0000-0000-000000000001'::UUID],
 TRUE, NOW() - INTERVAL '10 days');

-- ============================================================
-- SECTION 16: ISSUE ESCALATIONS
-- ============================================================

INSERT INTO issue_escalations
    (issue_id, escalated_by, escalated_to_role, escalated_to_user, reason, status, created_at)
VALUES
('b0000005-0000-0000-0000-000000000001',
 'a2000002-0000-0000-0000-000000000001',
 7,                                              -- escalated to Counselling Head role
 'a1000001-0000-0000-0000-000000000001',         -- specifically to Dr. Meera
 'Student describes 3 weeks of sleep and appetite disruption with social withdrawal and uncontrolled crying. Anonymous post. Risk indicators present. Requires Head-level oversight and possible external medical referral.',
 'acknowledged',
 NOW() - INTERVAL '4 days');

-- ============================================================
-- SECTION 17: MENTOR RATINGS
-- ============================================================

INSERT INTO mentor_ratings (mentor_id, rater_id, group_id, issue_id, score, feedback_text, is_anonymous, created_at) VALUES
-- Ananya rated by Ishaan (group + issue)
('a5000001-0000-0000-0000-000000000001', 'a7000001-0000-0000-0000-000000000001',
 'd0000001-0000-0000-0000-000000000001', 'b0000001-0000-0000-0000-000000000001',
 5, 'Ananya explained exactly what I needed without making me feel dumb. Very approachable and patient.', FALSE, NOW() - INTERVAL '19 days'),
-- Nikhil rated by Ishaan (for supporting comment on issue 1)
('a6000001-0000-0000-0000-000000000001', 'a7000001-0000-0000-0000-000000000001',
 'd0000001-0000-0000-0000-000000000001', 'b0000001-0000-0000-0000-000000000001',
 4, 'Good tip about the DSA sheet. Would have liked a bit more detail but overall very helpful.', FALSE, NOW() - INTERVAL '19 days'),
-- Pooja rated by Dev (for issue 4)
('a5000003-0000-0000-0000-000000000001', 'a7000003-0000-0000-0000-000000000001',
 'd0000002-0000-0000-0000-000000000001', 'b0000004-0000-0000-0000-000000000001',
 5, 'I felt genuinely understood for the first time since joining. The fact that Pooja went through the same thing made all the difference.', FALSE, NOW() - INTERVAL '9 days'),
-- Karan rated by Shreya (group, no specific issue)
('a5000002-0000-0000-0000-000000000001', 'a7000002-0000-0000-0000-000000000001',
 'd0000003-0000-0000-0000-000000000001', NULL,
 4, 'Very knowledgeable, especially about GATE topics. Sometimes assumes too much prior knowledge.', FALSE, NOW() - INTERVAL '15 days'),
-- Riya rated by Pritha (group)
('a6000004-0000-0000-0000-000000000001', 'a7000006-0000-0000-0000-000000000001',
 'd0000004-0000-0000-0000-000000000001', NULL,
 5, 'Riya gets it completely. Same background, same struggle. Feels like talking to someone who just knows.', FALSE, NOW() - INTERVAL '20 days'),
-- Anonymous rating for Ananya from Aisha
('a5000001-0000-0000-0000-000000000001', 'a7000004-0000-0000-0000-000000000001',
 'd0000001-0000-0000-0000-000000000001', NULL,
 5, 'Never felt judged. Really helped me feel like I can belong here.', TRUE, NOW() - INTERVAL '10 days'),
-- Arjun rated by Rohan (issue 2 comment)
('a3000001-0000-0000-0000-000000000001', 'a7000005-0000-0000-0000-000000000001',
 NULL, 'b0000002-0000-0000-0000-000000000001',
 4, 'Very helpful advice about tutorial sessions and PYQs. The YouTube recommendations were spot on.', FALSE, NOW() - INTERVAL '5 days');

-- ============================================================
-- SECTION 18: MENTOR STATS (compute from data above)
-- ============================================================

SELECT refresh_mentor_stats('a5000001-0000-0000-0000-000000000001');  -- Ananya
SELECT refresh_mentor_stats('a5000002-0000-0000-0000-000000000001');  -- Karan
SELECT refresh_mentor_stats('a5000003-0000-0000-0000-000000000001');  -- Pooja
SELECT refresh_mentor_stats('a6000001-0000-0000-0000-000000000001');  -- Nikhil
SELECT refresh_mentor_stats('a6000002-0000-0000-0000-000000000001');  -- Tanvi
SELECT refresh_mentor_stats('a6000004-0000-0000-0000-000000000001');  -- Riya
SELECT refresh_mentor_stats('a3000001-0000-0000-0000-000000000001');  -- Arjun
SELECT refresh_mentor_stats('a3000002-0000-0000-0000-000000000001');  -- Sneha
SELECT refresh_mentor_stats('a4000001-0000-0000-0000-000000000001');  -- Vikram
SELECT refresh_mentor_stats('a2000001-0000-0000-0000-000000000001');  -- Dr. Rahul
SELECT refresh_mentor_stats('a2000002-0000-0000-0000-000000000001');  -- Dr. Priya
SELECT refresh_mentor_stats('a1000001-0000-0000-0000-000000000001');  -- Dr. Meera

-- ============================================================
-- SECTION 19: AUDIT LOGS
-- (Append-only — seeded directly since rules block UPDATE/DELETE)
-- ============================================================

INSERT INTO audit_logs (actor_id, action_type, target_table, target_id, old_value, new_value, ip_address, created_at) VALUES
-- Ultra-private issue viewed by Dr. Priya
('a2000002-0000-0000-0000-000000000001',
 'issue.viewed', 'issues', 'b0000005-0000-0000-0000-000000000001',
 NULL, '{"visibility":"ultra_private","accessed_by_role":"mentor_professional"}',
 '10.0.1.42', NOW() - INTERVAL '4 days'),
-- Ultra-private issue viewed by Dr. Meera (head)
('a1000001-0000-0000-0000-000000000001',
 'issue.viewed', 'issues', 'b0000005-0000-0000-0000-000000000001',
 NULL, '{"visibility":"ultra_private","accessed_by_role":"mentor_head"}',
 '10.0.1.10', NOW() - INTERVAL '4 days'),
-- Escalation created
('a2000002-0000-0000-0000-000000000001',
 'issue.escalated', 'issue_escalations', 'b0000005-0000-0000-0000-000000000001',
 NULL, '{"escalated_to_role":7,"escalated_to_user":"a1000001-0000-0000-0000-000000000001"}',
 '10.0.1.42', NOW() - INTERVAL '4 days'),
-- Committee override on match
('a3000002-0000-0000-0000-000000000001',
 'match.override', 'match_approvals', 'f0000004-0000-0000-0000-000000000001',
 '{"original_mentor":"a6000001-0000-0000-0000-000000000001"}',
 '{"override_mentor":"a5000001-0000-0000-0000-000000000001","reason":"anxiety_support"}',
 '10.0.1.55', NOW() - INTERVAL '32 days'),
-- User role verified
('a3000001-0000-0000-0000-000000000001',
 'user_role.verified', 'user_roles', 'a6000001-0000-0000-0000-000000000001',
 '{"verified":false}', '{"verified":true,"role_id":2}',
 '10.0.1.55', NOW() - INTERVAL '248 days'),
-- Issue comment deleted (internal note cleanup — blocked by rule but shows intent)
('a3000001-0000-0000-0000-000000000001',
 'comment.internal_note_added', 'issue_comments', 'c0020005-0000-0000-0000-000000000001',
 NULL, '{"is_internal_note":true,"issue_id":"b0000002-0000-0000-0000-000000000001"}',
 '10.0.1.55', NOW() - INTERVAL '6 days'),
-- Login from new IP flagged
('a7000001-0000-0000-0000-000000000001',
 'auth.login', 'users', 'a7000001-0000-0000-0000-000000000001',
 '{"last_ip":"10.0.1.90"}', '{"current_ip":"49.37.221.108","flagged":"new_ip"}',
 '49.37.221.108', NOW() - INTERVAL '3 days');

-- ============================================================
-- SECTION 20: NOTIFICATIONS
-- ============================================================

INSERT INTO notifications (recipient_id, type, title, body, related_entity_type, related_entity_id, action_url, is_read, read_at, created_at) VALUES
-- Ishaan: match approved → group added (both read)
('a7000001-0000-0000-0000-000000000001', 'match_approved',
 'Your mentor match has been approved!',
 'You have been matched with Ananya Singh (Senior Peer Mentor – CSE). You have been added to her mentoring group.',
 'mentor_group', 'd0000001-0000-0000-0000-000000000001',
 '/groups/d0000001-0000-0000-0000-000000000001',
 TRUE, NOW() - INTERVAL '37 days', NOW() - INTERVAL '38 days'),
('a7000001-0000-0000-0000-000000000001', 'group_added',
 'You have been added to a mentoring group',
 'Welcome to Ananya''s CSE Batch-2024 Group. Say hello to your mentor!',
 'mentor_group', 'd0000001-0000-0000-0000-000000000001',
 '/groups/d0000001-0000-0000-0000-000000000001',
 TRUE, NOW() - INTERVAL '36 days', NOW() - INTERVAL '37 days'),
-- Ishaan: issue commented + resolved (read)
('a7000001-0000-0000-0000-000000000001', 'issue_commented',
 'Ananya Singh replied to your issue',
 'Ananya commented on: "How do I get started with competitive programming as a CSE fresher?"',
 'issue', 'b0000001-0000-0000-0000-000000000001',
 '/issues/b0000001-0000-0000-0000-000000000001',
 TRUE, NOW() - INTERVAL '32 days', NOW() - INTERVAL '33 days'),
('a7000001-0000-0000-0000-000000000001', 'issue_resolved',
 'Your issue has been marked as resolved',
 '"How do I get started with competitive programming as a CSE fresher?" was resolved by Ananya Singh.',
 'issue', 'b0000001-0000-0000-0000-000000000001',
 '/issues/b0000001-0000-0000-0000-000000000001',
 TRUE, NOW() - INTERVAL '20 days', NOW() - INTERVAL '21 days'),
-- Ananya: rating received (unread)
('a5000001-0000-0000-0000-000000000001', 'rating_received',
 'You received a new rating',
 'Ishaan Gupta gave you a 5-star rating: "Ananya explained exactly what I needed..."',
 NULL, NULL,
 '/profile/ratings',
 FALSE, NULL, NOW() - INTERVAL '19 days'),
-- Ananya: anonymous rating received (unread)
('a5000001-0000-0000-0000-000000000001', 'rating_received',
 'You received an anonymous rating',
 'An anonymous mentee gave you 5 stars.',
 NULL, NULL,
 '/profile/ratings',
 FALSE, NULL, NOW() - INTERVAL '10 days'),
-- Rohan: issue commented (unread)
('a7000005-0000-0000-0000-000000000001', 'issue_commented',
 'Arjun Menon replied to your issue',
 'Arjun commented on: "Struggling with Engineering Mathematics in 1st semester"',
 'issue', 'b0000002-0000-0000-0000-000000000001',
 '/issues/b0000002-0000-0000-0000-000000000001',
 FALSE, NULL, NOW() - INTERVAL '9 days'),
-- Dr. Meera: issue escalation (unread — critical)
('a1000001-0000-0000-0000-000000000001', 'issue_escalated',
 'URGENT: Ultra-private issue escalated to you',
 'Dr. Priya Nair has escalated an ultra-private issue requiring immediate Head-level attention.',
 'issue', 'b0000005-0000-0000-0000-000000000001',
 '/issues/b0000005-0000-0000-0000-000000000001',
 FALSE, NULL, NOW() - INTERVAL '4 days'),
-- Dr. Priya: assigned to issue (read)
('a2000002-0000-0000-0000-000000000001', 'issue_assigned',
 'You have been assigned to a new issue',
 'Dr. Meera Iyer has assigned you as primary counsellor on an ultra-private issue.',
 'issue', 'b0000005-0000-0000-0000-000000000001',
 '/issues/b0000005-0000-0000-0000-000000000001',
 TRUE, NOW() - INTERVAL '4 days', NOW() - INTERVAL '4 days'),
-- Aisha: match overridden → group added (unread)
('a7000004-0000-0000-0000-000000000001', 'match_approved',
 'Your mentor match has been confirmed',
 'You have been matched with Ananya Singh (Senior Peer Mentor – CSE) and added to her group.',
 'mentor_group', 'd0000001-0000-0000-0000-000000000001',
 '/groups/d0000001-0000-0000-0000-000000000001',
 FALSE, NULL, NOW() - INTERVAL '31 days'),
-- Dev: group added + issue resolved (read)
('a7000003-0000-0000-0000-000000000001', 'group_added',
 'You have been added to a mentoring group',
 'Welcome to Pooja''s Mech Lateral Entry Group.',
 'mentor_group', 'd0000002-0000-0000-0000-000000000001',
 '/groups/d0000002-0000-0000-0000-000000000001',
 TRUE, NOW() - INTERVAL '32 days', NOW() - INTERVAL '33 days'),
('a7000003-0000-0000-0000-000000000001', 'issue_resolved',
 'Your issue has been resolved',
 'Pooja Desai marked your issue as resolved after three sessions.',
 'issue', 'b0000004-0000-0000-0000-000000000001',
 '/issues/b0000004-0000-0000-0000-000000000001',
 TRUE, NOW() - INTERVAL '10 days', NOW() - INTERVAL '10 days'),
-- Arjun: pending match review reminder (unread)
('a3000001-0000-0000-0000-000000000001', 'match_proposed',
 'A new match prediction is awaiting your review',
 'ML model has proposed a mentor match for Rohan Tiwari. Please review and approve or override.',
 'mentor_group', NULL,
 '/admin/match-approvals',
 FALSE, NULL, NOW() - INTERVAL '32 days'),
-- Mihir: email verification reminder (system, unread)
('a7000007-0000-0000-0000-000000000001', 'system',
 'Please verify your email to continue',
 'Your registration is almost complete. Please check mihir.jain@college.edu for the verification link.',
 NULL, NULL,
 '/verify-email',
 FALSE, NULL, NOW() - INTERVAL '2 hours'),
-- Pooja: new rating received (unread)
('a5000003-0000-0000-0000-000000000001', 'rating_received',
 'You received a new rating',
 'Dev Malhotra gave you 5 stars: "I felt genuinely understood for the first time since joining."',
 NULL, NULL,
 '/profile/ratings',
 FALSE, NULL, NOW() - INTERVAL '9 days');

-- ============================================================
-- SECTION 21: QUICK REFERENCE CHEAT SHEET (as SQL comments)
-- ============================================================
-- Role distribution:
--   Head (7):              a1000001-...-0001  meera.iyer@college.edu
--   Professional (6):      a2000001-...-0001  rahul.sharma@college.edu
--                          a2000002-...-0001  priya.nair@college.edu
--   Committee (5):         a3000001-...-0001  arjun.menon@college.edu
--                          a3000002-...-0001  sneha.kulkarni@college.edu
--   PG Mentors (4):        a4000001-...-0001  vikram.patel@college.edu
--                          a4000002-...-0001  divya.rao@college.edu
--                          a4000003-...-0001  rohit.joshi@college.edu
--   Senior UG (3):         a5000001-...-0001  ananya.singh@college.edu
--                          a5000002-...-0001  karan.mehta@college.edu
--                          a5000003-...-0001  pooja.desai@college.edu
--   Junior UG (2):         a6000001-...-0001  nikhil.verma@college.edu
--                          a6000002-...-0001  tanvi.shah@college.edu
--                          a6000003-...-0001  aditya.kumar@college.edu
--                          a6000004-...-0001  riya.bose@college.edu
--   Mentees (1):           a7000001-...-0001  ishaan.gupta@college.edu     (matched)
--                          a7000002-...-0001  shreya.pillai@college.edu    (matched)
--                          a7000003-...-0001  dev.malhotra@college.edu     (matched)
--                          a7000004-...-0001  aisha.khan@college.edu       (matched)
--                          a7000005-...-0001  rohan.tiwari@college.edu     (profile_complete, pending match)
--                          a7000006-...-0001  pritha.banerjee@college.edu  (profile_complete, pending match)
--                          a7000007-...-0001  mihir.jain@college.edu       (pending email verification)
--
-- Issue scenarios present:
--   b0000001  Public  + Closed     — CP question, fully resolved, 2 mentors attributed
--   b0000002  Public  + InDiscuss  — Maths struggle, active thread, internal note present
--   b0000003  Public  + Open       — GATE resources, no assignment yet
--   b0000004  Private + Resolved   — Isolation/imposter syndrome, 3 sessions, sorted
--   b0000005  UltraPrivate + Escalated — Crisis, anonymous, assigned to professional
--   b0000006  Public  + Open       — Administrative (NSP scholarship)
--
-- All passwords: Password@123

COMMIT;