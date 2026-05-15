--FINANCIAL EXPENSES
--Section 1: General distribution of Income 
--1.1 OVERALL SURPLUS OR DEFICIT 
WITH total_inc AS (
    SELECT SUM(net_collection) AS total_income
    FROM income
),
total_exp AS (
    SELECT SUM(net_payments) AS total_expenditure
    FROM expense
)
SELECT
    total_inc.total_income,
    total_exp.total_expenditure,
    total_inc.total_income - total_exp.total_expenditure AS surplus_deficit,
    ROUND((total_inc.total_income / NULLIF(total_exp.total_expenditure, 0) * 100)::numeric, 2) AS income_coverage_pct
FROM total_inc, total_exp;

--1.2 DEPENDENCE ON PUBLIC FUNDING
SELECT
    CASE
        WHEN chapter ILIKE '%TRANSFERENCIAS%' THEN 'Public transfers'
        WHEN chapter ILIKE '%TASAS%' THEN 'Own generated income'
        WHEN chapter ILIKE '%PATRIMONIAL%' THEN 'Patrimonial income'
        ELSE 'Other'
    END AS income_type,
    SUM(net_collection) AS total,
    ROUND((SUM(net_collection) * 100.0 / SUM(SUM(net_collection)) OVER ())::numeric, 2) AS pct
FROM income
GROUP BY income_type
ORDER BY total DESC;

--1.3 OWN GENERATED INCOME 
SELECT
    concept,
    subconcept,
    SUM(net_collection) AS total,
    ROUND((SUM(net_collection) * 100.0 / 
          SUM(SUM(net_collection)) OVER ())::numeric, 2) AS pct_of_own_income
FROM income
WHERE chapter ILIKE '%TASAS%'
GROUP BY concept, subconcept
ORDER BY total DESC;

--1.4 RECOVERY PER STUDY TYPE 
WITH tuition AS (
    SELECT
        CASE
            WHEN subconcept ILIKE '%MASTER%' 
              OR subconcept ILIKE '%MASTERES%' THEN 'postgraduate'
            ELSE 'undergraduate'
        END AS program_type,
        SUM(net_collection) AS tuition_income
    FROM income
    WHERE concept ILIKE '%MATRICULA TIT%'
    GROUP BY program_type
),
credits AS (
    SELECT
        CASE
            WHEN dp.degree_name ILIKE '%MASTER%' 
              OR dp.degree_name ILIKE '%POSTGRADO%' THEN 'postgraduate'
            ELSE 'undergraduate'
        END AS program_type,
        SUM(sp.credits_passed) AS total_passed
    FROM student_progress sp
    JOIN degree_program dp ON sp.degree_code = dp.degree_code
    GROUP BY program_type
)
SELECT
    t.program_type,
    t.tuition_income,
    c.total_passed,
    ROUND((t.tuition_income / NULLIF(c.total_passed, 0))::numeric, 2) AS income_per_credit,
    CASE 
        WHEN t.program_type = 'undergraduate' THEN 65
        WHEN t.program_type = 'postgraduate' THEN 410
    END AS cost_per_credit,
    ROUND((t.tuition_income / NULLIF(c.total_passed, 0) / 
          CASE 
              WHEN t.program_type = 'undergraduate' THEN 65
              WHEN t.program_type = 'postgraduate' THEN 410
          END * 100)::numeric, 2) AS cost_recovery_pct
FROM tuition t
JOIN credits c ON c.program_type = t.program_type;

--1.5 NON-TUITION OWN GENERATED INCOME 
WITH students AS (
    SELECT COUNT(DISTINCT student_id) AS total_students
    FROM student_progress
)
SELECT
    subconcept,
    SUM(i.net_collection) AS total_income,
    ROUND((SUM(i.net_collection) / s.total_students)::numeric, 2) AS income_per_student
FROM income i, students s
WHERE chapter ILIKE '%TASAS%'
  AND subconcept NOT ILIKE '%MATRICULA%'
  AND subconcept NOT ILIKE '%EVAU%'
GROUP BY subconcept, s.total_students
ORDER BY total_income DESC;

--Section 2: General Distribution of Expenses 
--2.1 EXPENSES BY CAMPUS 
SELECT
    c.campus_name,
    SUM(e.net_payments) AS total_expenditure,
    ROUND(
        SUM(e.net_payments) * 100.0 / SUM(SUM(e.net_payments)) OVER (),
        2
    ) AS percentage
FROM expense e
JOIN campus c ON e.campus_id = c.campus_id
GROUP BY c.campus_name
ORDER BY total_expenditure DESC;

--2.2 EXPENSES BY TYPE 
SELECT
    chapter,
    SUM(net_payments) AS total_expenditure,
    ROUND(
        SUM(net_payments) * 100.0 / SUM(SUM(net_payments)) OVER (),
        2
    ) AS percentage
FROM expense
GROUP BY chapter
ORDER BY total_expenditure DESC;

--2.3 EXPENSES BY TYPE AND CAMPUS
SELECT
    c.campus_name,
    e.chapter,
    ROUND(
        SUM(e.net_payments) * 100.0 / SUM(SUM(e.net_payments)) OVER (PARTITION BY c.campus_name),
        2
    ) AS percentage
FROM expense e
JOIN campus c ON e.campus_id = c.campus_id
GROUP BY c.campus_name, e.chapter
ORDER BY c.campus_name, percentage DESC;

--2.4 EXPENSES BY PROGRAM ACTIVITY
SELECT
    program_name,
    SUM(net_payments) AS total_expenditure,
    ROUND(
        SUM(net_payments) * 100.0 / SUM(SUM(net_payments)) OVER (),
        2
    ) AS percentage
FROM expense
GROUP BY program_name
ORDER BY total_expenditure DESC;

--2.5 CORRELATION TRAINING EXPENSE AND PERFORMANCE
WITH quality_expense AS (
    SELECT
        e.campus_id,
        SUM(e.net_payments) AS quality_expenditure
    FROM expense e
    WHERE e.program_name ILIKE '%POSTGRADO Y FORMACION%'
       OR e.program_name ILIKE '%CALIDAD EN LOS ESTUDIOS%'
       OR e.program_name ILIKE '%ESTUDIANTES%'
    GROUP BY e.campus_id
),
credits AS (
    SELECT
        ce.campus_id,
        SUM(sp.credits_passed) AS total_passed,
        ROUND(SUM(sp.credits_passed)::numeric / 
              NULLIF(SUM(sp.credits_enrolled), 0)::numeric, 2) AS success_rate
    FROM student_progress sp
    JOIN center ce ON sp.center_code = ce.center_code
    GROUP BY ce.campus_id
)
SELECT
    c.campus_name,
    cr.success_rate,
    ROUND((qe.quality_expenditure / NULLIF(cr.total_passed, 0))::numeric, 2) AS quality_cost_per_credit
FROM campus c
JOIN quality_expense qe ON qe.campus_id = c.campus_id
JOIN credits cr ON cr.campus_id = c.campus_id
WHERE c.campus_id IN (1, 2)
ORDER BY success_rate DESC;

--Section 3: Cost per credit passed
--3.1 COST PER CREDIT BY CAMPUS
SELECT
    c.campus_name,
    SUM(e.net_payments) AS total_expenditure,
    SUM(sp.credits_passed) AS total_passed,
    SUM(e.net_payments) / SUM(sp.credits_passed) AS cost_per_passed_credit
FROM student_progress sp
JOIN center ce ON sp.center_code = ce.center_code
JOIN campus c ON ce.campus_id = c.campus_id
LEFT JOIN expense e ON c.campus_id = e.campus_id
GROUP BY c.campus_name
ORDER BY cost_per_passed_credit ASC;

--3.2 COST PER CREDIT BY STUDY TYPE
WITH sp_type AS (
    SELECT
        CASE
            WHEN dp.degree_name ILIKE '%MASTER%' 
              OR dp.degree_name ILIKE '%POSTGRADO%' 
            THEN 'postgraduate'
            ELSE 'undergraduate'
        END AS program_type,
        SUM(sp.credits_passed) AS total_passed
    FROM student_progress sp
    JOIN degree_program dp ON sp.degree_code = dp.degree_code
    GROUP BY program_type
),
exp_type AS (
    SELECT
        CASE
            WHEN program_name ILIKE '%POSTGRADO%' THEN 'postgraduate'
            WHEN program_name ILIKE '%GRADO%' THEN 'undergraduate'
        END AS program_type,
        SUM(net_payments) AS total_expenditure
    FROM expense
    GROUP BY program_type
)
SELECT
    e.program_type,
    e.total_expenditure,
    s.total_passed,
    e.total_expenditure / s.total_passed AS cost_per_passed_credit
FROM exp_type e
JOIN sp_type s ON e.program_type = s.program_type;

--3.3
WITH sp_type AS (
    SELECT
        CASE
            WHEN dp.degree_name ILIKE '%MASTER%' 
              OR dp.degree_name ILIKE '%POSTGRADO%' 
            THEN 'postgraduate'
            ELSE 'undergraduate'
        END AS program_type,
        SUM(sp.credits_passed) AS total_passed
    FROM student_progress sp
    JOIN degree_program dp ON sp.degree_code = dp.degree_code
    GROUP BY program_type
),

total_sp AS (
    SELECT SUM(total_passed) AS total_passed_all
    FROM sp_type
),

personnel_pool AS (
    SELECT SUM(net_payments) AS total_personnel
    FROM expense
    WHERE program_name = 'PERSONAL DOCENTE E INVESTIGADOR'
),

exp_type AS (
    SELECT
        CASE
            WHEN program_name ILIKE '%POSTGRADO%' THEN 'postgraduate'
            WHEN program_name ILIKE '%GRADO%' THEN 'undergraduate'
        END AS program_type,
        SUM(net_payments) AS direct_expenditure
    FROM expense
    GROUP BY program_type)

SELECT
    e.program_type,
    e.direct_expenditure,
    s.total_passed,
    
    -- personnel allocated proportionally based on passed credits
    (p.total_personnel * s.total_passed / t.total_passed_all) AS allocated_personnel,
    
    -- total expense adjusted
    e.direct_expenditure +
    (p.total_personnel * s.total_passed / t.total_passed_all) AS adjusted_expenditure,

    -- cost per credit adjusted 
    (e.direct_expenditure +
     (p.total_personnel * s.total_passed / t.total_passed_all)
    ) / s.total_passed AS adjusted_cost_per_credit

FROM exp_type e
JOIN sp_type s ON e.program_type = s.program_type
CROSS JOIN total_sp t
CROSS JOIN personnel_pool p;

--3.4 EXPENDITURE STRUCTURE PER STUDY TYPE
SELECT
    program_type,
    chapter,
    SUM(net_payments) AS total,
    ROUND(
        SUM(net_payments) * 100.0 
        / SUM(SUM(net_payments)) OVER (PARTITION BY program_type),
        2
    ) AS percentage
FROM (
    SELECT
        CASE
            WHEN program_name ILIKE '%POSTGRADO%' THEN 'postgraduate'
            WHEN program_name ILIKE '%GRADO%' THEN 'undergraduate'
        END AS program_type,
        chapter,
        net_payments
    FROM expense
) sub
GROUP BY program_type, chapter
ORDER BY program_type, percentage DESC;

--3.5 COSTS FOR POSTGRADUATE
SELECT
    subconcept,
    SUM(net_payments) AS total_expenditure
FROM expense
WHERE program_name ILIKE '%POSTGRADO%'
GROUP BY subconcept
ORDER BY total_expenditure DESC;

--3.6 COST FOR UNDERGRADUATE
SELECT
    program_type,
    subconcept,
    SUM(net_payments) AS total,
    ROUND(
        SUM(net_payments) * 100.0 
        / SUM(SUM(net_payments)) OVER (PARTITION BY program_type),
        2
    ) AS percentage
FROM (
    SELECT
        CASE
            WHEN program_name ILIKE '%POSTGRADO%' THEN 'postgraduate'
            WHEN program_name ILIKE '%GRADO%' THEN 'undergraduate'
        END AS program_type,
        subconcept,
        net_payments
    FROM expense
) sub
WHERE program_type IS NOT NULL
GROUP BY program_type, subconcept
ORDER BY program_type, total DESC;


