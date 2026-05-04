-- =========================================================
-- Proyecto no.2 Arturo Lima - 24683
-- =========================================================

-- DDL Creacion de las 7 tablas

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

-- INDICES

-- Indices en compra mediante fecha de emision de la compra
CREATE INDEX idx_compra_fecha ON compra(fecha);

-- Indice en producto mediante categoria 
CREATE INDEX idx_producto_categoria ON producto(id_categoria);

-- Indice en compra mediante cliente que realizan dichas compras
CREATE INDEX idx_compra_cliente ON compra(id_cliente);

-- Indice en compra mediante empleado que atendio dichas compras 
CREATE INDEX idx_compra_empleado ON compra(id_empleado);

-- Indice en producto mediante la cantidad de stock disponible en dicho producto
CREATE INDEX idx_producto_stock ON producto(stock);

-- VISTAS

-- Auditoria completa de ventas
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

-- Rotacion y rentabilidad de productos
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

-- Control de stock
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

-- Desempeno de empleados por ventas
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

-- DATOS DE PRUEBA

-- CLIENTE 
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

-- EMPLEADO 
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

-- CATEGORIA 
INSERT INTO categoria (nombre) VALUES
('Lácteos y Derivados'),
('Carnes y Embutidos'),
('Frutas y Verduras'),
('Panadería y Cereales'),
('Bebidas'),
('Abarrotes y Conservas'),
('Hogar y Limpieza');

-- PROVEEDOR 
INSERT INTO proveedor (nombre, telefono, correo) VALUES
('Lácteos del Norte S.A.',       '5566-1001', 'ventas@lacteosdn.com'),
('Carnes Premium Ltda.',         '5566-1002', 'pedidos@carnespremium.com'),
('Distribuidora Fruver',         '5566-1003', 'fruver@distribuidor.com'),
('Panadería y Cereales Central', '5566-1004', 'ventas@panaderiacentral.com'),
('Bebidas y Refrescos S.A.',     '5566-1005', 'supply@bebidasgt.com'),
('Abarrotes y Granos Ltda.',     '5566-1006', 'pedidos@abarrotes.com'),
('Distribuidora Clean GT',       '5566-1007', 'info@cleangt.com'),
('TechStore Guatemala',          '5566-1008', 'ventas@techstore.gt'),
('Importadora Alimentaria S.A.', '5566-1009', 'importa@alimentaria.com'),
('Agropecuaria Nacional',        '5566-1010', 'ventas@agronacional.com');

-- PRODUCTO 
INSERT INTO producto (nombre, descripcion, precio_actual, fecha_vencimiento, imagen, stock, id_categoria, id_proveedor) VALUES
('Leche entera 1L',         'Leche de vaca pasteurizada',                 35.00, '2026-05-15', '/img/leche_entera.jpg',  120, 1, 1),
('Queso fresco 500g',       'Queso blanco fresco empacado al vacío',      28.00, '2026-05-08', '/img/queso_fresco.jpg',   60, 1, 1),
('Yogur natural 1kg',       'Yogur sin azúcar con cultivos activos',      22.00, '2026-05-12', '/img/yogur.jpg',           45, 1, 1),
('Mantequilla sin sal 250g','Mantequilla de origen animal sin sal',       18.00, '2026-06-01', '/img/mantequilla.jpg',    80, 1, 1),
('Crema de leche 200ml',    'Crema para cocinar y repostería',            15.00, '2026-05-20', '/img/crema.jpg',           50, 1, 1),
('Pollo entero 2kg',        'Pollo fresco entero sin vísceras',           55.00, '2026-05-06', '/img/pollo.jpg',           30, 2, 2),
('Carne molida 500g',       'Carne de res molida empacada al vacío',      42.00, '2026-05-05', '/img/carne_molida.jpg',    25, 2, 2),
('Salchicha Viena 400g',    'Salchichas en empaque hermético',            32.00, '2026-05-18', '/img/salchicha.jpg',       40, 2, 2),
('Jamón de pavo 200g',      'Fiambre de pavo bajo en grasa',              25.00, '2026-05-10', '/img/jamon.jpg',           35, 2, 2),
('Manzana roja por lb',     'Manzana importada fresca',                    8.00, '2026-05-09', '/img/manzana.jpg',         90, 3,  3),
('Tomate cherry 500g',      'Tomate de cocina fresco local',              12.00, '2026-05-07', '/img/tomate.jpg',          70, 3, 10),
('Zanahoria 1kg',           'Zanahoria nacional fresca lavada',           10.00, '2026-05-14', '/img/zanahoria.jpg',       55, 3, 10),
('Banano 5 unidades',       'Banano criollo aprox 1.5kg',                 14.00, '2026-05-06', '/img/banano.jpg',          40, 3,  3),
('Pan integral molde',      'Pan de trigo integral en rebanadas',         16.00, '2026-05-08', '/img/pan_molde.jpg',       65, 4, 4),
('Pan francés 6 unidades',  'Bolillo crujiente de horno',                  9.00, '2026-05-04', '/img/pan_frances.jpg',     80, 4, 4),
('Avena instantánea 500g',  'Avena en hojuelas de cocción rápida',        24.00, '2026-10-15', '/img/avena.jpg',           45, 4, 4),
('Granola con frutos 400g', 'Granola horneada con nueces y pasas',        32.00, '2026-09-20', '/img/granola.jpg',         38, 4, 9),
('Jugo de naranja 1L',      'Jugo natural sin conservantes',              18.00, '2026-06-10', '/img/jugo.jpg',            75, 5, 5),
('Agua purificada 1.5L',    'Agua purificada en botella plástica',         6.00, '2027-01-01', '/img/agua.jpg',           200, 5, 5),
('Refresco de cola 2L',     'Bebida carbonatada sabor cola',              12.00, '2026-08-30', '/img/refresco.jpg',        90, 5, 5),
('Arroz blanco 2kg',        'Arroz de grano largo seleccionado',          22.00, '2027-03-10', '/img/arroz.jpg',          100, 6, 6),
('Frijol negro 1kg',        'Frijol negro seco de primera calidad',       18.00, '2027-02-15', '/img/frijol.jpg',          85, 6, 6),
('Aceite vegetal 1L',       'Aceite para cocinar de girasol',             20.00, '2026-11-20', '/img/aceite.jpg',          60, 6, 6),
('Detergente líquido 1L',   'Detergente multiusos para ropa',             28.00, '2027-06-01', '/img/detergente.jpg',      45, 7, 7),
('Lámpara LED escritorio',  'Lámpara LED ajustable con luz cálida',       85.00,  NULL,        '/img/lampara.jpg',         15, 7, 8);

-- COMPRA 
INSERT INTO compra (fecha, total, metodo_pago, estado, num_factura, id_cliente, id_empleado) VALUES
('2026-04-23',  53.00, 'tarjeta',       'completado', '12345',  1,  1),
('2026-04-23',  28.00, 'efectivo',      'completado', '12346',  2,  3),
('2026-04-24',  77.00, 'tarjeta',       'completado', '12347',  3,  2),
('2026-04-24',  40.00, 'transferencia', 'completado', '12348',  4,  4),
('2026-04-25',  52.00, 'tarjeta',       'completado', '12349',  5,  5),
('2026-04-25',  60.00, 'efectivo',      'completado', '12350',  6,  6),
('2026-04-26',  46.00, 'tarjeta',       'completado', '12351',  7,  7),
('2026-04-26',   0.00, 'tarjeta',       'cancelado',  '12352',  8,  8),
('2026-04-27',   0.00, 'efectivo',      'cancelado',  '12353',  9,  9),
('2026-04-27',   0.00, 'transferencia', 'cancelado',  '12354', 10, 10);

-- DETALLE_COMPRA 
INSERT INTO detalle_compra (id_compra, id_producto, cantidad, precio_unitario, sub_total) VALUES
(1,  1, 1, 35.00, 35.00),  
(1, 15, 2,  9.00, 18.00),  
(2, 10, 2,  8.00, 16.00),  
(2, 11, 1, 12.00, 12.00),  
(3,  6, 1, 55.00, 55.00),  
(3, 21, 1, 22.00, 22.00),  
(4,  4, 1, 18.00, 18.00),  
(4,  3, 1, 22.00, 22.00),  
(5,  7, 1, 42.00, 42.00),  
(5, 12, 1, 10.00, 10.00),  
(6, 18, 2, 18.00, 36.00),  
(6, 16, 1, 24.00, 24.00),  
(7, 24, 1, 28.00, 28.00),  
(7, 19, 3,  6.00, 18.00);
