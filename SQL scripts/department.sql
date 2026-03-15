CREATE TABLE department (
	department_id INT PRIMARY KEY,
    department_name VARCHAR(150),
    campus_id INT,
    status VARCHAR(50),
    FOREIGN KEY (campus_id) REFERENCES campus(campus_id)
);

INSERT INTO department (
    department_id,
    department_name,
    campus_id,
    status
)
SELECT
    cod_departamento AS department_id,
    des_departamento AS department_name,
    cod_campus AS campus_id,
    des_situacion_departamento AS status
FROM raw_department;