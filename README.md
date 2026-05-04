# Proyecto 2 Base de Datos: Página administrativa para gestión de tienda

### Autor: Arturo Lima — 24683

## Descripción general

Este proyecto ofrece una vista administrativa de una tienda ficticia llamada **Buy n Large**,
que permite gestionar las entidades de mayor interés para el negocio. Cuenta con las
siguientes funcionalidades:

- **Gestión de clientes y productos:** CRUD completo (GET, POST, PUT, DELETE)
  con soporte de estado activo/inactivo mediante soft delete.
- **Gestión de compras:** CRUD completo con transacción explícita que valida
  stock disponible al crear una compra e incluye rollback automático ante cualquier error.
- **Reportes administrativos:** auditoría completa de ventas, rentabilidad de producto,
  desempeño de empleados y stock crítico; implementados mediante vistas SQL con
  JOINs, GROUP BY, WHERE y HAVING.
- **Catálogo de referencia:** empleados, proveedores, categorías y detalle de compra,
  disponibles en modo solo lectura (GET).

---

## Requisitos previos

- Docker (v20.10 o superior)
- Docker Compose (v1.29 o superior)

---

## Instrucciones para levantar el proyecto

### 1. Clonar el repositorio

```bash
git clone https://github.com/Artli22/Proyecto2BasedeDatos
cd Proyecto2BasedeDatos
```

> El frontend y el backend están incluidos como submódulos de Git para facilitar
> el proceso de clonación.

### 2. Configurar variables de entorno

```bash
cp .env.example .env
```

El archivo `.env.example` contiene los siguientes valores por defecto:
DB_USER=proy2
DB_PASSWORD=secret
DB_NAME=tienda
DB_HOST=db
DB_PORT=5432

### 3. Construir e iniciar los servicios

```bash
# Detener contenedores anteriores (si existen)
docker compose down

# Reconstruir imágenes sin caché
docker compose build --no-cache

# Iniciar servicios en segundo plano
docker compose up -d
```

### 4. Verificar que los servicios estén corriendo

```bash
docker compose ps
```

Se deben ver los siguientes contenedores en estado `Running`:
proyecto2basededatos-db-1
proyecto2basededatos-backend-1
proyecto2basededatos-frontend-1

### 5. Acceder a la aplicación

- proyecto2basededatos-db-1 (RUNNING)
- proyecto2basededatos-backend-1 (RUNNING)
- proyecto2basededatos-frontend-1 (RUNNING)


### 6. Verificar la conexión a la base de datos

```bash
docker compose exec db psql -U proy2 -d tienda -c "SELECT COUNT(*) FROM cliente;"
```

Debe retornar `25` (registros de clientes insertados en la inicialización).

### 7. Verificar el backend

```bash
curl http://localhost:8080/productos
```

Debe retornar un JSON con la lista de productos.

---

## Tecnologías utilizadas

- Go
- React + vite (frontend)
- React Router DOM 
- PostgreSQL 16
- Docker compose (backend) 

---

## Estructura del proyecto
```
Proyecto2BasedeDatos/
├── docker-compose.yml                    # Orquestación de servicios
├── .env.example                          # Variables de entorno (ejemplo)
├── README.md
│
├── db/
│   └── init.sql                          # DDL y datos de prueba
│
├── Proyecto2BasedeDatos-Backend/
│   ├── main.go                           # Punto de entrada
│   ├── handlers.go                       # Endpoints HTTP
│   ├── helpers.go                        # Funciones auxiliares y transacciones
│   ├── models.go                         # Estructuras de datos
│   ├── db.go                             # Conexión a la base de datos
│   ├── go.mod / go.sum                   # Dependencias Go
│   └── Dockerfile
│
└── Proyecto2BasedeDatos-Frontend/
├── src/
│   ├── main.jsx                      # Punto de entrada React
│   ├── App.jsx                       # Rutas principales
│   ├── navConfig.js                  # Configuración de navegación
│   ├── paginas/
│   │   ├── gestion/                  # Clientes, Productos, Compras
│   │   ├── catalogo/                 # Empleados, Categorías, Proveedores, Detalle compra
│   │   └── reportes/                 # Auditoría, Rentabilidad, Desempeño, Stock
│   ├── componentes/
│   │   └── layout/                   # TopNav, SectionTabs, AppLayout
│   └── servicios/                    # Llamadas a la API REST
├── package.json
├── vite.config.js
└── Dockerfile

---

## Características principales

### Transacciones explícitas
- Las compras utilizan transacciones con `BEGIN`, `COMMIT` y `ROLLBACK`.
- Se valida el stock disponible antes de insertar cada línea de detalle.
- Al cancelar una compra, el stock de todos los productos involucrados
  se restaura automáticamente dentro de la misma transacción.

### Validaciones aplicadas
- Stock insuficiente al crear una compra
- Producto inactivo
- Cliente no encontrado
- Cantidad negativa o igual a cero
- Producto duplicado dentro de la misma compra

### Decisiones técnicas
- **SQL explícito:** todas las queries están escritas manualmente, sin ORM.
- **Vistas SQL:** los cuatro reportes se alimentan de vistas definidas en la base de datos.
- **API REST:** endpoints JSON en el puerto 8080.
- **SPA:** Single Page Application con React Router DOM.

### Persistencia de datos
- Los datos se almacenan en el volumen `postgres_data`.
- Persisten tras `docker compose down`.
- Se eliminan únicamente con `docker compose down -v`.

---

## Desafíos implementados según rúbrica

### Diseño de base de datos
- Diagrama ER con entidades, atributos, relaciones y cardinalidades
- Modelo relacional documentado en notación relacional
- Normalización justificada hasta 3FN con dependencias funcionales
- DDL completo con `PRIMARY KEY`, `FOREIGN KEY` y `NOT NULL`
- Script de datos de prueba con al menos 25 registros por tabla
- Índices definidos explícitamente (`CREATE INDEX`) en al menos 2 columnas justificadas

### SQL
- 3 consultas con JOIN entre múltiples tablas, visibles en la UI
- 2 consultas con subquery (`IN`, `EXISTS` o subquery correlacionado), visibles en la UI
- Consultas con `GROUP BY`, `HAVING` y funciones de agregación, visibles en la UI
- Al menos 1 vista (`VIEW`) utilizada por el backend para alimentar la UI
- Al menos 1 transacción explícita con manejo de error y `ROLLBACK`

### Aplicación web
- CRUD completo de al menos 2 entidades en la interfaz
- Al menos 1 reporte visible en la UI con datos reales de la base de datos
- README con instrucciones funcionales y ejemplo de `docker compose up`

---

## Submódulos del repositorio

- **Frontend:**: https://github.com/Artli22/Proyecto2BasedeDatos-Frontend.git
- **Backend:**: https://github.com/Artli22/Proyecto2BasedeDatos-Backend.git
