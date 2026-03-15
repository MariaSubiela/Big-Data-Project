CREATE TABLE income (
    income_id SERIAL PRIMARY KEY,
    year INT,
    chapter TEXT,
    article TEXT,
    concept TEXT,
    subconcept TEXT,
    campus_id INT,
    budget_amount FLOAT,
    recognized_rights FLOAT,
    net_collection FLOAT,
    FOREIGN KEY (campus_id) REFERENCES campus(campus_id)
);

INSERT INTO income (
    year,
    chapter,
    article,
    concept,
    subconcept,
    campus_id,
    budget_amount,
    recognized_rights,
    net_collection
)
SELECT
    anio AS year,
    des_capitulo AS chapter,
    des_articulo AS article,
    des_concepto AS concept,
    des_subconcepto AS subconcept,
    campus_id AS campus_id,
    credito_total AS budget_amount,
    derechos_reconocidos_netos AS recognized_rights,
    recaudacion_neta AS net_collection
FROM raw_income;