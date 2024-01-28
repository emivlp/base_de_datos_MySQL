# EJERCICIO 1 

# Lenguaje DDL
#creamos la BBDD (base de datos) 

USE `préstamos_ucm`; 

#creamos la tabla 
CREATE TABLE `préstamos_ucm`.orders (
	order_id VARCHAR(45) PRIMARY KEY,
    created_at DATETIME,
    status VARCHAR(10),
    amount DECIMAL,
    merchant_id_or VARCHAR(45),
    country VARCHAR (10)
    );

CREATE TABLE `préstamos_ucm`.refunds (
	order_id VARCHAR(45),
    refunded_at DATETIME,
    amount DECIMAL 
    );

CREATE TABLE `préstamos_ucm`.merchants (
	merchant_id_mer VARCHAR(45) PRIMARY KEY,
    name_merchant VARCHAR(45)
    );

SHOW DATABASES;
SHOW TABLES FROM `préstamos_ucm`;

# EJERCICIO 2.(1)  

SELECT # Seleccion de columnas 
	country,
    status AS estado_operación, 
    COUNT(order_id) AS total_operaciones,
    AVG(amount) AS importe_promedio 
    
FROM `préstamos_ucm`.orders 

WHERE # Condisiones a filtrar en las filas 
	created_at > '2015-07-01' 
    AND country IN ('Francia', 'Portugal', 'Espana')
    AND amount > 100
    AND amount < 1500
GROUP BY country, estado_operación
ORDER BY importe_promedio DESC; 

# 2.(2)  

SELECT 
	country,
    COUNT(order_id) AS total_operaciones,
    MAX(amount) AS operación_valor_máximo,
    MIN(amount) AS operación_valor_mínimo
    
FROM `préstamos_ucm`.orders 

WHERE 
	status NOT IN ('Delinquent', 'Cancelled') # no incluye deudores y operaciones canceladas
    AND amount > 100 # operaciones valor mayor a 100€

GROUP BY country
ORDER BY total_operaciones DESC 
LIMIT 3; 

# EJERCICIO 3.(1)

SELECT
    M.name_merchant AS nombre_comercio, # M. para saber que provine de la columna merchants
    M.merchant_id_mer AS id_comercio,
    O.country AS país, # O. para saber que provine de la columna orders
    COUNT(O.order_id) AS total_operaciones,
    AVG(O.amount) AS valor_promedio, 
    SUM(IF(R.total_devoluciones > 0, 1, 0)) AS total_devoluciones, # calcula valor promedio de las op. para cada comercio y país
    CASE # condicion CASE para etiquetar las consultas
        WHEN SUM(IF(R.total_devoluciones > 0, 1, 0)) > 0 THEN 'Sí'
        ELSE 'No'
    END AS acepta_devoluciones
FROM `préstamos_ucm`.merchants AS M
LEFT JOIN `préstamos_ucm`.orders AS O ON M.merchant_id_mer = O.merchant_id_or
LEFT JOIN (
    SELECT order_id, COUNT(*) AS total_devoluciones
    FROM `préstamos_ucm`.refunds
    GROUP BY order_id
) AS R ON O.order_id = R.order_id
WHERE
    O.country IN ('Marruecos', 'Italia', 'España', 'Portugal')
GROUP BY M.name_merchant, M.merchant_id_mer, O.country
HAVING total_operaciones > 10
ORDER BY total_operaciones ASC;

# 3.(2) 

# Crea la vista orders_view
CREATE VIEW préstamos_ucm.orders_view AS
SELECT
    O.*, # Todos los campos de la tabla orders
    M.*, # Todos los campos de la tabla merchants
    COUNT(R.order_id) AS total_devoluciones, # Conteo de devoluciones por operación
    SUM(IFNULL(R.amount, 0)) AS suma_valor_devoluciones # Suma del valor de las devoluciones
FROM `préstamos_ucm`.orders AS O
LEFT JOIN `préstamos_ucm`.merchants AS M ON O.merchant_id_or = M.merchant_id_mer
LEFT JOIN (
    SELECT order_id, COUNT(*) AS total_devoluciones, SUM(amount) AS amount
    FROM `préstamos_ucm`.refunds
    GROUP BY order_id
) AS R ON O.order_id = R.order_id
GROUP BY O.order_id;


# EJERCICIO 4 
SELECT
    M.name_merchant AS Nombre_comerciante,
    O.country AS País,
    O.order_id AS ID_orden,
    SUM(O.amount) AS Monto_total,
    CASE
        WHEN SUM(O.amount) > 200 THEN 'Operación Delictiva'
        ELSE 'Operación No Delictiva'
    END AS Categoría_de_operación,
    O.status AS Estado_operación,
    R.order_id AS ID_reembolso
FROM `préstamos_ucm`.orders AS O
LEFT JOIN `préstamos_ucm`.merchants AS M ON O.merchant_id_or = M.merchant_id_mer
LEFT JOIN `préstamos_ucm`.refunds AS R ON O.order_id = R.order_id
WHERE DATE_FORMAT(O.created_at, '%Y') = '2015' AND O.status IN ('delinquent', 'cancelled')
GROUP BY M.name_merchant, O.country, O.order_id, O.status, R.order_id
ORDER BY Categoría_de_operación ASC, Monto_total DESC, Estado_operación ASC;

