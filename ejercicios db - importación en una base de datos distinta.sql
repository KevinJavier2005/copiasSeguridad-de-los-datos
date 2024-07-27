CREATE DATABASE ejercicios_db;
USE ejercicios_db;

-- EJERCICIO 1
-- tabla llamada productos.
CREATE TABLE productos (
    id_producto INT PRIMARY KEY,
    nombre VARCHAR(100),
    precio DECIMAL(10,2)
);

-- Tres registros en la tabla de productos.
INSERT INTO  productos (id_producto, nombre, precio) 
VALUES ('1', 'Azucar', '16.00');

INSERT INTO  productos (id_producto, nombre, precio) 
VALUES ('2', 'Frijol', '15.00');

INSERT INTO  productos (id_producto, nombre, precio) 
VALUES ('3', 'Refresco', '18.00');

-- Actualización del precio de todos los productos.
START TRANSACTION;
UPDATE productos  SET precio = precio * 1.10 WHERE id_producto = 1;
SELECT * FROM productos;

-- Instrucción ROLLBACK para revertir los cambios.
ROLLBACK;
SELECT * FROM productos;

START TRANSACTION;
UPDATE productos  SET precio = precio * 1.10 WHERE id_producto = 2;
SELECT * FROM productos;
ROLLBACK;
SELECT * FROM productos;

START TRANSACTION;
UPDATE productos  SET precio = precio * 1.10 WHERE id_producto = 3;
SELECT * FROM productos;
ROLLBACK;
SELECT * FROM productos;

-- EJERCICIO 2
-- insertar un registro en la tabla productos 
-- y luego insertar un registro en una tabla no existente para provocar un error.
START TRANSACTION;
INSERT INTO productos (Id_producto, nombre, precio) 
VALUES (4, 'Maruchan', 10.00);
INSERT INTO tabla_inexistente (id, descripcion, valor) 
VALUES (1, 'descripcion', 'valor');
ROLLBACK;

-- Verificar que  ningún cambio ha sido aplicado a la tabla productos.
SELECT * FROM productos;

-- EJERCICIO 3
-- Transacción con COMMIT
-- Insertar nuevo producto y confirmar los cambios.
START TRANSACTION;
INSERT INTO productos (Id_producto, nombre, precio)
VALUES (4, 'Helado', 14.00);
COMMIT; 

-- Transacción con ROLLBACK
-- Actualizar el precio de un producto y luego revertir los cambios.
START TRANSACTION;
UPDATE productos SET precio = 100.00 WHERE Id_producto =1;
ROLLBACK;

-- EJERCICIO 4
-- Transacción con nivel de aislamiento Serializable.
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
START TRANSACTION;
SELECT * FROM productos WHERE Id_producto = 1;
UPDATE productos SET precio = 50.00 WHERE Id_producto = 1;
COMMIT; 

-- EJERCICIO 5
-- Insertar 2 registros en la tabla clientes y confirmar los cambios.
CREATE TABLE clientes (
    id_cliente INT PRIMARY KEY,
    nombre VARCHAR(100),
    email VARCHAR(100)
);

START TRANSACTION;
INSERT INTO clientes (Id_cliente, nombre, email) 
VALUES (1, 'Kevin', '23393313@utcancun.edu.mx');
INSERT INTO clientes (Id_cliente, nombre, email)
VALUES (2, 'Javier', '33364401@utcancun.edu.mx');
COMMIT;

SELECT * FROM clientes;

-- EJERCICIO 6
-- Lectura no confirmada.
-- Configuración de una transacción con nivel de aislamiento READ UNCOMMITTED
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;
SELECT nombre FROM clientes WHERE Id_cliente =1;

-- y realización de una operación de lectura mientras otra transacción está actualizando el mismo registro.
START TRANSACTION;
UPDATE clientes SET nombre = "Karla" WHERE Id_cliente = 1;
COMMIT;

-- Configura una transacción con nivel de aislamiento READ COMMITTED
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SELECT nombre FROM clientes WHERE Id_cliente = 1;

-- y observa cómo se comporta la lectura en comparación con READ UNCOMMITTED.
SELECT * FROM clientes;

-- EJERCICIO 7
-- Realización de una transacción que inserte un nuevo registro en la tabla clientes.
START TRANSACTION;
INSERT INTO clientes (nombre, email)
VALUES ('Eduardo', '28932319@utcancun.edu.mx');
COMMIT;

-- Confirmar los cambios y verificar que el registro persiste 
-- incluso después de un reinicio simulado de la base de datos.
SELECT * FROM clientes WHERE nombre = 'Eduardo';

-- EJERCICIO 8
-- Iniciar una transacción 
-- y crear un SAVEPOINT después de insertar un nuevo cliente.
START TRANSACTION;
INSERT INTO clientes (Id_cliente, nombre, email)
VALUES (3, 'Carlos', '12039423@utcancun.edu.mx');
SAVEPOINT after_insert;

-- Realizar otra operación 
-- y, en caso de error, vuelve al SAVEPOINT sin deshacer la primera operación.
UPDATE clientes SET email = '11111111@utcancun.edu.mx' WHERE nombre = 'Carlos';
ROLLBACK TO after_insert;
COMMIT;

-- EJERCICIO 9
-- Configurar una transacción con nivel de aislamiento REPEATABLE READ 
-- y realiza múltiples lecturas para observar la consistencia.
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
SELECT nombre, email FROM clientes WHERE Id_cliente = 1;
COMMIT;

-- Configurar una transacción con nivel de aislamiento SERIALIZABLE 
-- y realiza operaciones de lectura y escritura para asegurar la máxima consistencia.
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
START TRANSACTION;
SELECT * FROM clientes;
UPDATE clientes SET email = '29104322@utcancun.edu.mx' WHERE Id_cliente = 2;
COMMIT;

-- EJERCICIO 10
-- Crear una tabla llamada ventas.
CREATE TABLE ventas (
    id_venta INT PRIMARY KEY,
    producto VARCHAR(100),
    cantidad INT,
    precio DECIMAL(10,2)
);

-- Insertar varios registros en la tabla ventas y confirmar los cambios.
START TRANSACTION;
INSERT INTO ventas (id_venta, producto, cantidad, precio) 
VALUES (1, 'Cereal', 8, 10.50);
INSERT INTO ventas (id_venta, producto, cantidad, precio) 
VALUES (2, 'Raid', 4, 5.00);
INSERT INTO ventas (id_venta, producto, cantidad, precio) 
VALUES (3, 'Pastel', 7, 18.10);
COMMIT;
SELECT * FROM ventas;

-- Realizar una transacción que actualice algunos registros 
-- y luego revertir los cambios.
START TRANSACTION;
UPDATE ventas SET precio = precio * 1.10 WHERE id_venta = 1;
UPDATE ventas SET precio = precio * 1.10 WHERE id_venta = 2;
UPDATE ventas SET precio = precio * 1.10 WHERE id_venta = 3;
SELECT * FROM ventas;
ROLLBACK;
SELECT * FROM ventas;

-- EJERCICIO 11
-- Desarrollar un conjunto de operaciones que garantice la atomicidad y la consistencia.
START TRANSACTION;
INSERT INTO ventas (producto, cantidad, precio)
VALUES ('Vengala', 10, 20.00);
UPDATE ventas SET cantidad = 20 WHERE id_venta = 'zinc';
COMMIT; 
SELECT * FROM ventas;

-- Implementación de niveles de aislamiento para manejar la concurrencia.
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;
SELECT * FROM ventas;
COMMIT;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SELECT * FROM ventas;
COMMIT;

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
SELECT * FROM ventas WHERE producto = 'Vengala';
COMMIT;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
START TRANSACTION;
SELECT * FROM ventas;
COMMIT;

-- Verificación de la durabilidad de las transacciones 
-- después de un fallo simulado del sistema.
START TRANSACTION;
INSERT INTO ventas (id_venta, producto, cantidad, precio)
VALUES (5, 'Chocolate', 4, 5.00);
COMMIT;
SELECT * FROM ventas WHERE producto = 'Chocolate';

-- EJERCICIO 12
-- Crear puntos de guardado 
-- y revertir parcialmente una transacción utilizando SAVEPOINT 
-- y ROLLBACK TO SAVEPOINT.
START TRANSACTION;
INSERT INTO ventas (Id_venta, producto, cantidad, precio)
VALUES (6, 'Chocokrispis', 11, 16.00);
SAVEPOINT venta_1;

INSERT INTO ventas (Id_venta, producto, cantidad, precio)
VALUES (7, 'Caramelo', 20, 12.00);
SAVEPOINT venta_2;

ROLLBACK TO SAVEPOINT venta_1;

SELECT * FROM ventas;

INSERT INTO ventas (id_venta, producto, cantidad, precio)
VALUES (7, 'Palomitas', 12, 14.50);
COMMIT;

SELECT * FROM ventas;

-- EJERCICIO 13
-- Simulación de dos transacciones concurrentes 
-- y observar los efectos con diferentes niveles de aislamiento.
START TRANSACTION;
INSERT INTO ventas (id_venta, producto, cantidad, precio)
VALUES (8, 'Pollo', 11, 20.00);
INSERT INTO ventas (id_venta, producto, cantidad, precio)
VALUES (9, 'Salchicha', 18, 18.00);

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;
UPDATE ventas SET cantidad = cantidad + 1 WHERE id_venta = 8;
SELECT * FROM ventas;
COMMIT;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
UPDATE ventas SET cantidad = cantidad + 1 WHERE id_venta = 8;
SELECT * FROM ventas;
COMMIT;

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
UPDATE ventas SET cantidad = cantidad + 1 WHERE id_venta = 8;
SELECT * FROM ventas;
COMMIT;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
START TRANSACTION;
UPDATE ventas SET cantidad = cantidad + 1 WHERE id_venta = 8;
SELECT * FROM ventas;
COMMIT;

-- EJERCICIO 14
-- Configuración del nivel de aislamiento READ UNCOMMITTED 
-- y realización de una lectura mientras otra transacción está en progreso.
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;
UPDATE ventas SET cantidad = cantidad + 1 WHERE id_venta = 8;

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;
SELECT * FROM ventas;
COMMIT;

-- EJERCICIO 15
-- Realización de múltiples lecturas bajo el nivel de aislamiento REPEATABLE READ 
-- y observación de la consistencia.
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
SELECT * FROM ventas;
 START TRANSACTION;
UPDATE ventas SET cantidad = cantidad + 1 WHERE id_venta = 8;
START TRANSACTION;
SELECT * FROM ventas;
COMMIT;

-- EJERCICIO 16
-- Realización operaciones de lectura 
-- y escritura bajo el nivel de aislamiento SERIALIZABLE.
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
START TRANSACTION;
UPDATE ventas SET precio = precio + 1.10 WHERE id_venta = 8;
SELECT * FROM ventas;
commit;
UPDATE ventas SET precio = precio + 5.10 WHERE id_venta = 8;
commit;

-- EJERCICIO 17
-- Configuración de dos bases de datos 
-- y realización de una transacción distribuida que afecte a ambas.
CREATE DATABASE ventas_1;
USE ventas_1;
CREATE TABLE ventas1 (
id_venta01 INT PRIMARY KEY AUTO_INCREMENT,
producto VARCHAR(100),
cantidad INT,
precio DECIMAL (10, 2)
);
INSERT INTO ventas1 (id_venta01, producto, cantidad, precio)
VALUES (1, 'Bombones', 15, 11.50);

START TRANSACTION;
INSERT INTO ventas1 (id_venta01, producto, cantidad, precio)
VALUES (2, 'Manzanas', 13, 15.50);
SELECT * FROM ventas1;
COMMIT; 

CREATE DATABASE ventas_2;
USE ventas_2;
CREATE TABLE ventas2 (
id_venta02 INT PRIMARY KEY AUTO_INCREMENT,
producto VARCHAR(100),
cantidad INT,
precio DECIMAL (10, 2)
);
INSERT INTO ventas2 (id_venta02, producto, cantidad, precio)
VALUES (1, 'Mariscos', 20, 20.00);

START TRANSACTION;
INSERT INTO ventas2 (id_venta02, producto, cantidad, precio)
VALUES (2, 'Naranjas', 29, 16.00);
COMMIT;

SELECT * FROM ventas2;

-- EJERCICIO 18
-- Creación de una transacción anidada 
-- y gestión de su comportamiento utilizando SAVEPOINT.
START TRANSACTION;
INSERT INTO ventas (Id_venta, producto, cantidad, precio)
VALUES (10, 'Algodon', 13, 10.00);
SAVEPOINT venta_3;

INSERT INTO ventas (Id_venta, producto, cantidad, precio)
VALUES (11, 'Melon', 10, 13.50);
SAVEPOINT venta_4;

ROLLBACK TO SAVEPOINT venta_3;

SELECT * FROM ventas;

INSERT INTO ventas (id_venta, producto, cantidad, precio)
VALUES (11, 'Palomitas', 12, 14.50);
COMMIT;

SELECT * FROM ventas;

-- EJERCICIO 19
-- 	Realizar una transacción que se revierta automáticamente 
-- si una condición específica no se cumple.
START TRANSACTION;
UPDATE ventas SET cantidad = cantidad -2 WHERE id_venta = 10;
SELECT * FROM ventas;
COMMIT;
SELECT 'La cantidad esta actualizada correctamente';
ROLLBACK;
SELECT 'La cantidad esta actualizada incorrectamente';

-- EJERCICIO 20
-- Implementar una transacción que realice una operación 
-- de lectura seguida de una operación de escritura.
CREATE DATABASE bd1;
USE bd1;
CREATE TABLE lecturaseguida (
id_lecturaseguida INT PRIMARY KEY AUTO_INCREMENT,
producto VARCHAR(100),
cantidad INT,
precio DECIMAL(10, 2)
);

START TRANSACTION;
USE ejercicios_db;
INSERT INTO productos(id_producto, nombre, precio)
VALUES (4, 'Gelatina', 12.00);
USE bd1;
INSERT INTO lecturaseguida (id_lecturaseguida, producto, cantidad, precio)
VALUES (1, 'Alcohol', 18, 16.00);
COMMIT;
DELETE FROM productos WHERE id_producto = 4;
SELECT ¨FROM lecturaseguida;
SELECT * FROM productos;

-- EJERCICIO 21
-- Crear una transacción que solo se ejecute 
-- si existe un cierto estado en la base de datos.
START TRANSACTION;
SELECT COUNT(*) INTO @total_ventas FROM ventas;
UPDATE ventas SET precio = precio * 1.10 WHERE id_venta = 10;
SELECT 'Se actualizaron los precios de productos correctamente';
ROLLBACK;
SELECT 'No se actualizaron los precios correctamente';
COMMIT;

SELECT * FROM ventas;

-- EJERCICIO 22
-- Realización de una transacción que asegure la integridad de los datos 
-- al actualizar múltiples tablas.
START TRANSACTION;
UPDATE ventas SET cantidad = cantidad + 2 WHERE id_venta = 10;
SELECT ROW_COUNT() INTO @total__productos_actualizados;
UPDATE inventario SET stock = 12 WHERE id_inventario = 1;
SELECT 'Se actualizo la cantidad de ventas y el stock del inventario';
ROLLBACK;
SELECT 'No se actualizo la cantidad de ventas y el stock de inventario';
COMMIT;

SELECT * FROM ventas;
SELECT * FROM inventario;

CREATE TABLE auditoria (
    id_auditoria INT PRIMARY KEY AUTO_INCREMENT,
    id_producto INT,
    accion VARCHAR(50),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE categorias (
    id_categoria INT PRIMARY KEY,
    nombre_categoria VARCHAR(100)
);

CREATE TABLE productos_categoria (
    id_producto INT,
    id_categoria INT,
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto),
    FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
);

CREATE TABLE inventario (
    id_inventario INT PRIMARY KEY,
    producto VARCHAR(100),
    stock INT
);

INSERT INTO inventario (id_inventario, producto, stock)
VALUES (1, 'Carne', 64);

CREATE TABLE pedidos (
    id_pedido INT PRIMARY KEY,
    fecha_pedido DATE,
    cliente_id INT,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id_cliente)
);

CREATE TABLE detalles_pedido (
    id_detalle INT PRIMARY KEY AUTO_INCREMENT,
    id_pedido INT,
    id_producto INT,
    cantidad INT,
    precio DECIMAL(10,2),
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido),
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

