CREATE TABLE admin_staff (
    staff_id INT PRIMARY KEY,
    year INT,
    gender VARCHAR(20),
    service_unit VARCHAR(100),
    staff_type VARCHAR(100),
    contract_type VARCHAR(100),
    dedication_type VARCHAR(100),
    admin_status VARCHAR(100),
    teaches_flag BOOLEAN,
    seniority_periods INT
);

INSERT INTO admin_staff (
	staff_id,
    year,
    gender,
    service_unit,
    staff_type,
    contract_type,
    dedication_type,
    admin_status,
    teaches_flag,
    seniority_periods
)
select
	staff_id as staff_id,
    anio AS year,
    des_genero AS gender,
    des_servicio_prestado AS service_unit,
    des_tipo_personal AS staff_type,
    des_tipo_contrato AS contract_type,
    des_dedicacion AS dedication_type,
    des_situacion_administrativa AS admin_status,
    ind_imparte_docencia AS teaches_flag,
    num_trienios AS seniority_periods
FROM raw_admin_staff;