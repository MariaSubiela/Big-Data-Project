CREATE TABLE student_progress (
    student_id SERIAL PRIMARY KEY,
    academic_year VARCHAR(20),
    center_code INT,
    degree_code INT,
    birth_year INT,
    gender VARCHAR(20),
    nationality_country VARCHAR(100),
    nationality_continent VARCHAR(100),
    study_mode VARCHAR(100),
    credits_enrolled FLOAT,
    credits_passed FLOAT,
    credits_failed FLOAT,
    graduated_this_year VARCHAR(20),
    FOREIGN KEY (center_code) REFERENCES center(center_code),
    FOREIGN KEY (degree_code) REFERENCES degree_program(degree_code)
);

INSERT INTO student_progress (
    academic_year,
    center_code,
    degree_code,
    birth_year,
    gender,
    nationality_country,
    nationality_continent,
    study_mode,
    credits_enrolled,
    credits_passed,
    credits_failed,
    graduated_this_year
)
SELECT
    curso_academico AS academic_year,
    cod_centro AS center_code,
    cod_titulacion AS degree_code,
    anio_nacimiento AS birth_year,
    des_genero AS gender,
    des_pais_nacionalidad AS nationality_country,
    des_continente_nacionalidad AS nationality_continent,
    des_dedicacion AS study_mode,
    num_total_creditos_mat_curso AS credits_enrolled,
    num_total_creditos_sup_curso AS credits_passed,
    num_total_creditos_no_sup_curso AS credits_failed,
    ind_se_titula_curso AS graduated_this_year
FROM raw_student_progress;