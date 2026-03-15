-- Changing data types for columns with long text

ALTER TABLE raw_expense ALTER COLUMN des_capitulo TYPE TEXT;
ALTER TABLE raw_expense ALTER COLUMN des_articulo TYPE TEXT;
ALTER TABLE raw_expense ALTER COLUMN des_concepto TYPE TEXT;
ALTER TABLE raw_expense ALTER COLUMN des_subconcepto TYPE TEXT;
ALTER TABLE raw_expense ALTER COLUMN des_servicio TYPE TEXT;
ALTER TABLE raw_expense ALTER COLUMN des_subfuncion TYPE TEXT;
ALTER TABLE raw_expense ALTER COLUMN des_programa TYPE TEXT;

ALTER TABLE raw_income ALTER COLUMN des_subconcepto TYPE TEXT;
ALTER TABLE raw_income ALTER COLUMN des_articulo TYPE TEXT;
ALTER TABLE raw_income ALTER COLUMN des_concepto TYPE TEXT;
ALTER TABLE raw_income ALTER COLUMN des_capitulo TYPE TEXT;

ALTER TABLE raw_incoming_mobility ALTER COLUMN des_universidad_procedencia TYPE TEXT;

ALTER TABLE raw_outgoing_mobility ALTER COLUMN des_titulacion_origen TYPE TEXT;
ALTER TABLE raw_outgoing_mobility ALTER COLUMN des_universidad_destino TYPE TEXT;

ALTER TABLE raw_student_access ALTER COLUMN des_titulacion TYPE TEXT;
ALTER TABLE raw_student_access ALTER COLUMN des_forma_admision TYPE TEXT;
ALTER TABLE raw_student_access ALTER COLUMN des_nivel_estudios_madre TYPE TEXT;
ALTER TABLE raw_student_access ALTER COLUMN des_ocupacion_madre TYPE TEXT;
ALTER TABLE raw_student_access ALTER COLUMN des_ocupacion_padre TYPE TEXT;

ALTER TABLE raw_teaching_staff ALTER COLUMN des_dedicacion TYPE TEXT;
ALTER TABLE raw_teaching_staff ALTER COLUMN des_unidad_responsable TYPE TEXT;
ALTER TABLE raw_teaching_staff ALTER COLUMN des_tipo_contrato TYPE TEXT;

ALTER TABLE raw_student_progress ALTER COLUMN des_centro TYPE TEXT;
ALTER TABLE raw_student_progress ALTER COLUMN des_titulacion TYPE TEXT;

-- Changing boolean columns that were wrongly identified as varchar

UPDATE raw_admin_staff
SET ind_imparte_docencia = CASE
    WHEN ind_imparte_docencia = 'S' THEN 'TRUE'
    WHEN ind_imparte_docencia = 'N' THEN 'FALSE'
END;

ALTER TABLE raw_admin_staff
ALTER COLUMN ind_imparte_docencia TYPE BOOLEAN
USING ind_imparte_docencia::boolean;

UPDATE raw_teaching_staff
SET ind_investigador_principal = CASE
    WHEN ind_investigador_principal = 'S' THEN 'TRUE'
    WHEN ind_investigador_principal = 'N' THEN 'FALSE'
END;

ALTER TABLE raw_teaching_staff
ALTER COLUMN ind_investigador_principal TYPE BOOLEAN
USING ind_investigador_principal::boolean;