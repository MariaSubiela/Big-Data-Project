CREATE TABLE outgoing_mobility (
    mobility_id SERIAL PRIMARY KEY,
    academic_year VARCHAR(20),
    degree_code INT,
    degree_name TEXT,
    mobility_program_type VARCHAR(100),
    mobility_program VARCHAR(100),
    gender VARCHAR(20),
    birth_year INT,
    nationality_country VARCHAR(100),
    nationality_continent VARCHAR(100),
    destination_university TEXT,
    destination_country VARCHAR(100),
    destination_continent VARCHAR(100),
    start_month VARCHAR(20),
    end_month VARCHAR(20),
    FOREIGN KEY (degree_code) REFERENCES degree_program(degree_code)
);

INSERT INTO outgoing_mobility (
    academic_year,
    degree_code,
    degree_name,
    mobility_program_type,
    mobility_program,
    gender,
    birth_year,
    nationality_country,
    nationality_continent,
    destination_university,
    destination_country,
    destination_continent,
    start_month,
    end_month
)
SELECT
    curso_academico AS academic_year,
    cod_titulacion_origen AS degree_code,
    des_titulacion_origen AS degree_name,
    des_tipo_programa_mov AS mobility_program_type,
    des_programa_movilidad AS mobility_program,
    des_genero AS gender,
    anio_nacimiento AS birth_year,
    des_pais_nacionalidad AS nationality_country,
    des_continente_nacionalidad AS nationality_continent,
    des_universidad_destino AS destination_university,
    des_pais_univ_destino AS destination_country,
    des_continente_univ_destino AS destination_continent,
    mes_inicio_programa AS start_month,
    mes_fin_programa AS end_month
FROM raw_outgoing_mobility;