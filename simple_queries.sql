-- Checking row counts

SELECT 'campus' AS table_name, COUNT(*) AS total FROM campus
UNION ALL
SELECT 'center', COUNT(*) FROM center
UNION ALL
SELECT 'degree_program', COUNT(*) FROM degree_program
UNION ALL
SELECT 'department', COUNT(*) FROM department
UNION ALL
SELECT 'admin_staff', COUNT(*) FROM admin_staff
UNION ALL
SELECT 'teaching_staff', COUNT(*) FROM teaching_staff
UNION ALL
SELECT 'expense', COUNT(*) FROM expense
UNION ALL
SELECT 'income', COUNT(*) FROM income
UNION ALL
SELECT 'incoming_mobility', COUNT(*) FROM incoming_mobility
UNION ALL
SELECT 'outgoing_mobility', COUNT(*) FROM outgoing_mobility
UNION ALL
SELECT 'student_access', COUNT(*) FROM student_access
UNION ALL
SELECT 'student_progress', COUNT(*) FROM student_progress;

-- Testing JOINS

-- Center with campus join

SELECT
    c.center_code,
    c.center_name,
    c.campus_id,
    cp.campus_name
FROM center c
JOIN campus cp
    ON c.campus_id = cp.campus_id
LIMIT 20;

-- Department with campus join

SELECT
    d.department_id,
    d.department_name,
    d.campus_id,
    c.campus_name
FROM department d
JOIN campus c
    ON d.campus_id = c.campus_id
LIMIT 20;

-- Student access with center and degree join

SELECT
    sa.academic_year,
    sa.center_code,
    c.center_name,
    sa.degree_code,
    dp.degree_name,
    sa.admission_score
FROM student_access sa
JOIN center c
    ON sa.center_code = c.center_code
JOIN degree_program dp
    ON sa.degree_code = dp.degree_code
LIMIT 20;

-- Student progress with center and degree join

SELECT
    sp.academic_year,
    c.center_name,
    dp.degree_name,
    sp.credits_enrolled,
    sp.credits_passed,
    sp.credits_failed
FROM student_progress sp
JOIN center c
    ON sp.center_code = c.center_code
JOIN degree_program dp
    ON sp.degree_code = dp.degree_code
LIMIT 20;

-- Outgoing mobility with degree join

SELECT
    om.academic_year,
    dp.degree_name,
    om.mobility_program,
    om.destination_university,
    om.destination_country
FROM outgoing_mobility om
JOIN degree_program dp
    ON om.degree_code = dp.degree_code
LIMIT 20;

-- Some meaningful analysis queries

-- Number of centers per campus

SELECT
    cp.campus_name,
    COUNT(c.center_code) AS total_centers
FROM campus cp
LEFT JOIN center c
    ON cp.campus_id = c.campus_id
GROUP BY cp.campus_name
ORDER BY total_centers DESC;

-- Number of departments per campus

SELECT
    c.campus_name,
    COUNT(d.department_id) AS total_departments
FROM campus c
LEFT JOIN department d
    ON c.campus_id = d.campus_id
GROUP BY c.campus_name
ORDER BY total_departments DESC;

-- Average admission score by degree

SELECT
    dp.degree_name,
    ROUND(AVG(sa.admission_score)::numeric, 2) AS avg_admission_score
FROM student_access sa
JOIN degree_program dp
    ON sa.degree_code = dp.degree_code
GROUP BY dp.degree_name
ORDER BY avg_admission_score DESC;

-- Total enrolled credits by center

SELECT
    c.center_name,
    SUM(sp.credits_enrolled) AS total_enrolled_credits
FROM student_progress sp
JOIN center c
    ON sp.center_code = c.center_code
GROUP BY c.center_name
ORDER BY total_enrolled_credits DESC;

-- Graduation count by academic year

SELECT
    academic_year,
    graduated_this_year,
    COUNT(*) AS total_students
FROM student_progress
GROUP BY academic_year, graduated_this_year
ORDER BY academic_year, graduated_this_year;

-- Incoming mobility by origin country

SELECT
    origin_country,
    COUNT(*) AS total_students
FROM incoming_mobility
GROUP BY origin_country
ORDER BY total_students DESC
LIMIT 10;

-- Outgoing mobility by destination country

SELECT
    destination_country,
    COUNT(*) AS total_students
FROM outgoing_mobility
GROUP BY destination_country
ORDER BY total_students DESC
LIMIT 10;

-- Total income by year

SELECT
    year,
    SUM(budget_amount) AS total_income_budget,
    SUM(recognized_rights) AS total_recognized_rights,
    SUM(net_collection) AS total_net_collection
FROM income
GROUP BY year
ORDER BY year;

-- Total expense by year

SELECT
    year,
    SUM(budget_amount) AS total_expense_budget,
    SUM(recognized_obligations) AS total_recognized_obligations,
    SUM(net_payments) AS total_net_payments
FROM expense
GROUP BY year
ORDER BY year;

-- Compare income vs expense by year

SELECT
    i.year,
    i.total_income,
    e.total_expense
FROM (
    SELECT
        year,
        SUM(net_collection) AS total_income
    FROM income
    GROUP BY year
) i
JOIN (
    SELECT
        year,
        SUM(net_payments) AS total_expense
    FROM expense
    GROUP BY year
) e
ON i.year = e.year
ORDER BY i.year;