CREATE TABLE student_access (
    access_id SERIAL PRIMARY KEY,
    academic_year VARCHAR(20),
    center_code INT,
    center_name VARCHAR(100),
    degree_code INT,
    degree_name TEXT,
    admission_score FLOAT,
    admission_type TEXT,
    birth_year INT,
    gender VARCHAR(20),
    mother_education TEXT,
    mother_occupation TEXT,
    father_education VARCHAR(100),
    father_occupation TEXT,
    FOREIGN KEY (center_code) REFERENCES center(center_code),
    FOREIGN KEY (degree_code) REFERENCES degree_program(degree_code)
);

INSERT INTO student_access (
    academic_year,
    center_code,
    center_name,
    degree_code,
    degree_name,
    admission_score,
    admission_type,
    birth_year,
    gender,
    mother_education,
    mother_occupation,
    father_education,
    father_occupation
)
SELECT
    curso_academico AS academic_year,
    cod_centro AS center_code,
    des_centro AS center_name,
    cod_titulacion AS degree_code,
    des_titulacion AS degree_name,
    nota_admision AS admission_score,
    des_forma_admision AS admission_type,
    anio_nacimiento AS birth_year,
    des_genero AS gender,
    des_nivel_estudios_madre AS mother_education,
    des_ocupacion_madre AS mother_occupation,
    des_nivel_estudios_padre AS father_education,
    des_ocupacion_padre AS father_occupation
FROM raw_student_access;