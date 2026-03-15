CREATE TABLE incoming_mobility (
    mobility_id SERIAL PRIMARY KEY,
    academic_year VARCHAR(20),
    mobility_program_type VARCHAR(100),
    mobility_program VARCHAR(100),
    gender VARCHAR(20),
    birth_year INT,
    nationality_country VARCHAR(100),
    nationality_continent VARCHAR(100),
    origin_university TEXT,
    origin_country VARCHAR(100),
    origin_continent VARCHAR(100),
    campus_id INT,
    destination_study_level VARCHAR(100),
    FOREIGN KEY (campus_id) REFERENCES campus(campus_id)
);

INSERT INTO incoming_mobility (
    academic_year,
    mobility_program_type,
    mobility_program,
    gender,
    birth_year,
    nationality_country,
    nationality_continent,
    origin_university,
    origin_country,
    origin_continent,
    campus_id,
    destination_study_level
)
SELECT
    curso_academico AS academic_year,
    des_tipo_programa_mov AS mobility_program_type,
    des_programa_movilidad AS mobility_program,
    des_genero AS gender,
    anio_nacimiento AS birth_year,
    des_pais_nacionalidad AS nationality_country,
    des_continente_nacionalidad AS nationality_continent,
    des_universidad_procedencia AS origin_university,
    des_pais_univ_procedencia AS origin_country,
    des_continente_univ_procedencia AS origin_continent,
    campus_id AS campus_id,
    des_nivel_formativo_destino AS destination_study_level
FROM raw_incoming_mobility;