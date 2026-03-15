CREATE TABLE degree_program (
    degree_code INT PRIMARY KEY,
    degree_name VARCHAR(200) NOT NULL,
    study_type VARCHAR(100)
);

INSERT INTO degree_program (
    degree_code,
    degree_name,
    study_type
)
SELECT
    cod_titulacion AS degree_code,
    des_titulacion AS degree_name,
    des_tipo_estudio AS study_type
FROM raw_degree_program;