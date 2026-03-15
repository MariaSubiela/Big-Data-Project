CREATE TABLE center (
    center_code INT PRIMARY KEY,
    center_name VARCHAR(150) NOT NULL,
    campus_id INT,
    campus_name VARCHAR(150) NOT NULL,
    center_type VARCHAR(100),
    legal_nature VARCHAR(100),
    center_status VARCHAR(50),
    FOREIGN KEY (campus_id) REFERENCES campus(campus_id)
);

INSERT INTO center (
    center_code,
    center_name,
    campus_id,
    campus_name,
    center_type,
    legal_nature,
    center_status
)
SELECT
    cod_centro AS center_code,
    des_centro AS center_name,
    id_campus as campus_id,
    des_campus AS campus_name,
    des_tipo_centro AS center_type,
    des_naturaleza_centro AS legal_nature,
    des_situacion_centro AS center_status
FROM raw_center;