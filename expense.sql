CREATE TABLE expense (
    expense_id SERIAL PRIMARY KEY,
    year INT,
    chapter TEXT,
    article TEXT,
    concept TEXT,
    subconcept TEXT,
    campus_id INT,
    subfunction TEXT,
    budget_item_code VARCHAR(100),
    program_name TEXT,
    budget_amount FLOAT,
    recognized_obligations FLOAT,
    net_payments FLOAT,
    FOREIGN KEY (campus_id) REFERENCES campus(campus_id)
);

INSERT INTO expense (
    year,
    chapter,
    article,
    concept,
    subconcept,
    campus_id,
    subfunction,
    budget_item_code,
    program_name,
    budget_amount,
    recognized_obligations,
    net_payments
)
SELECT
    anio AS year,
    des_capitulo AS chapter,
    des_articulo AS article,
    des_concepto AS concept,
    des_subconcepto AS subconcept,
    campus_id AS campus_id,
    des_subfuncion AS subfunction,
    des_servicio AS budget_item_code,
    des_programa AS program_name,
    credito_total AS budget_amount,
    obligaciones_reconocidas AS recognized_obligations,
    pagos_netos AS net_payments
FROM raw_expense;