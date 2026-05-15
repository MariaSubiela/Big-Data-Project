
-- Total number of Incoming and Outgoing mobility students

WITH mobility_counts AS (
    SELECT 'Incoming' AS mobility_direction, COUNT(*) AS n_students
    FROM incoming_mobility
    UNION ALL
    SELECT 'Outgoing' AS mobility_direction, COUNT(*) AS n_students
    FROM outgoing_mobility
)
SELECT
    mobility_direction,
    n_students,
    n_students::float / SUM(n_students) OVER () AS share
FROM mobility_counts;

-- The results show that UC3M receives more mobility students than it sends abroad. This suggests that UC3M is more of an importing institution than 
-- an exporting one in terms of mobility, which already points to a strong international attractiveness.
-- To better understand where this mobility is concentrated, we analyzed the following:



-- Incoming students by campus.

WITH campus_students AS (
    SELECT 
        c.campus_id,
        c.campus_name,
        COUNT(DISTINCT sp.student_id) AS total_students
    FROM campus c
    LEFT JOIN center ce 
        ON c.campus_id = ce.campus_id
    LEFT JOIN student_progress sp 
        ON ce.center_code = sp.center_code
    GROUP BY c.campus_id, c.campus_name
)
SELECT 
    c.campus_name,
    COUNT(im.mobility_id) AS incoming_students,
    cs.total_students,
    COUNT(im.mobility_id)::float / NULLIF(cs.total_students, 0) AS mobility_ratio
FROM campus c
LEFT JOIN incoming_mobility im 
    ON c.campus_id = im.campus_id
LEFT JOIN campus_students cs 
    ON c.campus_id = cs.campus_id
GROUP BY 
    c.campus_name,
    cs.total_students
HAVING 
    COALESCE(cs.total_students, 0) > 0
    OR COUNT(im.mobility_id) > 0
ORDER BY incoming_students DESC;

-- This query shows that incoming mobility is highly concentrated in both Leganés and Getafe while Colmenarejo and Aranjuez have no incoming mobility at all. 
-- This alone is not enough to conclude that mobility improves or worsens academic performance, because campus-level results are also affected 
-- by structural factors such as the type of degrees offered, student selection, and program difficulty. For that reason, campus mobility should be 
-- interpreted as a contextual pattern rather than a direct performance driver.



-- Type of mobility program

SELECT
    mobility_program,
    COUNT(*) AS incoming_students
FROM incoming_mobility
GROUP BY mobility_program
ORDER BY incoming_students DESC;

-- Differently to what we would expect from a European university and to the pattern that other universities display, the incoming mobility flow is clearly not Erasmus-driven. 
-- Most incoming students come from “Otras Fuera de la UE”. This means UC3M’s incoming mobility is dominated by non-EU students, suggesting that UC3M is not only 
-- connected to Europe, but is also strongly positioned on a global scale. We also checked the mobility programs for outgoing students.

SELECT
    mobility_program,
    COUNT(*) AS outgoing_students
FROM outgoing_mobility
GROUP BY mobility_program
ORDER BY outgoing_students DESC;

-- Outgoing mobility shows a different pattern from incoming flows. While UC3M mainly attracts students from outside the EU, its own students predominantly 
-- participate in ERASMUS+ (1,109 students), with fewer going through non-EU programs. This indicates that UC3M’s mobility strategy is asymmetric: it is globally 
-- attractive for incoming students, but relies mostly on European exchanges for outgoing mobility. 



-- Nationality country of incoming students

SELECT
    nationality_country,
    COUNT(*) AS incoming_students
FROM incoming_mobility
GROUP BY nationality_country
ORDER BY incoming_students DESC;

-- From this we can see that most incoming mobility is heavily concentrated in one country, with the rest coming from a much more dispersed set of countries with 
-- relatively smaller shares. This suggests that UC3M is particularly attractive to students from that country, but it also means that its international profile 
-- depends quite strongly on a single source. If that flow were to change, it could noticeably affect the university’s overall mobility patterns.
-- We also compared outgoing mobility by campus, using the campus assigned through the dominant degree campus mapping.



-- Outgoing mobility by campus 

WITH degree_primary_campus AS (
    SELECT
        sp.degree_code,
        c.campus_id,
        c.campus_name,
        COUNT(*) AS n_students,
        ROW_NUMBER() OVER (
            PARTITION BY sp.degree_code
            ORDER BY COUNT(*) DESC
        ) AS rn
    FROM student_progress sp
    JOIN center ce
        ON sp.center_code = ce.center_code
    JOIN campus c
        ON ce.campus_id = c.campus_id
    GROUP BY sp.degree_code, c.campus_id, c.campus_name
),
outgoing_by_degree AS (
    SELECT
        degree_code,
        COUNT(*) AS outgoing_students
    FROM outgoing_mobility
    GROUP BY degree_code
)
SELECT
    dpc.campus_name,
    SUM(obd.outgoing_students) AS outgoing_students
FROM outgoing_by_degree obd
JOIN degree_primary_campus dpc
    ON obd.degree_code = dpc.degree_code
WHERE dpc.rn = 1
GROUP BY dpc.campus_name
ORDER BY outgoing_students DESC;

-- The latter query shows that outgoing mobility is also concentrated, with Leganés leading by far, followed by Getafe and Colmenarejo. 
-- Mobility is clearly not evenly distributed across the university as both incoming and outgoing flows are strongly centered in specific campuses. 
-- Mobility is not something that happens equally everywhere in the university. Instead, it depends on the campus, the degree, and how things are organized, 
-- so some students have much more access to it than others.



-- Mobility by gender

WITH gender_totals AS (
    SELECT gender, COUNT(*) AS total_students
    FROM student_progress
    GROUP BY gender
),
incoming_gender AS (
    SELECT gender, COUNT(*) AS incoming_students
    FROM incoming_mobility
    GROUP BY gender
),
outgoing_gender AS (
    SELECT gender, COUNT(*) AS outgoing_students
    FROM outgoing_mobility
    GROUP BY gender
)
SELECT
    gt.gender,
    gt.total_students,
    COALESCE(ig.incoming_students, 0) AS incoming_students,
    COALESCE(og.outgoing_students, 0) AS outgoing_students,
    COALESCE(ig.incoming_students, 0)::float / NULLIF(gt.total_students, 0) AS incoming_share,
    COALESCE(og.outgoing_students, 0)::float / NULLIF(gt.total_students, 0) AS outgoing_share
FROM gender_totals gt
LEFT JOIN incoming_gender ig ON gt.gender = ig.gender
LEFT JOIN outgoing_gender og ON gt.gender = og.gender
ORDER BY gt.gender;

-- Here, women seem to participate slightly more in mobility than men, both in terms of going abroad and coming to UC3M. This suggests that mobility is not only concentrated 
-- in certain places, but also slightly more common among female students. We then looked at mobility by degree to see whether all students have the same access 
-- to international opportunities. 



-- Mobility by degree

WITH degree_students AS (
    SELECT
        degree_name,
        COUNT(*) AS total_students
    FROM student_progress
    GROUP BY degree_name
),
outgoing_by_degree AS (
    SELECT
        sp.degree_name,
        COUNT(*) AS outgoing_students
    FROM outgoing_mobility om
    JOIN student_progress sp
        ON om.degree_code = sp.degree_code
    GROUP BY sp.degree_name
)
SELECT
    ds.degree_name,
    ds.total_students,
    COALESCE(obd.outgoing_students, 0) AS outgoing_students,
    COALESCE(obd.outgoing_students, 0)::float / NULLIF(ds.total_students, 0) AS outgoing_share
FROM degree_students ds
LEFT JOIN outgoing_by_degree obd
    ON ds.degree_name = obd.degree_name
ORDER BY outgoing_share DESC, outgoing_students DESC;

-- These results show that outgoing mobility is clearly concentrated in certain degrees, especially in business and law programs. This suggests that access 
-- to mobility depends on what students study, rather than being equally available to everyone.
-- Putting everything together, UC3M receives more students than it sends abroad, so it works more as a destination than a source of mobility. Incoming mobility 
-- is mainly concentrated in specific campuses and is driven mostly by students from outside the EU. At the same time, a large share of these students come from 
-- a single country, which makes UC3M very attractive internationally but also somewhat dependent on that source.

-- From a strategic point of view, UC3M should both strengthen its relationship with that main country and expand its connections with others. This means 
-- maintaining strong partnerships where it already succeeds, while also building new ones to reduce dependency and create a more balanced international network.


