-- Success rate by campus

SELECT 
    c.campus_name,
    SUM(sp.credits_passed) / SUM(sp.credits_enrolled) AS success_rate
FROM student_progress sp
JOIN center ce ON sp.center_code = ce.center_code
JOIN campus c ON ce.campus_id = c.campus_id
GROUP BY c.campus_name
ORDER BY success_rate DESC

-- Aranjuez's results seem to be suspiciously high. As a result, we constructed further analysis to find possible explanations for this outlier.

SELECT 
    c.campus_name,
    count(*) AS students_per_campus
FROM student_progress sp
JOIN center ce ON sp.center_code = ce.center_code
JOIN campus c ON ce.campus_id = c.campus_id
GROUP BY c.campus_name;

-- As we can see from the results, Aranjuez has a very small number of students, which explains most of the reason as to why the success rate is so high. 
-- However, we want to assess if there could be other reasons like the existence of specific programs (postgraduate or easier grading), or perhaps missing data (missing failed credits)
-- We immediately ruled out the possibility of there being missing data as we cleaned the datasets before they were used and used data imputation to fill or replace missing values

SELECT  -- Inspect which programs Aranjuez has and whether those programs are postgraduate or not
    sp.degree_code,
    sp.degree_name,
    dp.study_type,
    COUNT(*) AS student_count,
    SUM(sp.credits_enrolled) AS total_enrolled,
    SUM(sp.credits_passed) AS total_passed,
    SUM(sp.credits_failed) AS total_failed,
    SUM(sp.credits_passed)::float / NULLIF(SUM(sp.credits_enrolled), 0) AS success_rate
FROM student_progress sp
JOIN center ce ON sp.center_code = ce.center_code
JOIN campus c ON ce.campus_id = c.campus_id
LEFT JOIN degree_program dp ON sp.degree_code = dp.degree_code
WHERE c.campus_name = 'Aranjuez'
GROUP BY sp.degree_code, sp.degree_name, dp.study_type
ORDER BY dp.study_type, student_count DESC;

-- There is no relation between failures and study type (graduate and master), though it is true that masters show a lower number of students
-- We can conclude that the near-perfect academic performance observed in Aranjuez is primarily driven by its highly specialized program offering and limited student population. 
-- The campus concentrates on security-related degrees, which exhibit extremely low failure rates. 
-- Therefore, its performance is not directly comparable to larger, more diverse campuses.



-- Failure rate by degree

SELECT 
    degree_name,
    SUM(credits_failed) / SUM(credits_enrolled) AS failure_rate,
    COUNT(*) as students_per_degree
FROM student_progress
GROUP BY degree_name
ORDER BY failure_rate DESC;

-- Two degrees showed unusually large failure rates of over double the other degrees, but this observation was not caused 
-- by the number of students as they were higher than many other degrees with more normal rates
-- It is true that the first modality is "semipresencial" which could have affected the performance of students.
-- As for the second degree, it is actually a master that, though not shown in the dataset, is also "semipresencial". 

-- At the same time, there are also outliers in the other side of the spectrum. There are some studies with a failure_rate of 0. 
-- As the following query will show, this is not because of the amount of students or the number of credits enrolled per student in each degree. 
-- Instead, this may be due to structural differences between grado and master. Hence, it is worth performing clustering analysis for grado and master independently.
-- This will help us reveal the different structural groups present in the data, but first, lets check the following.



-- Summary of credits enrolled per degree

SELECT 
    degree_name,
    AVG(credits_enrolled) AS avg_enrolled,
    MIN(credits_enrolled),
    MAX(credits_enrolled),
    SUM(credits_failed) / SUM(credits_enrolled) AS failure_rate,
    COUNT(*) as students_per_degree
FROM student_progress
WHERE degree_name IN (
    SELECT degree_name
    FROM student_progress
    GROUP BY degree_name
)
GROUP BY degree_name
ORDER BY failure_rate ASC;

-- There seems to be a pattern related to the type of study and the performance of students in that specific study. So, to study this difference, 
-- we decided to compare their performance by aggregating the results using the following query.    



-- Compare performance by study type

SELECT 
    dp.study_type,
    COUNT(*) AS total_students,
    SUM(sp.credits_passed)::float / SUM(sp.credits_enrolled) AS success_rate,
    SUM(sp.credits_failed)::float / SUM(sp.credits_enrolled) AS failure_rate
FROM student_progress sp
JOIN degree_program dp ON sp.degree_code = dp.degree_code
GROUP BY dp.study_type
ORDER BY dp.study_type;

-- Overall, many masters have students with 0 failures, while normal degrees tend to show some variability. 
-- The results of the previous query clearly show better performance rates for master degrees. 
-- But at the same time, there are 6 times more students in grado than in masters. This difference in outcome does not imply that the masters are better. 
-- There is a structural difference and perhaps are designed so that: Smaller / selected students + Already filtered 
-- (they passed GRADO to enter) + More guided / structured + Failure is rare or discouraged. Basically, it is not performance based. 



-- Graduation rate by center (with campus_name and n_students)

SELECT 
    c.campus_name,
    ce.center_name,
    COUNT(*) AS n_students,
    AVG(CASE 
        WHEN sp.graduated_this_year THEN 1 
        ELSE 0 
    END) AS graduation_rate
FROM student_progress sp
JOIN center ce ON sp.center_code = ce.center_code
JOIN campus c ON ce.campus_id = c.campus_id
GROUP BY c.campus_name, ce.center_name
ORDER BY graduation_rate DESC;

-- Regardless of the campus, the Facultad de Ciencias Sociales y Juridicas has a very low graduation rate compared to the rest of the centers.
-- Then, it appears that Leganés has 2 centers dedicated to EPS. However, one is dedicated to GRADO, while the other to POSTGRADO. 
-- Before, we came to the conclusion that, because of structural differences, masters were designed to have a lower failure rate. 
-- This same idea is reinforced in this analysis as, once again, the POSTGRADO has a higher graduation rate for the same institutional unit.
-- One thing worth noting is that highly specialised degrees (with few students) and centers tend to have higher success and graduation rates.
-- For example, in the previous query, Centro Universitario Guardia Civil had the highest graduation_rate of ~0.66.



-- Graduation rate by campus

SELECT 
    c.campus_name,
    AVG(CASE 
        WHEN sp.graduated_this_year THEN 1 
        ELSE 0 
    END) AS avg_graduation_rate
FROM student_progress sp
JOIN center ce ON sp.center_code = ce.center_code
JOIN campus c ON ce.campus_id = c.campus_id
GROUP BY c.campus_name
ORDER BY avg_graduation_rate DESC;

-- The same structural difference applies to performance rates by center type ("centros adscritos" vs "centros propios") as the first ones are small, specialized, 
-- selective and therefore lead to higher performance

SELECT 
    center_type,
    COUNT(*) AS n_students,
    AVG(credits_passed::float / NULLIF(credits_enrolled,0)) AS success_rate,
    AVG(credits_failed::float / NULLIF(credits_enrolled,0)) AS failure_rate,
    AVG(CASE WHEN graduated_this_year THEN 1 ELSE 0 END) AS graduation_rate
FROM student_progress sp
JOIN center ce ON sp.center_code = ce.center_code
GROUP BY center_type
ORDER BY success_rate DESC;

-- From these past two queries we can therefore infer that performance differences are not primarily caused by where students study (campus/center), but by what they study (degree type, structure, difficulty and inherent 
-- student differences). Nevertheless, there are still some noticeable differences between campuses. Just like we saw before with the success_rate, Aranjuez has the 
-- highest average graduation rate.

-- However, to further assess whether these differences are truly driven by campuses, we performed a final check by comparing the performance of those degrees that 
-- appeared in more than one different center



-- Success rate of same degrees in two different centers

SELECT 
    degree_name,
    center_name,
    AVG(credits_passed::float / NULLIF(credits_enrolled, 0)) AS success_rate
FROM student_progress
WHERE degree_name IN (
    SELECT degree_name
    FROM student_progress
    GROUP BY degree_name
    HAVING COUNT(DISTINCT center_name) > 1
)
GROUP BY degree_name, center_name
ORDER BY degree_name, success_rate DESC;

-- The results show that the same degree can exhibit different success rates depending on the campus where it is taught. In particular, degrees such as “Doble Grado 
-- en Derecho y Administración de Empresas”, “Grado en Administración de Empresas”, and “Grado en Derecho” consistently perform better in Getafe. This occurs despite 
-- Getafe having a lower overall average success rate than Colmenarejo, suggesting that local factors at the campus or center level may still influence outcomes.
-- Having said this, a more complex analysis will be performed on these degrees to see which factors may be affecting their performance (in "Combined queries" sql script). 

-- After performing other types of analysis, we moved on to explore whether there were differences in academic performance by gender.  We began by looking at the following:



-- Overall student success rate per gender

SELECT 
    gender,
    AVG(credits_passed::float / credits_enrolled) AS success_rate
FROM student_progress
GROUP BY gender
ORDER BY success_rate desc;

-- From this query, we observe that female students have a higher average success rate (~93%) compared to male students (~89%). 
-- At first glance, this suggests that women perform better academically. However, before drawing conclusions, we considered whether this difference could 
-- be explained by an imbalance in the number of students.



-- Gender distribution

SELECT 
    gender,
    COUNT(*) AS n_students,
    ROUND(COUNT(*)::numeric / SUM(COUNT(*)) OVER (), 4
    ) AS pct_students
FROM student_progress
GROUP BY gender
ORDER BY n_students DESC;

-- From this, we know that the gender split is relatively balanced, with approximately 52% women and 48% men. Therefore, the observed difference in performance cannot 
-- be attributed to overrepresentation of one group, which suggests that the gap may reflect a real difference in academic outcomes.
-- To further investigate whether this pattern was consistent or driven by a small number of degrees, we analyzed the gender performance gap at the degree level



-- Gender performance gap by degree. 

WITH gender_perf AS (
    SELECT 
        degree_name,
        gender,
        COUNT(*) AS n_students,
        AVG(credits_passed::float / credits_enrolled) AS success_rate
    FROM student_progress
    GROUP BY degree_name, gender
    HAVING COUNT(*) >= 30
)
SELECT 
    d1.degree_name,
    d1.n_students AS female_students,
    d2.n_students AS male_students,
    d1.success_rate AS female_success,
    d2.success_rate AS male_success,
    (d1.success_rate - d2.success_rate) AS diff
FROM gender_perf d1
JOIN gender_perf d2
    ON d1.degree_name = d2.degree_name
WHERE d1.gender = 'Mujer'
  AND d2.gender = 'Hombre'
ORDER BY diff DESC;

-- In this query, we filtered out degrees with fewer than 30 students per gender to ensure that the results are statistically meaningful. 
-- The results show that in 36 out of 48 degrees (75%), female students achieve higher success rates than male students. This confirms that the difference observed 
-- earlier is not an isolated phenomenon, but rather a consistent pattern across the majority of programs. Having established that the performance gap is both real and 
-- widespread, we then explored possible explanations. One hypothesis was that female students might enter university with stronger academic backgrounds, 
-- which could partially explain their higher success rates. To test this, we examined the average admission score by gender.



-- Student access per gender

SELECT 
    gender,
    AVG(admission_score) AS avg_admission
FROM student_access
GROUP BY gender;

-- The results indicate that women have a slightly higher average admission score (~12.5) compared to men (~12.2). While this suggests that female students may enter 
-- with a marginal academic advantage, the difference is relatively small and does not fully account for the performance gap observed in university outcomes.
-- Finally, we considered whether this difference could be influenced by structural factors, such as the type of study (GRADO vs MASTER), as previous analyses showed 
-- significant differences between these categories. To evaluate this, we compared success rates by study type and gender.



-- Success rate per study type per gender

SELECT 
    study_type,
    gender,
    AVG(credits_passed::float / credits_enrolled) AS success_rate
FROM student_progress sp
JOIN degree_program dp 
    ON sp.degree_code = dp.degree_code
GROUP BY study_type, gender
order by dp.study_type;

-- The results show that female students outperform male students in both GRADO and MASTER programs. This indicates that the gender performance gap is consistent across 
-- different types of studies and is not driven by structural differences between program levels. In conclusion, despite a nearly balanced gender distribution, female students 
-- consistently achieve higher academic success rates. This pattern is observed across most degrees (75%) and remains stable across both undergraduate and postgraduate programs. 
-- While slightly higher admission scores for women may contribute to this difference, they do not fully explain it, suggesting that other factors—such as study behavior, 
-- motivation, or program engagement—may play a role.
