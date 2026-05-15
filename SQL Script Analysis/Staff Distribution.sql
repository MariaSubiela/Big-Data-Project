--STAFF DISTRIBUTION 
--SECTION 1
--1.1 TEACHING STAFF VS CREDITS PASSED
WITH credits_by_campus AS (
    SELECT
        ce.campus_id,
        SUM(sp.credits_passed) AS total_credits_passed
    FROM student_progress sp
    JOIN center ce ON sp.center_code = ce.center_code
    GROUP BY ce.campus_id
),
staff_by_campus AS (
    SELECT
        d.campus_id,
        COUNT(DISTINCT ts.staff_id) AS teaching_staff_count
    FROM teaching_staff ts
    JOIN department d ON ts.department_id = d.department_id
    GROUP BY d.campus_id
)
SELECT
    c.campus_name,
    s.teaching_staff_count,
    cr.total_credits_passed,
    ROUND((s.teaching_staff_count::numeric / 
          NULLIF(cr.total_credits_passed, 0) * 1000)::numeric, 2) AS staff_per_1000_credits
FROM campus c
JOIN staff_by_campus s ON s.campus_id = c.campus_id
JOIN credits_by_campus cr ON cr.campus_id = c.campus_id
ORDER BY staff_per_1000_credits DESC;

--1.2 TYPE OF CONTRACTS PER CAMPUS 
SELECT
    c.campus_name,
    ts.contract_type,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY c.campus_name), 2) AS percentage
FROM teaching_staff ts
JOIN department d ON ts.department_id = d.department_id
JOIN campus c ON d.campus_id = c.campus_id
GROUP BY c.campus_name, ts.contract_type
ORDER BY c.campus_name, percentage DESC;

--1.3 TEMPORARY CONTRACTS VS SUCCESS RATE
WITH pass_rate AS (
    SELECT
        ce.campus_id,
        ROUND((SUM(sp.credits_passed)::numeric / 
              NULLIF(SUM(sp.credits_enrolled), 0) * 100)::numeric, 2) AS pass_rate
    FROM student_progress sp
    JOIN center ce ON sp.center_code = ce.center_code
    GROUP BY ce.campus_id
),
contract_mix AS (
    SELECT
        d.campus_id,
        ROUND(COUNT(*) FILTER (WHERE ts.contract_type ILIKE '%Determinada%')::numeric / 
              NULLIF(COUNT(*), 0) * 100, 2) AS pct_temporary
    FROM teaching_staff ts
    JOIN department d ON ts.department_id = d.department_id
    GROUP BY d.campus_id
)
SELECT
    c.campus_name,
    cm.pct_temporary,
    pr.pass_rate
FROM campus c
JOIN contract_mix cm ON cm.campus_id = c.campus_id
JOIN pass_rate pr ON pr.campus_id = c.campus_id
ORDER BY cm.pct_temporary DESC;

--1.4 STAFF DISTRIBUTION VS STUDENT DEMAND 
WITH enrolled AS (
    SELECT
        ce.campus_id,
        COUNT(DISTINCT sp.student_id) AS total_students,
        SUM(sp.credits_enrolled) AS total_enrolled
    FROM student_progress sp
    JOIN center ce ON sp.center_code = ce.center_code
    GROUP BY ce.campus_id
),
staff AS (
    SELECT
        d.campus_id,
        COUNT(DISTINCT ts.staff_id) AS teaching_staff
    FROM teaching_staff ts
    JOIN department d ON ts.department_id = d.department_id
    GROUP BY d.campus_id
)
SELECT
    c.campus_name,
    s.teaching_staff,
    e.total_students,
    ROUND((e.total_students::numeric / NULLIF(s.teaching_staff, 0))::numeric, 2) AS students_per_teacher,
    ROUND((e.total_enrolled::numeric / NULLIF(s.teaching_staff, 0))::numeric, 2) AS enrolled_credits_per_teacher
FROM campus c
JOIN staff s ON s.campus_id = c.campus_id
JOIN enrolled e ON e.campus_id = c.campus_id
ORDER BY students_per_teacher DESC;

--1.5 DOCTORATE QUALIFICATIONS VS PASS RATE
WITH doctorate_by_campus AS (
    SELECT
        d.campus_id,
        COUNT(*) AS total_staff,
        COUNT(*) FILTER (WHERE ts.doctorate_code = '1') AS staff_with_doctorate,
        ROUND(COUNT(*) FILTER (WHERE ts.doctorate_code = '1')::numeric / 
              NULLIF(COUNT(*), 0) * 100, 2) AS pct_doctorate
    FROM teaching_staff ts
    JOIN department d ON ts.department_id = d.department_id
    GROUP BY d.campus_id
),
pass_rate AS (
    SELECT
        ce.campus_id,
        ROUND((SUM(sp.credits_passed)::numeric / 
              NULLIF(SUM(sp.credits_enrolled), 0) * 100)::numeric, 2) AS pass_rate
    FROM student_progress sp
    JOIN center ce ON sp.center_code = ce.center_code
    GROUP BY ce.campus_id
)
SELECT
    c.campus_name,
    d.total_staff,
    d.staff_with_doctorate,
    d.pct_doctorate,
    p.pass_rate
FROM campus c
JOIN doctorate_by_campus d ON d.campus_id = c.campus_id
JOIN pass_rate p ON p.campus_id = c.campus_id
ORDER BY pct_doctorate DESC;

--1.6 TEACHING STAFF STRUCTURE PER DEPARTMENT
SELECT
    d.department_name,
    c.campus_name,
    COUNT(DISTINCT ts.staff_id) AS teaching_staff,
    ROUND(AVG(ts.seniority_periods)::numeric, 1) AS avg_seniority,
    ROUND(AVG(ts.part_time_hours)::numeric, 1) AS avg_hours,
    COUNT(DISTINCT ts.staff_id) FILTER (WHERE ts.contract_type ILIKE '%Determinada%') AS temp_count,
    ROUND(COUNT(DISTINCT ts.staff_id) FILTER (WHERE ts.contract_type ILIKE '%Determinada%')::numeric / 
          NULLIF(COUNT(DISTINCT ts.staff_id), 0) * 100, 1) AS pct_temporary
FROM teaching_staff ts
JOIN department d ON ts.department_id = d.department_id
JOIN campus c ON d.campus_id = c.campus_id
GROUP BY d.department_name, c.campus_name
ORDER BY teaching_staff DESC;

--1.7 AEROSPACE ENGINEERING 
SELECT
    dp.degree_name,
    ROUND((SUM(sp.credits_passed)::numeric / 
          NULLIF(SUM(sp.credits_enrolled), 0) * 100)::numeric, 2) AS pass_rate,
    SUM(sp.credits_enrolled) AS total_enrolled
FROM student_progress sp
JOIN degree_program dp ON sp.degree_code = dp.degree_code
JOIN center ce ON sp.center_code = ce.center_code
JOIN campus c ON ce.campus_id = c.campus_id
WHERE c.campus_name ILIKE '%Leganés%'
GROUP BY dp.degree_name
ORDER BY pass_rate ASC;

--SECTION 2
--2.1 DISTRIBUTION OF RESERACH STAFF ACROSS CAMPUSES
WITH research AS (
    SELECT
        d.campus_id,
        COUNT(*) AS research_staff_count
    FROM research_staff rs
    JOIN department d ON rs.department_id = d.department_id
    GROUP BY d.campus_id
),
teaching AS (
    SELECT
        d.campus_id,
        COUNT(DISTINCT ts.staff_id) AS teaching_staff_count
    FROM teaching_staff ts
    JOIN department d ON ts.department_id = d.department_id
    GROUP BY d.campus_id
)
SELECT
    c.campus_name,
    r.research_staff_count,
    t.teaching_staff_count,
    ROUND(r.research_staff_count::numeric / 
          NULLIF(t.teaching_staff_count, 0), 2) AS research_to_teaching_ratio
FROM campus c
JOIN research r ON r.campus_id = c.campus_id
JOIN teaching t ON t.campus_id = c.campus_id
ORDER BY research_staff_count DESC;

--2.2 RESEARCH-TO-TEACHING RATIO PER DEPARTMENT 
SELECT
    d.department_name,
    c.campus_name,
    COUNT(DISTINCT rs.research_id) AS research_staff,
    COUNT(DISTINCT ts.staff_id) AS teaching_staff,
    ROUND(COUNT(DISTINCT rs.research_id)::numeric / 
          NULLIF(COUNT(DISTINCT ts.staff_id), 0), 2) AS research_to_teaching_ratio
FROM department d
JOIN campus c ON d.campus_id = c.campus_id
LEFT JOIN research_staff rs ON rs.department_id = d.department_id
LEFT JOIN teaching_staff ts ON ts.department_id = d.department_id
GROUP BY d.department_name, c.campus_name
ORDER BY research_to_teaching_ratio DESC;

--2.3 CONTRACT DURATION PROFILE
SELECT
    c.campus_name,
    ROUND(AVG(rs.month_duration)::numeric, 1) AS avg_contract_months,
    MIN(rs.month_duration) AS min_months,
    MAX(rs.month_duration) AS max_months,
    COUNT(*) FILTER (WHERE rs.month_duration <= 12) AS short_contracts,
    COUNT(*) FILTER (WHERE rs.month_duration > 12) AS long_contracts,
    ROUND(COUNT(*) FILTER (WHERE rs.month_duration <= 12)::numeric / 
          NULLIF(COUNT(*), 0) * 100, 2) AS pct_short
FROM research_staff rs
JOIN department d ON rs.department_id = d.department_id
JOIN campus c ON d.campus_id = c.campus_id
GROUP BY c.campus_name
ORDER BY avg_contract_months ASC;

--2.4 INCORPORATION TRENDS
SELECT
    rs.incorporation_year,
    c.campus_name,
    COUNT(*) AS new_hires,
    ROUND(AVG(rs.month_duration)::numeric, 1) AS avg_contract_months
FROM research_staff rs
JOIN department d ON rs.department_id = d.department_id
JOIN campus c ON d.campus_id = c.campus_id
WHERE rs.incorporation_year IS NOT NULL
GROUP BY rs.incorporation_year, c.campus_name
ORDER BY rs.incorporation_year, c.campus_name;

--SECTION 3
--3.1 SENIORITY OF ADMIN STAFF
SELECT
    seniority_periods,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()::numeric, 2) AS percentage
FROM admin_staff
GROUP BY seniority_periods
ORDER BY seniority_periods DESC;

--3.2 STATUS 
SELECT
    admin_status,
    COUNT(*) AS total,
    ROUND(AVG(seniority_periods)::numeric, 1) AS avg_seniority,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()::numeric, 2) AS pct_of_total,
    COUNT(*) FILTER (WHERE teaches_flag = true) AS also_teaches
FROM admin_staff
GROUP BY admin_status
ORDER BY total DESC;

--3.3 TYPE OF CONTRACT FOR EXCEDENCIAS
SELECT
    contract_type,
    dedication_type,
    staff_type,
    COUNT(*) AS total,
    ROUND(AVG(seniority_periods)::numeric, 1) AS avg_seniority,
    COUNT(*) FILTER (WHERE teaches_flag = true) AS teaches
FROM admin_staff
WHERE admin_status = 'Excedencia'
GROUP BY contract_type, dedication_type, staff_type
ORDER BY total DESC;

--3.4 EXCEDENCIAS BY GENDER
SELECT
    admin_status,
    gender,
    COUNT(*) AS total,
    ROUND(COUNT(*) * 100.0 / 
          SUM(COUNT(*)) OVER (PARTITION BY admin_status)::numeric, 2) AS pct_within_status
FROM admin_staff
WHERE admin_status IN ('Excedencia', 'Servicio Activo')
GROUP BY admin_status, gender
ORDER BY admin_status, total DESC;

