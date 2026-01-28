/*
	SCRIPT DE CREACION BASE DE DATOS "CLIENTS SYSTEM"
	AUTOR: DIEGO EDUARDO CASTRO QUINTANILLA
	FECHA DE MODIFICACION: 27/01/2026
*/

CREATE TABLE estadocliente (
    idestado SMALLINT PRIMARY KEY,
    estado   VARCHAR(25) NOT NULL UNIQUE
);

CREATE TABLE divisas (
    iddivisa  SERIAL PRIMARY KEY,
    divisa    VARCHAR(10) NOT NULL UNIQUE
);

CREATE TABLE clientes (
    codigocliente  INTEGER PRIMARY KEY,
    estado         SMALLINT NOT NULL DEFAULT 1 REFERENCES estadocliente(idestado),
    empresa        VARCHAR(100) NOT NULL,
    telefono       VARCHAR(20) NOT NULL,
    correo         VARCHAR(100) NOT NULL UNIQUE,
    usuario        VARCHAR(50) NOT NULL UNIQUE,
    clave          VARCHAR(255) NOT NULL,
    intentos       INTEGER NOT NULL DEFAULT 0,
    fechaclave     DATE NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT ck_clientes_estado CHECK (estado IN (1,2))
);

CREATE TABLE administradores (
    codigoadmin  INTEGER PRIMARY KEY,
    estado       SMALLINT NOT NULL DEFAULT 1,
    nombre       VARCHAR(50) NOT NULL,
    apellido     VARCHAR(50) NOT NULL,
    dui          VARCHAR(12) NOT NULL,
    correo       VARCHAR(100) NOT NULL UNIQUE,
    telefono     VARCHAR(20) NOT NULL,
    direccion    VARCHAR(150) NOT NULL,
    usuario      VARCHAR(50) NOT NULL UNIQUE,
    clave        VARCHAR(255) NOT NULL,
    tipo         SMALLINT NOT NULL,
    fechaclave   DATE NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT ck_admin_estado CHECK (estado IN (1,2))
);

ALTER TABLE administradores
ADD COLUMN codigo INTEGER;

CREATE TABLE sociedades (
    idsociedad  SERIAL PRIMARY KEY,
    cliente     INTEGER NOT NULL REFERENCES clientes(codigocliente) ON UPDATE CASCADE ON DELETE RESTRICT,
    sociedad    VARCHAR(50) NOT NULL
);

CREATE TABLE estadocuentas (
    idestadocuenta  SERIAL PRIMARY KEY,
    estado          BOOLEAN NOT NULL DEFAULT TRUE,
    responsable     INTEGER NOT NULL REFERENCES administradores(codigoadmin) ON UPDATE CASCADE ON DELETE RESTRICT,
    sociedad        INTEGER NOT NULL REFERENCES sociedades(idsociedad) ON UPDATE CASCADE ON DELETE RESTRICT,
    cliente         INTEGER NOT NULL REFERENCES clientes(codigocliente) ON UPDATE CASCADE ON DELETE RESTRICT,
    codigo          BIGINT NOT NULL,
    factura         BIGINT NOT NULL,
    asignacion      BIGINT NOT NULL,
    fechacontable   DATE NOT NULL,
    clase           VARCHAR(10) NOT NULL,
    vencimiento     DATE NOT NULL,
    divisa          INTEGER NOT NULL REFERENCES divisas(iddivisa) ON UPDATE CASCADE ON DELETE RESTRICT,
    totalgeneral    NUMERIC(14,2) NOT NULL
);

CREATE TABLE indiceentregas (
    idindice           SERIAL PRIMARY KEY,
    responsable        INTEGER NOT NULL REFERENCES administradores(codigoadmin) ON UPDATE CASCADE ON DELETE RESTRICT,
    cliente            INTEGER NOT NULL REFERENCES clientes(codigocliente) ON UPDATE CASCADE ON DELETE RESTRICT,
    organizacion       VARCHAR(60) NOT NULL,
    indice             NUMERIC(10,2) NOT NULL,
    totalcompromiso    INTEGER NOT NULL,
    cumplidos          INTEGER NOT NULL,
    nocumplidos        INTEGER NOT NULL,
    noconsiderados     INTEGER NOT NULL,
    incumnoentregados  VARCHAR(5) NOT NULL,
    incumporcalidad    VARCHAR(5) NOT NULL,
    incumporfecha      VARCHAR(5) NOT NULL,
    incumporcantidad   VARCHAR(5) NOT NULL,
    estado             BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE pedido (
    idpedido             SERIAL PRIMARY KEY,
    responsable          INTEGER NOT NULL REFERENCES administradores(codigoadmin) ON UPDATE CASCADE ON DELETE RESTRICT,
    cliente              INTEGER NOT NULL REFERENCES clientes(codigocliente) ON UPDATE CASCADE ON DELETE RESTRICT,
    pos                  VARCHAR(50) NOT NULL,
    oc                   VARCHAR(50) NOT NULL,
    cantidadsolicitada   INTEGER NOT NULL,
    descripcion          VARCHAR(200) NOT NULL,
    codigo               BIGINT NOT NULL,
    cantidadenviada      INTEGER NOT NULL,
    fechaentregada       DATE NOT NULL,
    fechaconfirmadaenvio DATE NOT NULL,
    comentarios          VARCHAR(150),
    fecharegistro        DATE NOT NULL DEFAULT CURRENT_DATE,
    estado               BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE historialcliente (
    idregistro   BIGSERIAL PRIMARY KEY,
    usuario      INTEGER NOT NULL REFERENCES clientes(codigocliente) ON UPDATE CASCADE ON DELETE RESTRICT,
    accion       VARCHAR(150) NOT NULL,
    hora         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dispositivo  VARCHAR(150) NOT NULL,
    sistema      VARCHAR(150) NOT NULL
);

CREATE TABLE historialusuario (
    idregistro   BIGSERIAL PRIMARY KEY,
    usuario      INTEGER NOT NULL REFERENCES administradores(codigoadmin) ON UPDATE CASCADE ON DELETE RESTRICT,
    accion       VARCHAR(150) NOT NULL,
    hora         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dispositivo  VARCHAR(150) NOT NULL,
    sistema      VARCHAR(150) NOT NULL
);

-- CREACION DE INDICES PARA OPTIMIZAR CONSULTAS
CREATE INDEX idx_sociedades_cliente      ON sociedades(cliente);
CREATE INDEX idx_estadocuentas_cliente   ON estadocuentas(cliente);
CREATE INDEX idx_estadocuentas_resp      ON estadocuentas(responsable);
CREATE INDEX idx_estadocuentas_sociedad  ON estadocuentas(sociedad);
CREATE INDEX idx_indice_cliente          ON indiceentregas(cliente);
CREATE INDEX idx_indice_resp             ON indiceentregas(responsable);
CREATE INDEX idx_pedido_cliente          ON pedido(cliente);
CREATE INDEX idx_pedido_resp             ON pedido(responsable);
CREATE INDEX idx_histc_usuario           ON historialcliente(usuario);
CREATE INDEX idx_histu_usuario           ON historialusuario(usuario);


-- INSERTS DE TABLAS CATALOGO
INSERT INTO estadocliente (idestado, estado) VALUES
(1, 'Activo'),
(2, 'Inactivo');

INSERT INTO divisas (divisa) VALUES
('USD'),
('EUR'),
('GTQ');

SELECT * FROM administradores

UPDATE administradores set estado = 1

-- INSERTS GENERICOS 

INSERT INTO administradores
(codigoadmin, estado, nombre, apellido, dui, correo, telefono, direccion, usuario, clave, tipo, fechaclave, codigo)
VALUES
(1001, 1, 'Carlos', 'Hernandez', '01234567-8', 'admin1@demo.com', '7777-0001', 'San Salvador, SV', 'admin1', 'demo_hash_1', 1, CURRENT_DATE, 50001),
(1002, 1, 'Ana', 'Martinez',  '12345678-9', 'admin2@demo.com', '7777-0002', 'Santa Tecla, SV',  'admin2', 'demo_hash_2', 1, CURRENT_DATE, 50002),
(1003, 1, 'Luis', 'Ramirez',   '23456789-0', 'admin3@demo.com', '7777-0003', 'San Miguel, SV',  'admin3', 'demo_hash_3', 2, CURRENT_DATE, 50003);

UPDATE administradores SET estado = 1 WHERE estado NOT IN (1,2);

INSERT INTO clientes
(codigocliente, estado, empresa, telefono, correo, usuario, clave, intentos, fechaclave)
VALUES
(2001, 1, 'Comercial Alfa S.A. de C.V.',  '2222-1001', 'cliente1@demo.com', 'cliente1', 'demo_hash_c1', 0, CURRENT_DATE),
(2002, 1, 'Servicios Beta S.A. de C.V.',  '2222-1002', 'cliente2@demo.com', 'cliente2', 'demo_hash_c2', 0, CURRENT_DATE),
(2003, 1, 'Industria Gamma S.A. de C.V.', '2222-1003', 'cliente3@demo.com', 'cliente3', 'demo_hash_c3', 1, CURRENT_DATE),
(2004, 2, 'Distribuidora Delta S.A.',     '2222-1004', 'cliente4@demo.com', 'cliente4', 'demo_hash_c4', 0, CURRENT_DATE);

INSERT INTO sociedades (cliente, sociedad) VALUES
(2001, 'ALFA-01'),
(2001, 'ALFA-02'),
(2002, 'BETA-01'),
(2003, 'GAMMA-01'),
(2004, 'DELTA-01');

INSERT INTO estadocuentas
(estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral)
VALUES
(TRUE, 1001, 1, 2001, 7000000001, 9000001001, 8000002001, CURRENT_DATE - 15, 'INV', CURRENT_DATE + 15, 1, 1520.50),
(TRUE, 1002, 2, 2001, 7000000002, 9000001002, 8000002002, CURRENT_DATE - 10, 'INV', CURRENT_DATE + 20, 1,  980.00),
(TRUE, 1002, 3, 2002, 7000000003, 9000001003, 8000002003, CURRENT_DATE - 20, 'CRN', CURRENT_DATE + 10, 2, 2100.75),
(FALSE,1003, 4, 2003, 7000000004, 9000001004, 8000002004, CURRENT_DATE - 30, 'INV', CURRENT_DATE -  2, 1,  450.00),
(TRUE, 1001, 5, 2004, 7000000005, 9000001005, 8000002005, CURRENT_DATE -  5, 'INV', CURRENT_DATE + 25, 3,  300.00);

INSERT INTO indiceentregas
(responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados,
 incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado)
VALUES
(1001, 2001, 'Org Alfa',  92.50, 100, 92,  5, 3, '2%', '1%', '2%', '0%', TRUE),
(1002, 2002, 'Org Beta',  87.25,  80, 70,  8, 2, '3%', '2%', '5%', '0%', TRUE),
(1003, 2003, 'Org Gamma', 75.00,  60, 45, 10, 5, '8%', '3%', '7%', '2%', TRUE),
(1001, 2004, 'Org Delta', 60.00,  50, 30, 15, 5, '10%','5%','8%','7%', FALSE);

INSERT INTO pedido
(responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada,
 fechaentregada, fechaconfirmadaenvio, comentarios, fecharegistro, estado)
VALUES
(1001, 2001, 'POS-1001', 'OC-5001', 120, 'Papelería y suministros',  1110000001, 110, CURRENT_DATE - 2, CURRENT_DATE - 5, 'Entrega parcial', CURRENT_DATE - 10, TRUE),
(1002, 2002, 'POS-1002', 'OC-5002',  60, 'Equipo de oficina',       1110000002,  60, CURRENT_DATE - 1, CURRENT_DATE - 3, 'Completo',        CURRENT_DATE -  8, TRUE),
(1003, 2003, 'POS-1003', 'OC-5003', 200, 'Consumibles industriales', 1110000003, 180, CURRENT_DATE - 7, CURRENT_DATE - 9, 'Pendiente 20u',    CURRENT_DATE - 15, TRUE),
(1001, 2004, 'POS-1004', 'OC-5004',  30, 'Repuestos varios',        1110000004,  0, CURRENT_DATE + 5, CURRENT_DATE + 1, 'Programado',       CURRENT_DATE,      TRUE);

INSERT INTO historialcliente (usuario, accion, dispositivo, sistema)
VALUES
(2001, 'Inicio de sesión',      'Chrome - Windows', 'Portal Clientes'),
(2001, 'Consulta de estado',    'Chrome - Windows', 'Portal Clientes'),
(2002, 'Inicio de sesión',      'Firefox - Linux',  'Portal Clientes'),
(2003, 'Actualizó contraseña',  'Edge - Windows',   'Portal Clientes'),
(2004, 'Intento fallido login', 'Chrome - Android', 'Portal Clientes');

INSERT INTO historialusuario (usuario, accion, dispositivo, sistema)
VALUES
(1001, 'Creó cliente 2004',     'Chrome - Windows', 'Admin Panel'),
(1002, 'Actualizó pedido 3',    'Chrome - Windows', 'Admin Panel'),
(1003, 'Consultó reporte KPI',  'Firefox - Linux',  'Admin Panel'),
(1001, 'Creó sociedad ALFA-02', 'Edge - Windows',   'Admin Panel');

