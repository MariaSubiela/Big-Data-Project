CREATE TABLE campus (
    campus_id INT PRIMARY KEY,
    campus_name VARCHAR(100)
);

INSERT INTO campus (campus_id, campus_name) VALUES
(1, 'Getafe'),
(2, 'Leganes'),
(3, 'Colmenarejo'),
(4, 'Madrid'),
(5, 'Aranjuez'),
(6, 'Intercampus');

DELETE FROM campus;

INSERT INTO campus (campus_id, campus_name)
SELECT DISTINCT cod_campus, des_campus
FROM raw_center
WHERE cod_campus IS NOT NULL
  AND des_campus IS NOT NULL;

INSERT INTO campus (campus_id, campus_name)
VALUES (6, 'Intercampus')
ON CONFLICT (campus_id) DO NOTHING;