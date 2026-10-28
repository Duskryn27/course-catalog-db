-- queries.sql
-- Queries that modify data are rolled back so the script can be rerun safely.

-- 1. GET /courses: first page, non-elective courses, sorted by popularity
SELECT id, title, credits, likes
FROM courses
WHERE is_elective = false
ORDER BY likes DESC, id
LIMIT 3 OFFSET 0;

-- 1b. GET /courses: second page
SELECT id, title, credits, likes
FROM courses
WHERE is_elective = false
ORDER BY likes DESC, id
LIMIT 3 OFFSET 3;

-- 2. GET /courses/{course_id}: existing course
SELECT id, title, credits, is_elective, likes
FROM courses
WHERE id = 'api-design';

-- 2b. GET /courses/{course_id}: nonexistent course
SELECT id, title, credits, is_elective, likes
FROM courses
WHERE id = 'missing-course';

-- 3. POST /courses/{course_id}/like: existing course
BEGIN;
UPDATE courses
SET likes = likes + 1
WHERE id = 'api-design'
RETURNING id, likes;

-- Like a nonexistent course
UPDATE courses
SET likes = likes + 1
WHERE id = 'missing-course'
RETURNING id, likes;
ROLLBACK;

-- 4. POST /enrollments
BEGIN;
INSERT INTO enrollments (course_id, student_id)
VALUES ('web-security', 3)
RETURNING id, course_id, student_id;
ROLLBACK;

-- 5. GET /enrollments
SELECT
    e.id AS enrollment_id,
    s.name AS student,
    c.title AS course
FROM enrollments AS e
JOIN students AS s ON s.id = e.student_id
JOIN courses AS c ON c.id = e.course_id
ORDER BY e.id;

-- 6. Enrollment statistics, including courses with none
SELECT
    c.id,
    COUNT(e.id) AS enrolled
FROM courses AS c
LEFT JOIN enrollments AS e ON e.course_id = c.id
GROUP BY c.id
ORDER BY enrolled DESC, c.id;
