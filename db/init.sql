-- =========================================================
-- Proyecto no.2 Arturo Lima - 24683
-- =========================================================

-- =========================================================
-- DDL - Creacion de tablas
-- =========================================================

CREATE TABLE cliente (
    id_cliente INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    telefono VARCHAR(20),
    correo VARCHAR(100),
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE empleado (
    id_empleado INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    telefono VARCHAR(20),
    correo VARCHAR(100),
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE categoria (
    id_categoria INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);

CREATE TABLE proveedor (
    id_proveedor INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    telefono VARCHAR(20),
    correo VARCHAR(100),
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE producto (
    id_producto INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    descripcion TEXT,
    precio_actual NUMERIC(10,2) NOT NULL,
    fecha_vencimiento DATE,
    imagen VARCHAR(255),
    stock INT NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE, 
    id_categoria INT NOT NULL,
    id_proveedor INT NOT NULL,
    FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria),
    FOREIGN KEY (id_proveedor) REFERENCES proveedor(id_proveedor)
);

CREATE TABLE compra (
    id_compra INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fecha DATE NOT NULL,
    total NUMERIC(10,2) NOT NULL,
    metodo_pago VARCHAR(50),
    estado VARCHAR(50),
    num_factura VARCHAR(50) UNIQUE,
    id_cliente INT NOT NULL,
    id_empleado INT NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
    FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado)
);

CREATE TABLE detalle_compra (
    id_compra INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario NUMERIC(10,2) NOT NULL,
    sub_total NUMERIC(10,2) NOT NULL,
    PRIMARY KEY (id_compra, id_producto),
    FOREIGN KEY (id_compra) REFERENCES compra(id_compra),
    FOREIGN KEY (id_producto) REFERENCES producto(id_producto)
);

-- =========================================================
-- INDICES
-- =========================================================

-- Acelera filtros y reportes de ventas por rango de fecha
CREATE INDEX idx_compra_fecha ON compra(fecha);

-- Analisis de rotacion de inventario por categoria,
CREATE INDEX idx_producto_categoria ON producto(id_categoria);

-- Deteccion de patrones de consumo de los clientes
CREATE INDEX idx_compra_cliente ON compra(id_cliente);

-- Agiliza reportes de desempeno por empleado
CREATE INDEX idx_compra_empleado ON compra(id_empleado);

-- Analisis de stock disponibles; funcional para un sistema de alerta de stock bajo
CREATE INDEX idx_producto_stock ON producto(stock);

-- =========================================================
-- VISTAS
-- =========================================================

-- Vista 1: Auditoria completa de ventas
CREATE VIEW vista_auditoria_completa_ventas AS
SELECT
    com.id_compra,
    com.num_factura,
    com.fecha,
    com.metodo_pago,
    com.estado,
    com.total,
    cli.nombre  AS cliente,
    cli.correo  AS correo_cliente,
    e.nombre   AS empleado_cajero
FROM compra com
JOIN cliente  cli ON com.id_cliente  = cli.id_cliente
JOIN empleado e  ON com.id_empleado = e.id_empleado;

-- Vista 2: Rotacion y rentabilidad de productos
CREATE VIEW vista_rentabilidad_productos AS
SELECT
    pro.id_producto,
    pro.nombre                        AS producto,
    cat.nombre                      AS categoria,
    SUM(detcom.cantidad)                AS unidades_vendidas,
    SUM(detcom.sub_total)               AS ingresos_totales,
    ROUND(AVG(detcom.precio_unitario), 2) AS precio_promedio_venta
FROM detalle_compra detcom
JOIN producto  pro   ON detcom.id_producto  = pro.id_producto
JOIN categoria cat ON pro.id_categoria  = cat.id_categoria
WHERE pro.activo = TRUE
GROUP BY pro.id_producto, pro.nombre, cat.nombre 
HAVING SUM(detcom.cantidad) > 0;

-- Vista 3: Control de stock
CREATE VIEW vista_stock_critico AS
SELECT
    pro.id_producto,
    pro.nombre          AS producto,
    cat.nombre        AS categoria,
    prov.nombre         AS proveedor,
    prov.telefono       AS telefono_proveedor,
    pro.stock           AS stock_actual,
    pro.fecha_vencimiento
FROM producto pro
JOIN categoria cat ON pro.id_categoria = cat.id_categoria
JOIN proveedor prov  ON pro.id_proveedor = prov.id_proveedor
WHERE pro.stock < 20
ORDER BY pro.stock ASC;

-- Vista 4: Desempeno de empleados por ventas
CREATE VIEW vista_desempeno_empleados AS
SELECT
    emp.id_empleado,
    emp.nombre                    AS empleado,
    COUNT(com.id_compra)          AS total_transacciones,
    SUM(com.total)                AS monto_total_vendido,
    ROUND(AVG(com.total), 2)      AS ticket_promedio,
    MAX(com.fecha)                AS ultima_venta
FROM empleado emp
LEFT JOIN compra com ON emp.id_empleado = com.id_empleado
    AND com.estado = 'completado'
WHERE emp.activo = TRUE
GROUP BY emp.id_empleado, emp.nombre
HAVING SUM(com.total) > 0;

-- =========================================================
-- DATOS DE PRUEBA
-- =========================================================

-- CLIENTE (25 registros)
INSERT INTO cliente (nombre, telefono, correo) VALUES
('Mario Barrientos',   '5555-4321', 'Mar2687@uvg.edu.gt'),
('Ana Morales',        '5555-1111', 'ana.morales@gmail.com'),
('Carlos Pérez',       '5555-2222', 'carlos.perez@gmail.com'),
('Lucía Gómez',        '5555-3333', 'lucia.gomez@gmail.com'),
('Diego Hernández',    '5555-4444', 'diego.hdz@gmail.com'),
('Sofía Ramírez',      '5555-5555', 'sofia.ramirez@gmail.com'),
('Fernando López',     '5555-6666', 'fernando.lopez@gmail.com'),
('María Castillo',     '5555-7777', 'maria.castillo@gmail.com'),
('Jorge Méndez',       '5555-8888', 'jorge.mendez@gmail.com'),
('Paola Ruiz',         '5555-9999', 'paola.ruiz@gmail.com'),
('Roberto Aguilar',    '5544-1001', 'roberto.aguilar@gmail.com'),
('Claudia Vásquez',    '5544-1002', 'claudia.vasquez@gmail.com'),
('Héctor Montoya',     '5544-1003', 'hector.montoya@gmail.com'),
('Nadia Ortiz',        '5544-1004', 'nadia.ortiz@gmail.com'),
('Samuel Barrios',     '5544-1005', 'samuel.barrios@gmail.com'),
('Ingrid Maldonado',   '5544-1006', 'ingrid.maldonado@gmail.com'),
('Bryan Solís',        '5544-1007', 'bryan.solis@gmail.com'),
('Karla Estrada',      '5544-1008', 'karla.estrada@gmail.com'),
('Edwin Marroquín',    '5544-1009', 'edwin.marroquin@gmail.com'),
('Viviana Ajú',        '5544-1010', 'viviana.aju@gmail.com'),
('Julio Chávez',       '5544-1011', 'julio.chavez@gmail.com'),
('Renata Fuentes',     '5544-1012', 'renata.fuentes@gmail.com'),
('Óscar Polanco',      '5544-1013', 'oscar.polanco@gmail.com'),
('Daniela Cano',       '5544-1014', 'daniela.cano@gmail.com'),
('Tomás Velásquez',    '5544-1015', 'tomas.velasquez@gmail.com');

-- EMPLEADO (25 registros)
INSERT INTO empleado (nombre, telefono, correo) VALUES
('Luis Fonsi',         '5555-5678', 'luis.fonsi@tienda.com'),
('Andrea Soto',        '5555-1010', 'andrea.soto@tienda.com'),
('Pablo García',       '5555-2020', 'pablo.garcia@tienda.com'),
('Martina López',      '5555-3030', 'martina.lopez@tienda.com'),
('Ricardo Pérez',      '5555-4040', 'ricardo.perez@tienda.com'),
('Valeria Rojas',      '5555-5050', 'valeria.rojas@tienda.com'),
('Alejandro Moreno',   '5555-6060', 'alejandro.moreno@tienda.com'),
('Gabriela Flores',    '5555-7070', 'gabriela.flores@tienda.com'),
('Felipe Gutierrez',   '5555-8080', 'felipe.gutierrez@tienda.com'),
('Natalia Vargas',     '5555-9090', 'natalia.vargas@tienda.com'),
('Manuel Ríos',        '5544-2001', 'manuel.rios@tienda.com'),
('Carolina Herrera',   '5544-2002', 'carolina.herrera@tienda.com'),
('Fernando Ruiz',      '5544-2003', 'fernando.ruiz@tienda.com'),
('Leticia Fuentes',    '5544-2004', 'leticia.fuentes@tienda.com'),
('Miguel Acosta',      '5544-2005', 'miguel.acosta@tienda.com'),
('Rosario Iglesias',   '5544-2006', 'rosario.iglesias@tienda.com'),
('Guillermo Medina',   '5544-2007', 'guillermo.medina@tienda.com'),
('Teresa Vega',        '5544-2008', 'teresa.vega@tienda.com'),
('Raúl Delgado',       '5544-2009', 'raul.delgado@tienda.com'),
('Silvia Navarro',     '5544-2010', 'silvia.navarro@tienda.com'),
('Óscar Díaz',         '5544-2011', 'oscar.diaz@tienda.com'),
('Margarita Rincón',   '5544-2012', 'margarita.rincon@tienda.com'),
('Enrique Santana',    '5544-2013', 'enrique.santana@tienda.com'),
('Beatriz Guzmán',     '5544-2014', 'beatriz.guzman@tienda.com'),
('Rodrigo Salinas',    '5544-2015', 'rodrigo.salinas@tienda.com');

-- CATEGORIA (5 registros)
INSERT INTO categoria (nombre) VALUES
('Electrónica'),
('Ropa y Accesorios'),
('Alimentos y Bebidas'),
('Hogar y Jardín'),
('Deportes y Recreación');

-- PROVEEDOR (10 registros)
INSERT INTO proveedor (nombre, telefono, correo) VALUES
('Tech Solutions S.A.',      '5555-1111', 'ventas@techsolutions.com'),
('Fashion Import Co.',       '5555-2222', 'contacto@fashionimport.com'),
('Alimentos Frescos Ltd.',   '5555-3333', 'pedidos@alimentosfrescos.com'),
('Casa y Hogar Premium',     '5555-4444', 'info@casayhogar.com'),
('Sports Equipment Global',  '5555-5555', 'ventas@sportsequip.com'),
('Electronics Distributor',  '5555-6666', 'dist@electronics.com'),
('Clothing Wholesale',       '5555-7777', 'bulk@clothingwhole.com'),
('Beverages International',  '5555-8888', 'supply@beverages.com'),
('Garden Supplies Inc.',     '5555-9999', 'orders@gardensupplies.com'),
('Recreation Distributors',  '5544-3001', 'sales@recreation.com');

-- PRODUCTO (20 registros)
INSERT INTO producto (nombre, descripcion, precio_actual, fecha_vencimiento, imagen, stock, id_categoria, id_proveedor) VALUES
('Laptop Dell XPS 13', 'Laptop ultradelgada con procesador Intel i7', 999.99, NULL, '/img/laptop.jpg', 15, 1, 1),
('Monitor LG 27"', 'Monitor 4K UltraWide de 27 pulgadas', 349.99, NULL, '/img/monitor.jpg', 8, 1, 1),
('Teclado Mecánico RGB', 'Teclado gaming con switches mecánicos', 129.99, NULL, '/img/keyboard.jpg', 25, 1, 6),
('Camiseta Básica Blanca', 'Camiseta 100% algodón de hombre', 19.99, NULL, '/img/camiseta.jpg', 150, 2, 7),
('Jeans Azul Oscuro', 'Pantalón jean de corte clásico', 59.99, NULL, '/img/jeans.jpg', 45, 2, 2),
('Leche Integral 1L', 'Leche de vaca pasteurizada', 2.50, '2026-05-30', '/img/leche.jpg', 200, 3, 8),
('Café Molido Premium', 'Café 100% Arábica, bolsa de 500g', 8.99, '2026-08-15', '/img/cafe.jpg', 80, 3, 8),
('Almohada de Espuma', 'Almohada ergonómica con espuma viscoelástica', 34.99, NULL, '/img/almohada.jpg', 60, 4, 4),
('Maceta de Cerámica', 'Maceta decorativa para interiores', 12.99, NULL, '/img/maceta.jpg', 120, 4, 9),
('Pelota de Fútbol', 'Balón reglamentario de cuero sintético', 24.99, NULL, '/img/balon.jpg', 50, 5, 10),
('Mouse inalámbrico', 'Mouse óptico inalámbrico 2.4GHz', 19.99, NULL, '/img/mouse.jpg', 40, 1, 1),
('Auriculares Bluetooth', 'Auriculares inalámbricos con cancelación de ruido', 149.99, NULL, '/img/auriculares.jpg', 30, 1, 1),
('Chaqueta de Invierno', 'Abrigo impermeable para climas fríos', 89.99, NULL, '/img/chaqueta.jpg', 20, 2, 2),
('Zapatos Deportivos', 'Zapatillas para correr con soporte ortopédico', 79.99, NULL, '/img/zapatos.jpg', 35, 2, 7),
('Aceite de Oliva 500ml', 'Aceite virgen extra de oliva', 12.99, '2027-01-10', '/img/aceite.jpg', 100, 3, 8),
('Mantequilla 250g', 'Mantequilla clarificada sin sal', 5.99, '2026-06-20', '/img/mantequilla.jpg', 75, 3, 8),
('Lámpara de Escritorio', 'Lámpara LED ajustable con control táctil', 44.99, NULL, '/img/lampara.jpg', 18, 4, 4),
('Cortinas Blackout', 'Cortinas opacas para oscurecer la habitación', 39.99, NULL, '/img/cortinas.jpg', 25, 4, 9),
('Bicicleta de Montaña', 'Bicicleta todo terreno con 21 velocidades', 299.99, NULL, '/img/bicicleta.jpg', 12, 5, 10),
('Raqueta de Tenis', 'Raqueta profesional de grafito', 149.99, NULL, '/img/raqueta.jpg', 22, 5, 10);

-- PRODUCTO - Datos adicionales
INSERT INTO producto (nombre, descripcion, precio_actual, fecha_vencimiento, imagen, stock, id_categoria, id_proveedor) VALUES
('Mantequilla', 'mala para la salud', 5.00, '2026-09-12', 'imagen1', 80, 3, 1),
('Arroz', 'buen producto', 8.00, '2026-10-22', 'imagen2', 40, 3, 2),
('Leche entera', 'leche de un litro', 9.50, '2026-08-15', 'imagen3', 60, 3, 6),
('Frijol negro', 'bolsa de frijol 1kg', 12.00, '2027-01-10', 'imagen4', 35, 3, 7),
('Jugo de naranja', 'bebida natural en caja', 7.25, '2026-07-05', 'imagen5', 50, 3, 8),
('Detergente líquido', 'detergente para ropa', 18.75, '2027-03-18', 'imagen6', 25, 4, 9),
('Pan integral', 'pan fresco de bolsa', 6.50, '2026-05-01', 'imagen7', 45, 3, 3),
('Carne molida', 'carne empacada', 32.00, '2026-04-30', 'imagen8', 20, 3, 4),
('Manzana roja', 'fruta fresca por libra', 4.75, '2026-04-29', 'imagen9', 70, 3, 10),
('Shampoo herbal', 'producto de cuidado personal', 24.00, '2027-06-12', 'imagen10', 30, 4, 5);

-- COMPRA (10 registros)
INSERT INTO compra (fecha, total, metodo_pago, estado, num_factura, id_cliente, id_empleado) VALUES
('2026-04-23', 21.00, 'tarjeta', 'completado', '12345', 1, 1),
('2026-04-23', 29.50, 'efectivo', 'completado', '12346', 2, 3),
('2026-04-24', 38.25, 'tarjeta', 'completado', '12347', 3, 2),
('2026-04-24', 18.75, 'transferencia', 'completado', '12348', 4, 4),
('2026-04-25', 32.00, 'tarjeta', 'completado', '12349', 5, 5),
('2026-04-25', 13.25, 'efectivo', 'completado', '12350', 6, 6),
('2026-04-26', 24.00, 'tarjeta', 'completado', '12351', 7, 7),
('2026-04-26', 0.00, 'tarjeta', 'cancelado', '12352', 8, 8),
('2026-04-27', 0.00, 'efectivo', 'cancelado', '12353', 9, 9),
('2026-04-27', 0.00, 'transferencia', 'cancelado', '12354', 10, 10);

-- DETALLE_COMPRA (10 registros)
INSERT INTO detalle_compra (id_compra, id_producto, cantidad, precio_unitario, sub_total) VALUES
(1, 1, 1, 5.00, 5.00),
(1, 2, 2, 8.00, 16.00),
(2, 3, 1, 9.50, 9.50),
(2, 4, 1, 12.00, 12.00),
(2, 2, 1, 8.00, 8.00),
(3, 5, 2, 7.25, 14.50),
(3, 9, 5, 4.75, 23.75),
(4, 6, 1, 18.75, 18.75),
(5, 8, 1, 32.00, 32.00),
(6, 7, 1, 6.50, 6.50);
