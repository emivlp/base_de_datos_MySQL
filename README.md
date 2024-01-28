# base_de_datos_MySQL
Base de datos MySQL 

Índice

Ejercicio 1: 
-	Modelo Entidad-Relación y Modelo físico…………… 3
-	Texto de las consultas de creación de la bases de datos y el esquema……………………………… 4

Ejercicio 2 y 3: 
-	Enunciado………………………………… 
-	Texto de la query…………………………… 5
-	Captura de la query y el insight………………………… 6-10

Ejercicio 4: 
-	Párrafo explicando brevemente la funcionalidad desarrollada………………………………………… 
-	Texto de la query………………………………11
-	Captura de la query y el insight………………………… 12
-	Párrafo reflexionando de forma concisa sobre el insight obtenido…………………………














Ejercicio 1.

Modelo de Entidad-Relación:

 


Modelo Lógico: 

 


Modelo de Físico: 

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
















Ejercicio 2. 

A partir de las tablas incluidas en la base de datos préstamos, vamos a realizar las siguientes 
consultas: 
1-	Realizamos una consulta donde obtengamos por país y estado de operación, el total de operaciones y su importe promedio. La consulta debe cumplir las siguientes condiciones: 

a. Operaciones posteriores al 01-07-2015
b. Operaciones realizadas en Francia, Portugal y España.
c. Operaciones con un valor mayor de 100 € y menor de 1500€ 
Ordenamos los resultados por el promedio del importe de manera descendente.

2- Realizamos una consulta donde obtengamos los 3 países con el mayor número de operaciones, el total de operaciones, la operación con un valor máximo y la operación con el valor mínimo para cada país. La consulta debe cumplir las siguientes condiciones: 
a. Excluimos aquellas operaciones con el estado “Delinquent” y “Cancelled” 
b. Operaciones con un valor mayor de 100 € 


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



Captura de la query y el insight; Ejercicio 2.1 
 



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


Captura de la query y el insight; Ejercicio 2.2

 




















Ejercicio 3.
A partir de las tablas incluidas en la base de datos prestamos_ucm vamos a realizar las siguientes consultas: 
1-	Realizamos una consulta donde obtengamos, por país y comercio, el total de operaciones, su valor promedio y el total de devoluciones. La consulta debe cumplir las siguientes condiciones: 
a. Se debe mostrar el nombre y el id del comercio.
b. Comercios con más de 10 ventas.
c. Comercios de Marruecos, Italia, España y Portugal.
d. Creamos un campo que identifique si el comercio acepta o no devoluciones. Si no acepta (total de devoluciones es igual a cero) el campo debe contener el valor “No” y si sí lo acepta (total de devoluciones es mayor que cero) el campo debe contener el valor “Sí”. Llamaremos al campo “acepta_devoluciones”. 
Ordenamos los resultados por el total de operaciones de manera ascendente. 
2-	Realizamos una consulta donde vamos a traer todos los campos de las tablas operaciones y comercios. De la tabla devoluciones vamos a traer el conteo de devoluciones por operación y la suma del valor de las devoluciones. Una vez tengamos la consulta anterior, creamos una vista con el nombre orders_view dentro del esquema tarea_ucm con esta consulta. 
Nota: La tabla refunds contiene más de una devolución por operación por lo que, para hacer el cruce, es muy importante que agrupemos las devoluciones. 
 
# EJERCICIO 3.(1)

SELECT
    M.name_merchant AS nombre_comercio, # M. para saber que provine de la columna merchants
    M.merchant_id_mer AS id_comercio,
    O.country AS país, # O. para saber que provine de la columna orders
    COUNT(O.order_id) AS total_operaciones,
    AVG(O.amount) AS valor_promedio, 
    SUM(IF(R.total_devoluciones > 0, 1, 0)) AS total_devoluciones, # calcula valor promedio de las op. para cada comercio y país
    CASE 
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

Captura de la query y el insight; Ejercicio 3.1

 
# EJERCICIO 3.(2) 

# Crea la vista orders_view

CREATE VIEW préstamos_ucm.orders_view AS
SELECT
    O.*, # Todos los campos de la tabla orders
    M.*, # Todos los campos de la tabla merchants
    COUNT(R.order_id) AS total_devoluciones, -- Conteo de devoluciones por operación
    SUM(IFNULL(R.amount, 0)) AS sordersuma_valor_devoluciones -- Suma del valor de las devoluciones
FROM `préstamos_ucm`.orders AS O
LEFT JOIN `préstamos_ucm`.merchants AS M ON O.merchant_id_or = M.merchant_id_mer
LEFT JOIN (
    SELECT order_id, COUNT(*) AS total_devoluciones, SUM(amount) AS amount
    FROM `préstamos_ucm`.refunds
    GROUP BY order_id
) AS R ON O.order_id = R.order_id
GROUP BY O.order_id;
Captura de la query y el insight; Ejercicio 3.2
 





Ejercicio 4.

A partir de los datos disponibles diseñar una funcionalidad a tu elección que permita obtener un insight de interés sobre el caso de uso estudiado. 
Para ello debes plantear primeramente en un breve texto el objetivo de tu funcionalidad, la queries desarrollada y una reflexión sobre el insight obtenido. Para ello puedes usar cualquier recurso estudiado en clase. 
Algunos ejemplos de funcionalidad podría ser: segmentación de clientes en función del valor de las operaciones, sistema de alertas para operaciones delictivas, identificación de estacionalidad, etc.. Tienes libertad total para desarrollar tu funcionalidad, lo importante es que tenga tu sello personal. 

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



La siguiente funcionalidad responde cuáles operaciones pueden ser sospechosas o delictivas. Para esto los insights que se esperan son a partir de; la segmentación de clientes en función del; Nombre del comerciante, su país de origen, el ID de la orden, el monto total de la orden (mayores a 200€), filtrando mediante una alerta las operaciones “delictivas” por cancelación (cancelled), o por falta de pago (delinqued) para su posterior aviso en este caso, además las operaciones reembolsadas y saber el motivo de dicho reembolso y el estado de la operación.

 


La funcionalidad de esta query y su consulta responde acerca de cómo podemos identificar un fraude en las ordenes mayores a cierto monto en función de si estas operaciones están en estado de deuda, canceladas o han sido reembolsadas por cierto motivo. De esta manera poder asegurarse que los pagos han sido efectuados correctamente y en su caso contrario tomar las medidas necesarias de aviso o detallar los motivos por los cuales están en situaciones consideradas delictivas o fuera de los términos requeridos.  
![image](https://github.com/emivlp/base_de_datos_MySQL/assets/123488399/7f984ad6-68d8-4cfe-b24c-115457b60dd4)
