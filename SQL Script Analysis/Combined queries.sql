-- Information on duplicated degrees across different campuses 

WITH target_degree AS (
    SELECT 'Grado en Derecho'::text AS degree_name
),
progress AS (
    SELECT 
        sp.degree_code,
        sp.degree_name,
        ce.center_name,
        c.campus_id,
        c.campus_name,
        ce.center_type,
        COUNT(*) AS n_students,
        AVG(sp.credits_enrolled) AS avg_credits_enrolled,
        AVG(sp.credits_passed) AS avg_credits_passed,
        AVG(sp.credits_failed) AS avg_credits_failed,
        AVG(sp.credits_passed::float / NULLIF(sp.credits_enrolled, 0)) AS success_rate,
        AVG(sp.credits_failed::float / NULLIF(sp.credits_enrolled, 0)) AS failure_rate,
        AVG(CASE WHEN sp.graduated_this_year THEN 1 ELSE 0 END) AS graduation_rate
    FROM student_progress sp
    JOIN center ce
        ON sp.center_code = ce.center_code
    JOIN campus c
        ON ce.campus_id = c.campus_id
    JOIN target_degree td
        ON sp.degree_name = td.degree_name
    GROUP BY 
        sp.degree_code, sp.degree_name,
        ce.center_name, c.campus_id, c.campus_name, ce.center_type
),
access AS (
    SELECT 
        sa.degree_code,
        sa.degree_name,
        ce.center_name,
        AVG(sa.admission_score) AS avg_admission_score,
        AVG(
            CASE 
                WHEN sa.mother_education IN ('Estudios Primarios', 'Estudios Secundarios')
                  OR sa.father_education IN ('Estudios Primarios', 'Estudios Secundarios')
                THEN 1 ELSE 0
            END
        ) AS pct_low_background,
        AVG(CASE WHEN sa.gender = 'Mujer' THEN 1 ELSE 0 END) AS pct_women
    FROM student_access sa
    JOIN center ce
        ON sa.center_code = ce.center_code
    JOIN target_degree td
        ON sa.degree_name = td.degree_name
    GROUP BY sa.degree_code, sa.degree_name, ce.center_name
),
out_mob AS (
    SELECT 
        om.degree_code,
        om.degree_name,
        COUNT(*) AS outgoing_mobility
    FROM outgoing_mobility om
    JOIN target_degree td
        ON om.degree_name = td.degree_name
    GROUP BY om.degree_code, om.degree_name
),
campus_students AS (
    SELECT 
        c.campus_id,
        COUNT(*) AS campus_students
    FROM student_progress sp
    JOIN center ce
        ON sp.center_code = ce.center_code
    JOIN campus c
        ON ce.campus_id = c.campus_id
    GROUP BY c.campus_id
),
campus_expense AS (
    SELECT 
        campus_id,
        SUM(recognized_obligations) AS total_expense
    FROM expense
    GROUP BY campus_id
),
campus_income AS (
    SELECT 
        campus_id,
        SUM(recognized_rights) AS total_income
    FROM income
    GROUP BY campus_id
),
campus_in_mob AS (
    SELECT 
        campus_id,
        COUNT(*) AS incoming_mobility
    FROM incoming_mobility
    GROUP BY campus_id
)
SELECT 
    p.degree_name,
    p.center_name,
    p.campus_name,
    p.center_type,
    p.n_students,
    p.avg_credits_enrolled,
    p.avg_credits_passed,
    p.avg_credits_failed,
    p.success_rate,
    p.failure_rate,
    p.graduation_rate,
    a.avg_admission_score,
    a.pct_low_background,
    a.pct_women,
    COALESCE(ce.total_expense / NULLIF(cs.campus_students, 0), NULL) AS expense_per_student_campus,
    COALESCE(ci.total_income / NULLIF(cs.campus_students, 0), NULL) AS income_per_student_campus,
    COALESCE(cim.incoming_mobility, 0) AS incoming_mobility_campus,
    COALESCE(om.outgoing_mobility, 0) AS outgoing_mobility_degree
FROM progress p
LEFT JOIN access a
    ON p.degree_code = a.degree_code
   AND p.center_name = a.center_name
LEFT JOIN out_mob om
    ON p.degree_code = om.degree_code
LEFT JOIN campus_students cs
    ON p.campus_id = cs.campus_id
LEFT JOIN campus_expense ce
    ON p.campus_id = ce.campus_id
LEFT JOIN campus_income ci
    ON p.campus_id = ci.campus_id
LEFT JOIN campus_in_mob cim
    ON p.campus_id = cim.campus_id
ORDER BY p.success_rate DESC;




-- Doble Grado en Ingeniería Informática y Administración de Empresas

WITH target_degree AS (
    SELECT 'Doble Grado en Ingeniería Informática y Administración de Empresas'::text AS degree_name
),
progress AS (
    SELECT 
        sp.degree_code,
        sp.degree_name,
        ce.center_name,
        c.campus_id,
        c.campus_name,
        ce.center_type,
        COUNT(*) AS n_students,
        AVG(sp.credits_enrolled) AS avg_credits_enrolled,
        AVG(sp.credits_passed) AS avg_credits_passed,
        AVG(sp.credits_failed) AS avg_credits_failed,
        AVG(sp.credits_passed::float / NULLIF(sp.credits_enrolled, 0)) AS success_rate,
        AVG(sp.credits_failed::float / NULLIF(sp.credits_enrolled, 0)) AS failure_rate,
        AVG(CASE WHEN sp.graduated_this_year THEN 1 ELSE 0 END) AS graduation_rate
    FROM student_progress sp
    JOIN center ce
        ON sp.center_code = ce.center_code
    JOIN campus c
        ON ce.campus_id = c.campus_id
    JOIN target_degree td
        ON sp.degree_name = td.degree_name
    GROUP BY 
        sp.degree_code, sp.degree_name,
        ce.center_name, c.campus_id, c.campus_name, ce.center_type
),
access AS (
    SELECT 
        sa.degree_code,
        sa.degree_name,
        ce.center_name,
        AVG(sa.admission_score) AS avg_admission_score,
        AVG(
            CASE 
                WHEN sa.mother_education IN ('Estudios Primarios', 'Estudios Secundarios')
                  OR sa.father_education IN ('Estudios Primarios', 'Estudios Secundarios')
                THEN 1 ELSE 0
            END
        ) AS pct_low_background,
        AVG(CASE WHEN sa.gender = 'Mujer' THEN 1 ELSE 0 END) AS pct_women
    FROM student_access sa
    JOIN center ce
        ON sa.center_code = ce.center_code
    JOIN target_degree td
        ON sa.degree_name = td.degree_name
    GROUP BY sa.degree_code, sa.degree_name, ce.center_name
),
out_mob AS (
    SELECT 
        om.degree_code,
        om.degree_name,
        COUNT(*) AS outgoing_mobility
    FROM outgoing_mobility om
    JOIN target_degree td
        ON om.degree_name = td.degree_name
    GROUP BY om.degree_code, om.degree_name
),
campus_students AS (
    SELECT 
        c.campus_id,
        COUNT(*) AS campus_students
    FROM student_progress sp
    JOIN center ce
        ON sp.center_code = ce.center_code
    JOIN campus c
        ON ce.campus_id = c.campus_id
    GROUP BY c.campus_id
),
campus_expense AS (
    SELECT 
        campus_id,
        SUM(recognized_obligations) AS total_expense
    FROM expense
    GROUP BY campus_id
),
campus_income AS (
    SELECT 
        campus_id,
        SUM(recognized_rights) AS total_income
    FROM income
    GROUP BY campus_id
),
campus_in_mob AS (
    SELECT 
        campus_id,
        COUNT(*) AS incoming_mobility
    FROM incoming_mobility
    GROUP BY campus_id
)
SELECT 
    p.degree_name,
    p.center_name,
    p.campus_name,
    p.center_type,
    p.n_students,
    p.avg_credits_enrolled,
    p.avg_credits_passed,
    p.avg_credits_failed,
    p.success_rate,
    p.failure_rate,
    p.graduation_rate,
    a.avg_admission_score,
    a.pct_low_background,
    a.pct_women,
    COALESCE(ce.total_expense / NULLIF(cs.campus_students, 0), NULL) AS expense_per_student_campus,
    COALESCE(ci.total_income / NULLIF(cs.campus_students, 0), NULL) AS income_per_student_campus,
    COALESCE(cim.incoming_mobility, 0) AS incoming_mobility_campus,
    COALESCE(om.outgoing_mobility, 0) AS outgoing_mobility_degree
FROM progress p
LEFT JOIN access a
    ON p.degree_code = a.degree_code
   AND p.center_name = a.center_name
LEFT JOIN out_mob om
    ON p.degree_code = om.degree_code
LEFT JOIN campus_students cs
    ON p.campus_id = cs.campus_id
LEFT JOIN campus_expense ce
    ON p.campus_id = ce.campus_id
LEFT JOIN campus_income ci
    ON p.campus_id = ci.campus_id
LEFT JOIN campus_in_mob cim
    ON p.campus_id = cim.campus_id
ORDER BY p.success_rate DESC;




-- Grado en Ingeniería Informática

WITH target_degree AS (
    SELECT 'Grado en Ingeniería Informática'::text AS degree_name
),
progress AS (
    SELECT 
        sp.degree_code,
        sp.degree_name,
        ce.center_name,
        c.campus_id,
        c.campus_name,
        ce.center_type,
        COUNT(*) AS n_students,
        AVG(sp.credits_enrolled) AS avg_credits_enrolled,
        AVG(sp.credits_passed) AS avg_credits_passed,
        AVG(sp.credits_failed) AS avg_credits_failed,
        AVG(sp.credits_passed::float / NULLIF(sp.credits_enrolled, 0)) AS success_rate,
        AVG(sp.credits_failed::float / NULLIF(sp.credits_enrolled, 0)) AS failure_rate,
        AVG(CASE WHEN sp.graduated_this_year THEN 1 ELSE 0 END) AS graduation_rate
    FROM student_progress sp
    JOIN center ce
        ON sp.center_code = ce.center_code
    JOIN campus c
        ON ce.campus_id = c.campus_id
    JOIN target_degree td
        ON sp.degree_name = td.degree_name
    GROUP BY 
        sp.degree_code, sp.degree_name,
        ce.center_name, c.campus_id, c.campus_name, ce.center_type
),
access AS (
    SELECT 
        sa.degree_code,
        sa.degree_name,
        ce.center_name,
        AVG(sa.admission_score) AS avg_admission_score,
        AVG(
            CASE 
                WHEN sa.mother_education IN ('Estudios Primarios', 'Estudios Secundarios')
                  OR sa.father_education IN ('Estudios Primarios', 'Estudios Secundarios')
                THEN 1 ELSE 0
            END
        ) AS pct_low_background,
        AVG(CASE WHEN sa.gender = 'Mujer' THEN 1 ELSE 0 END) AS pct_women
    FROM student_access sa
    JOIN center ce
        ON sa.center_code = ce.center_code
    JOIN target_degree td
        ON sa.degree_name = td.degree_name
    GROUP BY sa.degree_code, sa.degree_name, ce.center_name
),
out_mob AS (
    SELECT 
        om.degree_code,
        om.degree_name,
        COUNT(*) AS outgoing_mobility
    FROM outgoing_mobility om
    JOIN target_degree td
        ON om.degree_name = td.degree_name
    GROUP BY om.degree_code, om.degree_name
),
campus_students AS (
    SELECT 
        c.campus_id,
        COUNT(*) AS campus_students
    FROM student_progress sp
    JOIN center ce
        ON sp.center_code = ce.center_code
    JOIN campus c
        ON ce.campus_id = c.campus_id
    GROUP BY c.campus_id
),
campus_expense AS (
    SELECT 
        campus_id,
        SUM(recognized_obligations) AS total_expense
    FROM expense
    GROUP BY campus_id
),
campus_income AS (
    SELECT 
        campus_id,
        SUM(recognized_rights) AS total_income
    FROM income
    GROUP BY campus_id
),
campus_in_mob AS (
    SELECT 
        campus_id,
        COUNT(*) AS incoming_mobility
    FROM incoming_mobility
    GROUP BY campus_id
)
SELECT 
    p.degree_name,
    p.center_name,
    p.campus_name,
    p.center_type,
    p.n_students,
    p.avg_credits_enrolled,
    p.avg_credits_passed,
    p.avg_credits_failed,
    p.success_rate,
    p.failure_rate,
    p.graduation_rate,
    a.avg_admission_score,
    a.pct_low_background,
    a.pct_women,
    COALESCE(ce.total_expense / NULLIF(cs.campus_students, 0), NULL) AS expense_per_student_campus,
    COALESCE(ci.total_income / NULLIF(cs.campus_students, 0), NULL) AS income_per_student_campus,
    COALESCE(cim.incoming_mobility, 0) AS incoming_mobility_campus,
    COALESCE(om.outgoing_mobility, 0) AS outgoing_mobility_degree
FROM progress p
LEFT JOIN access a
    ON p.degree_code = a.degree_code
   AND p.center_name = a.center_name
LEFT JOIN out_mob om
    ON p.degree_code = om.degree_code
LEFT JOIN campus_students cs
    ON p.campus_id = cs.campus_id
LEFT JOIN campus_expense ce
    ON p.campus_id = ce.campus_id
LEFT JOIN campus_income ci
    ON p.campus_id = ci.campus_id
LEFT JOIN campus_in_mob cim
    ON p.campus_id = cim.campus_id
ORDER BY p.success_rate DESC;





-- Grado en Administración de Empresas

WITH target_degree AS (
    SELECT 'Grado en Administración de Empresas'::text AS degree_name
),
progress AS (
    SELECT 
        sp.degree_code,
        sp.degree_name,
        ce.center_name,
        c.campus_id,
        c.campus_name,
        ce.center_type,
        COUNT(*) AS n_students,
        AVG(sp.credits_enrolled) AS avg_credits_enrolled,
        AVG(sp.credits_passed) AS avg_credits_passed,
        AVG(sp.credits_failed) AS avg_credits_failed,
        AVG(sp.credits_passed::float / NULLIF(sp.credits_enrolled, 0)) AS success_rate,
        AVG(sp.credits_failed::float / NULLIF(sp.credits_enrolled, 0)) AS failure_rate,
        AVG(CASE WHEN sp.graduated_this_year THEN 1 ELSE 0 END) AS graduation_rate
    FROM student_progress sp
    JOIN center ce
        ON sp.center_code = ce.center_code
    JOIN campus c
        ON ce.campus_id = c.campus_id
    JOIN target_degree td
        ON sp.degree_name = td.degree_name
    GROUP BY 
        sp.degree_code, sp.degree_name,
        ce.center_name, c.campus_id, c.campus_name, ce.center_type
),
access AS (
    SELECT 
        sa.degree_code,
        sa.degree_name,
        ce.center_name,
        AVG(sa.admission_score) AS avg_admission_score,
        AVG(
            CASE 
                WHEN sa.mother_education IN ('Estudios Primarios', 'Estudios Secundarios')
                  OR sa.father_education IN ('Estudios Primarios', 'Estudios Secundarios')
                THEN 1 ELSE 0
            END
        ) AS pct_low_background,
        AVG(CASE WHEN sa.gender = 'Mujer' THEN 1 ELSE 0 END) AS pct_women
    FROM student_access sa
    JOIN center ce
        ON sa.center_code = ce.center_code
    JOIN target_degree td
        ON sa.degree_name = td.degree_name
    GROUP BY sa.degree_code, sa.degree_name, ce.center_name
),
out_mob AS (
    SELECT 
        om.degree_code,
        om.degree_name,
        COUNT(*) AS outgoing_mobility
    FROM outgoing_mobility om
    JOIN target_degree td
        ON om.degree_name = td.degree_name
    GROUP BY om.degree_code, om.degree_name
),
campus_students AS (
    SELECT 
        c.campus_id,
        COUNT(*) AS campus_students
    FROM student_progress sp
    JOIN center ce
        ON sp.center_code = ce.center_code
    JOIN campus c
        ON ce.campus_id = c.campus_id
    GROUP BY c.campus_id
),
campus_expense AS (
    SELECT 
        campus_id,
        SUM(recognized_obligations) AS total_expense
    FROM expense
    GROUP BY campus_id
),
campus_income AS (
    SELECT 
        campus_id,
        SUM(recognized_rights) AS total_income
    FROM income
    GROUP BY campus_id
),
campus_in_mob AS (
    SELECT 
        campus_id,
        COUNT(*) AS incoming_mobility
    FROM incoming_mobility
    GROUP BY campus_id
)
SELECT 
    p.degree_name,
    p.center_name,
    p.campus_name,
    p.center_type,
    p.n_students,
    p.avg_credits_enrolled,
    p.avg_credits_passed,
    p.avg_credits_failed,
    p.success_rate,
    p.failure_rate,
    p.graduation_rate,
    a.avg_admission_score,
    a.pct_low_background,
    a.pct_women,
    COALESCE(ce.total_expense / NULLIF(cs.campus_students, 0), NULL) AS expense_per_student_campus,
    COALESCE(ci.total_income / NULLIF(cs.campus_students, 0), NULL) AS income_per_student_campus,
    COALESCE(cim.incoming_mobility, 0) AS incoming_mobility_campus,
    COALESCE(om.outgoing_mobility, 0) AS outgoing_mobility_degree
FROM progress p
LEFT JOIN access a
    ON p.degree_code = a.degree_code
   AND p.center_name = a.center_name
LEFT JOIN out_mob om
    ON p.degree_code = om.degree_code
LEFT JOIN campus_students cs
    ON p.campus_id = cs.campus_id
LEFT JOIN campus_expense ce
    ON p.campus_id = ce.campus_id
LEFT JOIN campus_income ci
    ON p.campus_id = ci.campus_id
LEFT JOIN campus_in_mob cim
    ON p.campus_id = cim.campus_id
ORDER BY p.success_rate DESC;




-- Doble Grado en Derecho y Administración de Empresas

WITH target_degree AS (
    SELECT 'Doble Grado en Derecho y Administración de Empresas'::text AS degree_name
),
progress AS (
    SELECT 
        sp.degree_code,
        sp.degree_name,
        ce.center_name,
        c.campus_id,
        c.campus_name,
        ce.center_type,
        COUNT(*) AS n_students,
        AVG(sp.credits_enrolled) AS avg_credits_enrolled,
        AVG(sp.credits_passed) AS avg_credits_passed,
        AVG(sp.credits_failed) AS avg_credits_failed,
        AVG(sp.credits_passed::float / NULLIF(sp.credits_enrolled, 0)) AS success_rate,
        AVG(sp.credits_failed::float / NULLIF(sp.credits_enrolled, 0)) AS failure_rate,
        AVG(CASE WHEN sp.graduated_this_year THEN 1 ELSE 0 END) AS graduation_rate
    FROM student_progress sp
    JOIN center ce
        ON sp.center_code = ce.center_code
    JOIN campus c
        ON ce.campus_id = c.campus_id
    JOIN target_degree td
        ON sp.degree_name = td.degree_name
    GROUP BY 
        sp.degree_code, sp.degree_name,
        ce.center_name, c.campus_id, c.campus_name, ce.center_type
),
access AS (
    SELECT 
        sa.degree_code,
        sa.degree_name,
        ce.center_name,
        AVG(sa.admission_score) AS avg_admission_score,
        AVG(
            CASE 
                WHEN sa.mother_education IN ('Estudios Primarios', 'Estudios Secundarios')
                  OR sa.father_education IN ('Estudios Primarios', 'Estudios Secundarios')
                THEN 1 ELSE 0
            END
        ) AS pct_low_background,
        AVG(CASE WHEN sa.gender = 'Mujer' THEN 1 ELSE 0 END) AS pct_women
    FROM student_access sa
    JOIN center ce
        ON sa.center_code = ce.center_code
    JOIN target_degree td
        ON sa.degree_name = td.degree_name
    GROUP BY sa.degree_code, sa.degree_name, ce.center_name
),
out_mob AS (
    SELECT 
        om.degree_code,
        om.degree_name,
        COUNT(*) AS outgoing_mobility
    FROM outgoing_mobility om
    JOIN target_degree td
        ON om.degree_name = td.degree_name
    GROUP BY om.degree_code, om.degree_name
),
campus_students AS (
    SELECT 
        c.campus_id,
        COUNT(*) AS campus_students
    FROM student_progress sp
    JOIN center ce
        ON sp.center_code = ce.center_code
    JOIN campus c
        ON ce.campus_id = c.campus_id
    GROUP BY c.campus_id
),
campus_expense AS (
    SELECT 
        campus_id,
        SUM(recognized_obligations) AS total_expense
    FROM expense
    GROUP BY campus_id
),
campus_income AS (
    SELECT 
        campus_id,
        SUM(recognized_rights) AS total_income
    FROM income
    GROUP BY campus_id
),
campus_in_mob AS (
    SELECT 
        campus_id,
        COUNT(*) AS incoming_mobility
    FROM incoming_mobility
    GROUP BY campus_id
)
SELECT 
    p.degree_name,
    p.center_name,
    p.campus_name,
    p.center_type,
    p.n_students,
    p.avg_credits_enrolled,
    p.avg_credits_passed,
    p.avg_credits_failed,
    p.success_rate,
    p.failure_rate,
    p.graduation_rate,
    a.avg_admission_score,
    a.pct_low_background,
    a.pct_women,
    COALESCE(ce.total_expense / NULLIF(cs.campus_students, 0), NULL) AS expense_per_student_campus,
    COALESCE(ci.total_income / NULLIF(cs.campus_students, 0), NULL) AS income_per_student_campus,
    COALESCE(cim.incoming_mobility, 0) AS incoming_mobility_campus,
    COALESCE(om.outgoing_mobility, 0) AS outgoing_mobility_degree
FROM progress p
LEFT JOIN access a
    ON p.degree_code = a.degree_code
   AND p.center_name = a.center_name
LEFT JOIN out_mob om
    ON p.degree_code = om.degree_code
LEFT JOIN campus_students cs
    ON p.campus_id = cs.campus_id
LEFT JOIN campus_expense ce
    ON p.campus_id = ce.campus_id
LEFT JOIN campus_income ci
    ON p.campus_id = ci.campus_id
LEFT JOIN campus_in_mob cim
    ON p.campus_id = cim.campus_id
ORDER BY p.success_rate DESC;











WITH progress AS (
    SELECT 
        sp.degree_name,
        sp.degree_code,
        sp.center_code,
        ce.center_name,
        c.campus_id,
        c.campus_name,
        ce.center_type,
        dp.study_type,
        COUNT(DISTINCT sp.student_id) AS n_students,
        AVG(sp.credits_enrolled) AS avg_credits_enrolled,
        AVG(sp.credits_passed) AS avg_credits_passed,
        AVG(sp.credits_failed) AS avg_credits_failed,
        AVG(sp.credits_passed::float / NULLIF(sp.credits_enrolled, 0)) AS success_rate,
        AVG(sp.credits_failed::float / NULLIF(sp.credits_enrolled, 0)) AS failure_rate,
        AVG(CASE WHEN sp.graduated_this_year IS TRUE THEN 1 ELSE 0 END) AS graduation_rate,
        AVG(CASE WHEN sp.gender = 'Mujer' THEN 1 ELSE 0 END) AS pct_women
    FROM student_progress sp
    JOIN center ce
        ON sp.center_code = ce.center_code
    JOIN campus c
        ON ce.campus_id = c.campus_id
    LEFT JOIN degree_program dp
        ON sp.degree_code = dp.degree_code
    GROUP BY 
        sp.degree_name,
        sp.degree_code,
        sp.center_code,
        ce.center_name,
        c.campus_id,
        c.campus_name,
        ce.center_type,
        dp.study_type
),
access AS (
    SELECT 
        sa.degree_name,
        sa.degree_code,
        sa.center_code,
        ce.center_name,
        AVG(sa.admission_score) AS avg_admission_score,
        AVG(CASE WHEN sa.gender = 'Mujer' THEN 1 ELSE 0 END) AS pct_women_access,
        AVG(
            CASE
                WHEN sa.mother_education IN ('Estudios Primarios', 'Estudios Secundarios')
                  OR sa.father_education IN ('Estudios Primarios', 'Estudios Secundarios')
                THEN 1 ELSE 0
            END
        ) AS pct_low_background
    FROM student_access sa
    JOIN center ce
        ON sa.center_code = ce.center_code
    GROUP BY 
        sa.degree_name,
        sa.degree_code,
        sa.center_code,
        ce.center_name
),
campus_students AS (
    SELECT 
        c.campus_id,
        COUNT(DISTINCT sp.student_id) AS total_students_campus
    FROM campus c
    JOIN center ce
        ON c.campus_id = ce.campus_id
    JOIN student_progress sp
        ON ce.center_code = sp.center_code
    GROUP BY c.campus_id
),
campus_mobility AS (
    SELECT 
        campus_id,
        COUNT(*) AS incoming_students_campus
    FROM incoming_mobility
    GROUP BY campus_id
)
SELECT 
    p.degree_name,
    p.center_name,
    p.campus_name,
    p.center_type,
    p.study_type,
    p.n_students,
    p.avg_credits_enrolled,
    p.avg_credits_passed,
    p.avg_credits_failed,
    p.success_rate,
    p.failure_rate,
    p.graduation_rate,
    p.pct_women,
    a.avg_admission_score,
    a.pct_women_access,
    a.pct_low_background,
    COALESCE(cm.incoming_students_campus, 0) AS incoming_students_campus,
    COALESCE(cs.total_students_campus, 0) AS total_students_campus,
    ROUND(
        COALESCE(cm.incoming_students_campus, 0)::numeric / NULLIF(cs.total_students_campus, 0),
        4
    ) AS mobility_ratio
FROM progress p
LEFT JOIN access a
    ON p.degree_code = a.degree_code
   AND p.center_code = a.center_code
LEFT JOIN campus_students cs
    ON p.campus_id = cs.campus_id
LEFT JOIN campus_mobility cm
    ON p.campus_id = cm.campus_id
WHERE p.n_students >= 30
ORDER BY p.degree_name, p.success_rate DESC;