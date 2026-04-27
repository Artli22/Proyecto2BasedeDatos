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
    correo VARCHAR(100)
);

CREATE TABLE empleado (
    id_empleado INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    telefono VARCHAR(20),
    correo VARCHAR(100)
);

CREATE TABLE categoria (
    id_categoria INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);

CREATE TABLE proveedor (
    id_proveedor INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    telefono VARCHAR(20),
    correo VARCHAR(100)
);

CREATE TABLE producto (
    id_producto INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    descripcion TEXT,
    precio_actual NUMERIC(10,2) NOT NULL,
    fecha_vencimiento DATE,
    imagen VARCHAR(255),
    stock INT NOT NULL,
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
GROUP BY pro.id_producto, pro.nombre, cat.nombre;

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
GROUP BY emp.id_empleado, emp.nombre;

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
('Carmen Díaz',        '5555-3030', 'carmen.diaz@tienda.com'),
('Roberto Silva',      '5555-4040', 'roberto.silva@tienda.com'),
('Elena Torres',       '5555-5050', 'elena.torres@tienda.com'),
('Miguel Reyes',       '5555-6060', 'miguel.reyes@tienda.com'),
('Valeria Cruz',       '5555-7070', 'valeria.cruz@tienda.com'),
('Oscar Molina',       '5555-8080', 'oscar.molina@tienda.com'),
('Daniela Fuentes',    '5555-9090', 'daniela.fuentes@tienda.com'),
('Jesús Alvarado',     '5566-1001', 'jesus.alvarado@tienda.com'),
('Patricia Leiva',     '5566-1002', 'patricia.leiva@tienda.com'),
('Rodrigo Paz',        '5566-1003', 'rodrigo.paz@tienda.com'),
('Silvia Portillo',    '5566-1004', 'silvia.portillo@tienda.com'),
('Marco Girón',        '5566-1005', 'marco.giron@tienda.com'),
('Rebeca Juárez',      '5566-1006', 'rebeca.juarez@tienda.com'),
('Felipe Sandoval',    '5566-1007', 'felipe.sandoval@tienda.com'),
('Lorena Cifuentes',   '5566-1008', 'lorena.cifuentes@tienda.com'),
('Andrés Recinos',     '5566-1009', 'andres.recinos@tienda.com'),
('Isabel Najarro',     '5566-1010', 'isabel.najarro@tienda.com'),
('Wilber Cuxum',       '5566-1011', 'wilber.cuxum@tienda.com'),
('Marisol Caal',       '5566-1012', 'marisol.caal@tienda.com'),
('Ernesto Toj',        '5566-1013', 'ernesto.toj@tienda.com'),
('Xiomara Pop',        '5566-1014', 'xiomara.pop@tienda.com'),
('Gerardo Xol',        '5566-1015', 'gerardo.xol@tienda.com');

-- CATEGORIA (25 registros)
INSERT INTO categoria (nombre) VALUES
('Lacteos'),
('Granos'),
('Bebidas'),
('Limpieza'),
('Panadería'),
('Carnes'),
('Frutas'),
('Verduras'),
('Cuidado personal'),
('Snacks'),
('Congelados'),
('Enlatados'),
('Condimentos'),
('Aceites y grasas'),
('Cereales y desayunos'),
('Dulces y repostería'),
('Medicamentos básicos'),
('Ferretería y hogar'),
('Papelería'),
('Mascotas'),
('Bebidas alcohólicas'),
('Tabaco'),
('Electrónicos básicos'),
('Ropa y accesorios'),
('Flores y plantas');

-- PROVEEDOR (25 registros)
INSERT INTO proveedor (nombre, telefono, correo) VALUES
('Proveedor A',            '5555-1234', 'ProveedorA@gmail.com'),
('Proveedor B',            '5555-6879', 'ProveedorB@gmail.com'),
('Distribuidora Central',  '5555-1212', 'central@proveedores.com'),
('Alimentos del Norte',    '5555-3434', 'norte@proveedores.com'),
('Comercial La Unión',     '5555-5656', 'union@proveedores.com'),
('Lácteos Premium',        '5555-7878', 'premium@proveedores.com'),
('Granos Selectos',        '5555-9898', 'granos@proveedores.com'),
('Bebidas Express',        '5555-4545', 'bebidas@proveedores.com'),
('Higiene Total',          '5555-6767', 'higiene@proveedores.com'),
('Mercado Verde',          '5555-8989', 'verde@proveedores.com'),
('Congelados del Sur',     '5577-1001', 'sur@proveedores.com'),
('Enlatados Selectos',     '5577-1002', 'enlatados@proveedores.com'),
('Condimentos Gourmet',    '5577-1003', 'gourmet@proveedores.com'),
('Aceites Naturales',      '5577-1004', 'aceites@proveedores.com'),
('Cereales Andinos',       '5577-1005', 'cereales@proveedores.com'),
('Dulcería Nacional',      '5577-1006', 'dulceria@proveedores.com'),
('Farmacéutica Básica',    '5577-1007', 'farma@proveedores.com'),
('Hogar y Más',            '5577-1008', 'hogar@proveedores.com'),
('Papelería Guatemala',    '5577-1009', 'papeleria@proveedores.com'),
('Nutrición Animal',       '5577-1010', 'mascotas@proveedores.com'),
('Distribuidora Norte',    '5577-1011', 'dnorte@proveedores.com'),
('Importaciones del Este', '5577-1012', 'importeste@proveedores.com'),
('Exportaciones Sur',      '5577-1013', 'exsur@proveedores.com'),
('Productos Orgánicos GT', '5577-1014', 'organicos@proveedores.com'),
('Cooperativa Maya',       '5577-1015', 'maya@proveedores.com');

-- PRODUCTO (25 registros)
INSERT INTO producto (
    nombre, descripcion, precio_actual,
    fecha_vencimiento, imagen, stock, id_categoria, id_proveedor
) VALUES
('Mantequilla',          'mala para la salud',             5.00,  '2026-09-12', 'img_mantequilla.jpg',   80, 1,  1),
('Arroz',                'bolsa 1kg grano largo',          8.00,  '2026-10-22', 'img_arroz.jpg',         40, 2,  2),
('Leche entera',         'leche de un litro',              9.50,  '2026-08-15', 'img_leche.jpg',         60, 1,  6),
('Frijol negro',         'bolsa de frijol 1kg',           12.00,  '2027-01-10', 'img_frijol.jpg',        35, 2,  7),
('Jugo de naranja',      'bebida natural en caja',         7.25,  '2026-07-05', 'img_jugo.jpg',          50, 3,  8),
('Detergente líquido',   'detergente para ropa',          18.75,  '2027-03-18', 'img_detergente.jpg',    25, 4,  9),
('Pan integral',         'pan fresco de bolsa',            6.50,  '2026-05-01', 'img_pan.jpg',           45, 5,  3),
('Carne molida',         'carne empacada 500g',           32.00,  '2026-04-30', 'img_carne.jpg',         20, 6,  4),
('Manzana roja',         'fruta fresca por libra',         4.75,  '2026-04-29', 'img_manzana.jpg',       70, 7, 10),
('Shampoo herbal',       'cuidado personal 400ml',        24.00,  '2027-06-12', 'img_shampoo.jpg',       30, 9,  5),
('Helado de vainilla',   'helado en cubo 1L',             22.00,  '2026-06-30', 'img_helado.jpg',        15, 11, 11),
('Atún en lata',         'atún en agua 170g',              8.50,  '2028-01-01', 'img_atun.jpg',          55, 12, 12),
('Salsa de tomate',      'salsa natural 500ml',            6.00,  '2027-09-15', 'img_salsa.jpg',         40, 13, 13),
('Aceite de oliva',      'aceite extra virgen 500ml',     38.00,  '2027-11-20', 'img_aceite.jpg',        18, 14, 14),
('Granola',              'cereal con frutos secos 400g',  15.00,  '2026-12-01', 'img_granola.jpg',       35, 15, 15),
('Chocolate negro',      'tableta 70% cacao 100g',        14.50,  '2027-04-10', 'img_chocolate.jpg',     50, 16, 16),
('Ibuprofeno 400mg',     'caja de 10 tabletas',           18.00,  '2027-08-01', 'img_ibuprofeno.jpg',    25, 17, 17),
('Escoba de plástico',   'escoba hogar resistente',       35.00,  NULL,         'img_escoba.jpg',        12, 18, 18),
('Cuaderno 100 hojas',   'cuaderno rayado universitario', 12.00,  NULL,         'img_cuaderno.jpg',      60, 19, 19),
('Comida para perro',    'croquetas 2kg adulto',          45.00,  '2027-03-01', 'img_croquetas.jpg',     20, 20, 20),
('Agua purificada',      'botella 1.5L',                   4.00,  '2026-10-01', 'img_agua.jpg',         100, 3,  8),
('Yogur natural',        'yogur sin azúcar 200g',          7.00,  '2026-05-10', 'img_yogur.jpg',         45, 1,  6),
('Papas fritas',         'bolsa de snack 150g',            9.00,  '2026-09-01', 'img_papas.jpg',         65, 10,  2),
('Café molido',          'café 250g origen Guatemala',    28.00,  '2027-02-14', 'img_cafe.jpg',          30, 3, 25),
('Tomate',               'tomate fresco por libra',        3.50,  '2026-05-05', 'img_tomate.jpg',        80, 8, 10);

-- COMPRA (25 registros)
INSERT INTO compra (
    fecha, total, metodo_pago, estado, num_factura, id_cliente, id_empleado
) VALUES
('2026-04-23', 21.00,  'tarjeta',       'completado', '12345', 1,  1),
('2026-04-23', 29.50,  'efectivo',      'completado', '12346', 2,  3),
('2026-04-24', 38.25,  'tarjeta',       'completado', '12347', 3,  2),
('2026-04-24', 18.75,  'transferencia', 'completado', '12348', 4,  4),
('2026-04-25', 32.00,  'tarjeta',       'completado', '12349', 5,  5),
('2026-04-25', 13.25,  'efectivo',      'completado', '12350', 6,  6),
('2026-04-26', 24.00,  'tarjeta',       'completado', '12351', 7,  7),
('2026-04-26',  0.00,  'tarjeta',       'cancelado',  '12352', 8,  8),
('2026-04-27',  0.00,  'efectivo',      'cancelado',  '12353', 9,  9),
('2026-04-27',  0.00,  'transferencia', 'cancelado',  '12354', 10, 10),
('2026-04-28', 53.50,  'tarjeta',       'completado', '12355', 11, 11),
('2026-04-28', 22.00,  'efectivo',      'completado', '12356', 12,  2),
('2026-04-29', 76.00,  'tarjeta',       'completado', '12357', 13,  3),
('2026-04-29', 14.00,  'efectivo',      'completado', '12358', 14,  4),
('2026-04-30', 45.00,  'transferencia', 'completado', '12359', 15,  5),
('2026-04-30', 38.00,  'tarjeta',       'completado', '12360', 16,  6),
('2026-05-01', 29.75,  'efectivo',      'completado', '12361', 17,  7),
('2026-05-01', 18.00,  'tarjeta',       'completado', '12362', 18,  8),
('2026-05-02', 62.50,  'transferencia', 'completado', '12363', 19,  9),
('2026-05-02', 31.00,  'efectivo',      'completado', '12364', 20, 10),
('2026-05-03',  0.00,  'tarjeta',       'cancelado',  '12365', 21, 11),
('2026-05-03', 44.50,  'tarjeta',       'completado', '12366', 22, 12),
('2026-05-04', 17.50,  'efectivo',      'completado', '12367', 23, 13),
('2026-05-04', 83.00,  'transferencia', 'completado', '12368', 24, 14),
('2026-05-05', 28.00,  'tarjeta',       'completado', '12369', 25, 15);

-- DETALLE_COMPRA (25 registros)
INSERT INTO detalle_compra (
    id_compra, id_producto, cantidad, precio_unitario, sub_total
) VALUES
(1,  1,  1,  5.00,  5.00),
(1,  2,  2,  8.00, 16.00),
(2,  3,  1,  9.50,  9.50),
(2,  4,  1, 12.00, 12.00),
(3,  5,  2,  7.25, 14.50),
(3,  9,  5,  4.75, 23.75),
(4,  6,  1, 18.75, 18.75),
(5,  8,  1, 32.00, 32.00),
(6,  7,  1,  6.50,  6.50),
(6, 21,  2,  4.00,  8.00),
(7, 10,  1, 24.00, 24.00),
(11, 11, 1, 22.00, 22.00),
(11, 12, 3,  8.50, 25.50),
(12, 11, 1, 22.00, 22.00),
(13, 14, 2, 38.00, 76.00),
(14, 25, 4,  3.50, 14.00),
(15, 20, 1, 45.00, 45.00),
(16, 14, 1, 38.00, 38.00),
(17, 15, 1, 15.00, 15.00),
(17, 23, 2,  9.00, 18.00),
(18, 17, 1, 18.00, 18.00),
(19, 24, 1, 28.00, 28.00),
(19, 13, 3,  6.00, 18.00),
(22, 16, 2, 14.50, 29.00),
(24, 8,  1, 32.00, 32.00);