/*
	SCRIPT DE CREACION BASE DE DATOS "CLIENTS SYSTEM"
    SISTEMA DE EXPOTECNICA 2021 INSTITUTO TECNICO RICALDONE
    BACKUP LOGICO DE LA BASE DE DATOS EN POSTGRESQL
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

-- CAMBIOS DE TIPO DE DATO A CHAR EN CAMPOS DE TAMAÑO FIJO
ALTER TABLE clientes   ALTER COLUMN telefono TYPE CHAR(20);
ALTER TABLE administradores ALTER COLUMN telefono TYPE CHAR(20);
ALTER TABLE administradores ALTER COLUMN dui      TYPE CHAR(12);

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

-- DIVISAS: 
INSERT INTO divisas (divisa) VALUES ('USD'),('EUR'),('GTQ');
INSERT INTO divisas (divisa) VALUES ('GBP');
INSERT INTO divisas (divisa) VALUES ('JPY');
INSERT INTO divisas (divisa) VALUES ('MXN');
INSERT INTO divisas (divisa) VALUES ('CAD');

-- CLIENTES: 
INSERT INTO clientes (codigocliente, estado, empresa, telefono, correo, usuario, clave, intentos, fechaclave)
VALUES (2001, 1, 'Technovation S.A. de C.V.', '7700-1001', 'technovation@empresa.com', 'technovation_user', 'hash_cli_001', 0, CURRENT_DATE);
INSERT INTO clientes (codigocliente, estado, empresa, telefono, correo, usuario, clave, intentos, fechaclave)
VALUES (2002, 1, 'Soluciones Digitales Ltda.', '7700-1002', 'soldigitales@empresa.com', 'soldigitales_user', 'hash_cli_002', 0, CURRENT_DATE);
INSERT INTO clientes (codigocliente, estado, empresa, telefono, correo, usuario, clave, intentos, fechaclave)
VALUES (2003, 1, 'Grupo Comercial Orion', '7700-1003', 'grupoorion@empresa.com', 'grupoorion_user', 'hash_cli_003', 0, CURRENT_DATE);
INSERT INTO clientes (codigocliente, estado, empresa, telefono, correo, usuario, clave, intentos, fechaclave)
VALUES (2004, 1, 'Distribuidora Centroamerica', '7700-1004', 'distrocentro@empresa.com', 'distrocentro_user', 'hash_cli_004', 0, CURRENT_DATE);
INSERT INTO clientes (codigocliente, estado, empresa, telefono, correo, usuario, clave, intentos, fechaclave)
VALUES (2005, 1, 'Inversiones del Pacifico', '7700-1005', 'invpacifico@empresa.com', 'invpacifico_user', 'hash_cli_005', 0, CURRENT_DATE);
INSERT INTO clientes (codigocliente, estado, empresa, telefono, correo, usuario, clave, intentos, fechaclave)
VALUES (2006, 2, 'Logistica Express S.A.', '7700-1006', 'logexpress@empresa.com', 'logexpress_user', 'hash_cli_006', 0, CURRENT_DATE);
INSERT INTO clientes (codigocliente, estado, empresa, telefono, correo, usuario, clave, intentos, fechaclave)
VALUES (2007, 1, 'Servicios Integrales Pro', '7700-1007', 'servintegral@empresa.com', 'servintegral_user', 'hash_cli_007', 0, CURRENT_DATE);

-- ADMINISTRADORES: 5 registros 
INSERT INTO administradores(codigoadmin, estado, nombre, apellido, dui, correo, telefono, direccion, usuario, clave, tipo, fechaclave, codigo)
VALUES(1001, 1, 'Carlos', 'Hernandez', '01234567-8', 'admin1@demo.com', '7777-0001', 'San Salvador, SV', 'admin1', 'demo_hash_1', 1, CURRENT_DATE, 50001),
(1002, 1, 'Ana', 'Martinez',  '12345678-9', 'admin2@demo.com', '7777-0002', 'Santa Tecla, SV',  'admin2', 'demo_hash_2', 1, CURRENT_DATE, 50002),
(1003, 1, 'Luis', 'Ramirez',   '23456789-0', 'admin3@demo.com', '7777-0003', 'San Miguel, SV',  'admin3', 'demo_hash_3', 2, CURRENT_DATE, 50003);
INSERT INTO administradores (codigoadmin, estado, nombre, apellido, dui, correo, telefono, direccion, usuario, clave, tipo, fechaclave, codigo)
VALUES (1004, 1, 'Diego', 'Castro', '34567890-1', 'diego_castro@gmail.com', '7777-0004', 'Soyapango, SV', 'diego_castro', 'demo_hash_4', 1, CURRENT_DATE, 50004);
INSERT INTO administradores (codigoadmin, estado, nombre, apellido, dui, correo, telefono, direccion, usuario, clave, tipo, fechaclave, codigo)
VALUES (1005, 1, 'Sofia', 'Mendoza', '45678901-2', 'sofia_mendoza@gmail.com', '7777-0005', 'Mejicanos, SV', 'sofia_mendoza', 'demo_hash_5', 2, CURRENT_DATE, 50005);

-- Actualizar correos de admins existentes al formato nombre_apellido@gmail.com
UPDATE administradores SET correo = 'carlos_hernandez@gmail.com' WHERE codigoadmin = 1001;
UPDATE administradores SET correo = 'ana_martinez@gmail.com'     WHERE codigoadmin = 1002;
UPDATE administradores SET correo = 'luis_ramirez@gmail.com'     WHERE codigoadmin = 1003;

-- SOCIEDADES: 5 registros
INSERT INTO sociedades (cliente, sociedad) VALUES (2001, 'Sociedad Alfa');
INSERT INTO sociedades (cliente, sociedad) VALUES (2002, 'Sociedad Beta');
INSERT INTO sociedades (cliente, sociedad) VALUES (2003, 'Sociedad Gamma');
INSERT INTO sociedades (cliente, sociedad) VALUES (2004, 'Sociedad Delta');
INSERT INTO sociedades (cliente, sociedad) VALUES (2005, 'Sociedad Epsilon');

-- ESTADO DE CUENTAS: 100 registros
-- responsable: 1001-1005 | cliente: 2001-2007
-- sociedad: 1-5 | divisa: 1-7
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1001, 1, 2001, 100001, 200001, 300001, '2024-01-05', 'CREDITO', '2024-02-05', 1, 1500.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1002, 2, 2002, 100002, 200002, 300002, '2024-01-06', 'DEBITO', '2024-02-06', 2, 2300.50);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1003, 3, 2003, 100003, 200003, 300003, '2024-01-07', 'CREDITO', '2024-02-07', 3, 875.25);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (FALSE, 1004, 4, 2004, 100004, 200004, 300004, '2024-01-08', 'DEBITO', '2024-02-08', 4, 4200.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1005, 5, 2005, 100005, 200005, 300005, '2024-01-09', 'CREDITO', '2024-02-09', 5, 990.75);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1001, 1, 2006, 100006, 200006, 300006, '2024-01-10', 'DEBITO', '2024-02-10', 6, 3100.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (FALSE, 1002, 2, 2007, 100007, 200007, 300007, '2024-01-11', 'CREDITO', '2024-02-11', 7, 760.40);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1003, 3, 2001, 100008, 200008, 300008, '2024-01-12', 'DEBITO', '2024-02-12', 1, 2250.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1004, 4, 2002, 100009, 200009, 300009, '2024-01-13', 'CREDITO', '2024-02-13', 2, 1875.60);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1005, 5, 2003, 100010, 200010, 300010, '2024-01-14', 'DEBITO', '2024-02-14', 3, 5400.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1001, 1, 2004, 100011, 200011, 300011, '2024-01-15', 'CREDITO', '2024-02-15', 4, 1100.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (FALSE, 1002, 2, 2005, 100012, 200012, 300012, '2024-01-16', 'DEBITO', '2024-02-16', 5, 3300.90);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1003, 3, 2006, 100013, 200013, 300013, '2024-01-17', 'CREDITO', '2024-02-17', 6, 670.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1004, 4, 2007, 100014, 200014, 300014, '2024-01-18', 'DEBITO', '2024-02-18', 7, 2900.50);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1005, 5, 2001, 100015, 200015, 300015, '2024-01-19', 'CREDITO', '2024-02-19', 1, 1430.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (FALSE, 1001, 1, 2002, 100016, 200016, 300016, '2024-01-20', 'DEBITO', '2024-02-20', 2, 780.25);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1002, 2, 2003, 100017, 200017, 300017, '2024-01-21', 'CREDITO', '2024-02-21', 3, 6100.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1003, 3, 2004, 100018, 200018, 300018, '2024-01-22', 'DEBITO', '2024-02-22', 4, 2050.75);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1004, 4, 2005, 100019, 200019, 300019, '2024-01-23', 'CREDITO', '2024-02-23', 5, 3750.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (FALSE, 1005, 5, 2006, 100020, 200020, 300020, '2024-01-24', 'DEBITO', '2024-02-24', 6, 920.10);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1001, 1, 2007, 100021, 200021, 300021, '2024-01-25', 'CREDITO', '2024-02-25', 7, 4800.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1002, 2, 2001, 100022, 200022, 300022, '2024-01-26', 'DEBITO', '2024-02-26', 1, 1600.50);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1003, 3, 2002, 100023, 200023, 300023, '2024-01-27', 'CREDITO', '2024-02-27', 2, 2700.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (FALSE, 1004, 4, 2003, 100024, 200024, 300024, '2024-01-28', 'DEBITO', '2024-02-28', 3, 530.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1005, 5, 2004, 100025, 200025, 300025, '2024-01-29', 'CREDITO', '2024-02-29', 4, 8900.25);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1001, 1, 2005, 100026, 200026, 300026, '2024-02-01', 'DEBITO', '2024-03-01', 5, 1750.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1002, 2, 2006, 100027, 200027, 300027, '2024-02-02', 'CREDITO', '2024-03-02', 6, 4400.80);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (FALSE, 1003, 3, 2007, 100028, 200028, 300028, '2024-02-03', 'DEBITO', '2024-03-03', 7, 610.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1004, 4, 2001, 100029, 200029, 300029, '2024-02-04', 'CREDITO', '2024-03-04', 1, 3200.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1005, 5, 2002, 100030, 200030, 300030, '2024-02-05', 'DEBITO', '2024-03-05', 2, 2100.60);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1001, 1, 2003, 100031, 200031, 300031, '2024-02-06', 'CREDITO', '2024-03-06', 3, 990.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (FALSE, 1002, 2, 2004, 100032, 200032, 300032, '2024-02-07', 'DEBITO', '2024-03-07', 4, 5500.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1003, 3, 2005, 100033, 200033, 300033, '2024-02-08', 'CREDITO', '2024-03-08', 5, 1300.40);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1004, 4, 2006, 100034, 200034, 300034, '2024-02-09', 'DEBITO', '2024-03-09', 6, 7200.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1005, 5, 2007, 100035, 200035, 300035, '2024-02-10', 'CREDITO', '2024-03-10', 7, 855.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1001, 1, 2001, 100036, 200036, 300036, '2024-02-11', 'DEBITO', '2024-03-11', 1, 4100.75);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (FALSE, 1002, 2, 2002, 100037, 200037, 300037, '2024-02-12', 'CREDITO', '2024-03-12', 2, 2600.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1003, 3, 2003, 100038, 200038, 300038, '2024-02-13', 'DEBITO', '2024-03-13', 3, 1450.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1004, 4, 2004, 100039, 200039, 300039, '2024-02-14', 'CREDITO', '2024-03-14', 4, 3900.20);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1005, 5, 2005, 100040, 200040, 300040, '2024-02-15', 'DEBITO', '2024-03-15', 5, 700.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1001, 1, 2006, 100041, 200041, 300041, '2024-02-16', 'CREDITO', '2024-03-16', 6, 5600.90);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (FALSE, 1002, 2, 2007, 100042, 200042, 300042, '2024-02-17', 'DEBITO', '2024-03-17', 7, 1200.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1003, 3, 2001, 100043, 200043, 300043, '2024-02-18', 'CREDITO', '2024-03-18', 1, 8400.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1004, 4, 2002, 100044, 200044, 300044, '2024-02-19', 'DEBITO', '2024-03-19', 2, 2350.45);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1005, 5, 2003, 100045, 200045, 300045, '2024-02-20', 'CREDITO', '2024-03-20', 3, 1700.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (FALSE, 1001, 1, 2004, 100046, 200046, 300046, '2024-02-21', 'DEBITO', '2024-03-21', 4, 3050.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1002, 2, 2005, 100047, 200047, 300047, '2024-02-22', 'CREDITO', '2024-03-22', 5, 940.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1003, 3, 2006, 100048, 200048, 300048, '2024-02-23', 'DEBITO', '2024-03-23', 6, 6700.80);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1004, 4, 2007, 100049, 200049, 300049, '2024-02-24', 'CREDITO', '2024-03-24', 7, 1100.50);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (FALSE, 1005, 5, 2001, 100050, 200050, 300050, '2024-02-25', 'DEBITO', '2024-03-25', 1, 2800.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1001, 1, 2002, 100051, 200051, 300051, '2024-02-26', 'CREDITO', '2024-03-26', 2, 4500.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1002, 2, 2003, 100052, 200052, 300052, '2024-02-27', 'DEBITO', '2024-03-27', 3, 1350.75);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1003, 3, 2004, 100053, 200053, 300053, '2024-02-28', 'CREDITO', '2024-03-28', 4, 3600.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (FALSE, 1004, 4, 2005, 100054, 200054, 300054, '2024-03-01', 'DEBITO', '2024-04-01', 5, 800.40);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1005, 5, 2006, 100055, 200055, 300055, '2024-03-02', 'CREDITO', '2024-04-02', 6, 9100.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1001, 1, 2007, 100056, 200056, 300056, '2024-03-03', 'DEBITO', '2024-04-03', 7, 2200.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1002, 2, 2001, 100057, 200057, 300057, '2024-03-04', 'CREDITO', '2024-04-04', 1, 1650.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (FALSE, 1003, 3, 2002, 100058, 200058, 300058, '2024-03-05', 'DEBITO', '2024-04-05', 2, 4700.25);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1004, 4, 2003, 100059, 200059, 300059, '2024-03-06', 'CREDITO', '2024-04-06', 3, 1050.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1005, 5, 2004, 100060, 200060, 300060, '2024-03-07', 'DEBITO', '2024-04-07', 4, 6300.80);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1001, 1, 2005, 100061, 200061, 300061, '2024-03-08', 'CREDITO', '2024-04-08', 5, 2500.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (FALSE, 1002, 2, 2006, 100062, 200062, 300062, '2024-03-09', 'DEBITO', '2024-04-09', 6, 1800.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1003, 3, 2007, 100063, 200063, 300063, '2024-03-10', 'CREDITO', '2024-04-10', 7, 7500.60);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1004, 4, 2001, 100064, 200064, 300064, '2024-03-11', 'DEBITO', '2024-04-11', 1, 3400.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1005, 5, 2002, 100065, 200065, 300065, '2024-03-12', 'CREDITO', '2024-04-12', 2, 1950.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (FALSE, 1001, 1, 2003, 100066, 200066, 300066, '2024-03-13', 'DEBITO', '2024-04-13', 3, 640.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1002, 2, 2004, 100067, 200067, 300067, '2024-03-14', 'CREDITO', '2024-04-14', 4, 5200.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1003, 3, 2005, 100068, 200068, 300068, '2024-03-15', 'DEBITO', '2024-04-15', 5, 1250.90);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1004, 4, 2006, 100069, 200069, 300069, '2024-03-16', 'CREDITO', '2024-04-16', 6, 8800.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (FALSE, 1005, 5, 2007, 100070, 200070, 300070, '2024-03-17', 'DEBITO', '2024-04-17', 7, 2950.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1001, 1, 2001, 100071, 200071, 300071, '2024-03-18', 'CREDITO', '2024-04-18', 1, 1550.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1002, 2, 2002, 100072, 200072, 300072, '2024-03-19', 'DEBITO', '2024-04-19', 2, 4300.75);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1003, 3, 2003, 100073, 200073, 300073, '2024-03-20', 'CREDITO', '2024-04-20', 3, 900.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (FALSE, 1004, 4, 2004, 100074, 200074, 300074, '2024-03-21', 'DEBITO', '2024-04-21', 4, 6000.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1005, 5, 2005, 100075, 200075, 300075, '2024-03-22', 'CREDITO', '2024-04-22', 5, 1400.50);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1001, 1, 2006, 100076, 200076, 300076, '2024-03-23', 'DEBITO', '2024-04-23', 6, 3100.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1002, 2, 2007, 100077, 200077, 300077, '2024-03-24', 'CREDITO', '2024-04-24', 7, 7700.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (FALSE, 1003, 3, 2001, 100078, 200078, 300078, '2024-03-25', 'DEBITO', '2024-04-25', 1, 2400.20);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1004, 4, 2002, 100079, 200079, 300079, '2024-03-26', 'CREDITO', '2024-04-26', 2, 1150.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1005, 5, 2003, 100080, 200080, 300080, '2024-03-27', 'DEBITO', '2024-04-27', 3, 5800.60);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1001, 1, 2004, 100081, 200081, 300081, '2024-03-28', 'CREDITO', '2024-04-28', 4, 2050.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (FALSE, 1002, 2, 2005, 100082, 200082, 300082, '2024-03-29', 'DEBITO', '2024-04-29', 5, 4900.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1003, 3, 2006, 100083, 200083, 300083, '2024-03-30', 'CREDITO', '2024-04-30', 6, 1050.75);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1004, 4, 2007, 100084, 200084, 300084, '2024-04-01', 'DEBITO', '2024-05-01', 7, 3700.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1005, 5, 2001, 100085, 200085, 300085, '2024-04-02', 'CREDITO', '2024-05-02', 1, 6600.90);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (FALSE, 1001, 1, 2002, 100086, 200086, 300086, '2024-04-03', 'DEBITO', '2024-05-03', 2, 1350.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1002, 2, 2003, 100087, 200087, 300087, '2024-04-04', 'CREDITO', '2024-05-04', 3, 2850.40);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1003, 3, 2004, 100088, 200088, 300088, '2024-04-05', 'DEBITO', '2024-05-05', 4, 4100.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1004, 4, 2005, 100089, 200089, 300089, '2024-04-06', 'CREDITO', '2024-05-06', 5, 750.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (FALSE, 1005, 5, 2006, 100090, 200090, 300090, '2024-04-07', 'DEBITO', '2024-05-07', 6, 9200.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1001, 1, 2007, 100091, 200091, 300091, '2024-04-08', 'CREDITO', '2024-05-08', 7, 1800.50);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1002, 2, 2001, 100092, 200092, 300092, '2024-04-09', 'DEBITO', '2024-05-09', 1, 3500.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1003, 3, 2002, 100093, 200093, 300093, '2024-04-10', 'CREDITO', '2024-05-10', 2, 2100.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (FALSE, 1004, 4, 2003, 100094, 200094, 300094, '2024-04-11', 'DEBITO', '2024-05-11', 3, 5000.75);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1005, 5, 2004, 100095, 200095, 300095, '2024-04-12', 'CREDITO', '2024-05-12', 4, 1600.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1001, 1, 2005, 100096, 200096, 300096, '2024-04-13', 'DEBITO', '2024-05-13', 5, 7000.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1002, 2, 2006, 100097, 200097, 300097, '2024-04-14', 'CREDITO', '2024-05-14', 6, 2700.30);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (FALSE, 1003, 3, 2007, 100098, 200098, 300098, '2024-04-15', 'DEBITO', '2024-05-15', 7, 1100.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1004, 4, 2001, 100099, 200099, 300099, '2024-04-16', 'CREDITO', '2024-05-16', 1, 4400.00);
INSERT INTO estadocuentas (estado, responsable, sociedad, cliente, codigo, factura, asignacion, fechacontable, clase, vencimiento, divisa, totalgeneral) VALUES (TRUE, 1005, 5, 2002, 100100, 200100, 300100, '2024-04-17', 'DEBITO', '2024-05-17', 2, 3200.80);

-- INDICES DE ENTREGAS: 100 registros
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1001, 2001, 'Org Alpha', 95.50, 100, 90, 5, 5, '2.5%', '1.0%', '1.0%', '0.5%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1002, 2002, 'Org Beta', 88.00, 80, 70, 8, 2, '3.0%', '2.0%', '2.0%', '1.0%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1003, 2003, 'Org Gamma', 76.25, 120, 90, 25, 5, '5.0%', '3.0%', '4.0%', '2.0%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1004, 2004, 'Org Delta', 91.00, 60, 55, 4, 1, '1.5%', '1.0%', '0.5%', '1.0%', FALSE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1005, 2005, 'Org Epsilon', 83.75, 90, 75, 12, 3, '4.0%', '2.5%', '3.0%', '1.5%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1001, 2006, 'Org Zeta', 79.00, 110, 87, 18, 5, '6.0%', '3.5%', '4.5%', '2.5%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1002, 2007, 'Org Eta', 97.20, 50, 49, 1, 0, '0.5%', '0.5%', '0.0%', '0.0%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1003, 2001, 'Org Theta', 85.00, 70, 60, 8, 2, '2.0%', '2.0%', '2.0%', '1.0%', FALSE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1004, 2002, 'Org Iota', 72.50, 130, 95, 30, 5, '7.0%', '4.0%', '5.0%', '3.0%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1005, 2003, 'Org Kappa', 93.40, 85, 79, 5, 1, '1.0%', '1.5%', '1.0%', '0.5%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1001, 2004, 'Org Lambda', 80.00, 75, 60, 12, 3, '4.0%', '3.0%', '3.0%', '2.0%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1002, 2005, 'Org Mu', 68.00, 150, 102, 40, 8, '8.0%', '5.0%', '6.0%', '4.0%', FALSE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1003, 2006, 'Org Nu', 90.10, 95, 86, 7, 2, '2.5%', '1.5%', '2.0%', '1.0%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1004, 2007, 'Org Xi', 87.30, 65, 57, 6, 2, '2.0%', '2.0%', '1.5%', '0.5%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1005, 2001, 'Org Omicron', 74.80, 100, 75, 20, 5, '5.0%', '4.0%', '4.0%', '3.0%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1001, 2002, 'Org Pi', 96.00, 55, 53, 2, 0, '1.0%', '0.5%', '0.5%', '0.0%', FALSE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1002, 2003, 'Org Rho', 82.50, 88, 73, 12, 3, '4.0%', '2.5%', '3.5%', '2.0%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1003, 2004, 'Org Sigma', 65.70, 140, 92, 42, 6, '9.0%', '5.5%', '6.5%', '4.5%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1004, 2005, 'Org Tau', 89.90, 72, 65, 6, 1, '2.0%', '1.5%', '1.5%', '1.0%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1005, 2006, 'Org Upsilon', 78.20, 115, 90, 20, 5, '5.5%', '3.5%', '4.5%', '2.5%', FALSE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1001, 2007, 'Org Phi', 94.10, 45, 42, 3, 0, '1.5%', '1.0%', '1.0%', '0.5%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1002, 2001, 'Org Chi', 70.00, 160, 112, 42, 6, '8.0%', '5.0%', '7.0%', '4.0%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1003, 2002, 'Org Psi', 86.60, 78, 68, 8, 2, '2.5%', '2.0%', '2.0%', '1.5%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1004, 2003, 'Org Omega', 92.30, 92, 85, 6, 1, '1.5%', '1.0%', '1.5%', '0.5%', FALSE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1005, 2004, 'Org Acorn', 77.40, 105, 82, 18, 5, '5.0%', '3.0%', '4.0%', '3.0%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1001, 2005, 'Org Blaze', 98.00, 40, 39, 1, 0, '0.5%', '0.0%', '0.5%', '0.0%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1002, 2006, 'Org Cedar', 84.00, 83, 70, 11, 2, '3.5%', '2.0%', '3.0%', '2.0%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1003, 2007, 'Org Dune', 67.80, 145, 98, 40, 7, '8.5%', '5.5%', '6.0%', '4.0%', FALSE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1004, 2001, 'Org Edge', 91.70, 58, 53, 4, 1, '1.5%', '1.0%', '1.0%', '0.5%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1005, 2002, 'Org Frost', 73.50, 125, 92, 28, 5, '6.5%', '4.0%', '5.0%', '3.0%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1001, 2003, 'Org Grove', 88.90, 68, 61, 6, 1, '2.0%', '1.5%', '1.5%', '1.0%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1002, 2004, 'Org Hive', 80.60, 97, 78, 16, 3, '4.5%', '3.0%', '3.5%', '2.0%', FALSE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1003, 2005, 'Org Iris', 95.00, 35, 33, 2, 0, '1.0%', '0.5%', '0.5%', '0.0%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1004, 2006, 'Org Jade', 69.30, 135, 94, 36, 5, '7.5%', '4.5%', '5.5%', '3.5%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1005, 2007, 'Org Kite', 87.80, 62, 54, 7, 1, '2.5%', '2.0%', '2.0%', '1.5%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1001, 2001, 'Org Lime', 76.10, 112, 85, 22, 5, '5.5%', '3.5%', '4.5%', '3.0%', FALSE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1002, 2002, 'Org Mist', 93.80, 48, 45, 3, 0, '1.0%', '1.0%', '0.5%', '0.0%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1003, 2003, 'Org Nova', 82.00, 86, 71, 12, 3, '4.0%', '2.5%', '3.5%', '2.0%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1004, 2004, 'Org Onyx', 90.50, 66, 60, 5, 1, '1.5%', '1.0%', '1.0%', '0.5%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1005, 2005, 'Org Pearl', 71.40, 155, 110, 38, 7, '9.0%', '5.0%', '7.0%', '4.5%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1001, 2006, 'Org Quartz', 85.60, 74, 63, 9, 2, '3.0%', '2.0%', '2.5%', '1.5%', FALSE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1002, 2007, 'Org Ridge', 96.50, 42, 40, 2, 0, '0.5%', '0.5%', '0.5%', '0.0%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1003, 2001, 'Org Stone', 79.80, 107, 85, 18, 4, '5.0%', '3.0%', '4.0%', '2.5%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1004, 2002, 'Org Thorn', 88.20, 69, 61, 7, 1, '2.5%', '1.5%', '2.0%', '1.0%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1005, 2003, 'Org Unity', 66.90, 148, 99, 43, 6, '9.5%', '6.0%', '7.0%', '5.0%', FALSE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1001, 2004, 'Org Vapor', 92.70, 56, 52, 4, 0, '1.0%', '1.0%', '0.5%', '0.5%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1002, 2005, 'Org Willow', 75.30, 118, 89, 24, 5, '6.0%', '4.0%', '5.0%', '3.0%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1003, 2006, 'Org Xenon', 83.00, 81, 67, 12, 2, '3.5%', '2.5%', '3.0%', '2.0%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1004, 2007, 'Org Yield', 97.80, 38, 37, 1, 0, '0.5%', '0.0%', '0.5%', '0.0%', FALSE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1005, 2001, 'Org Zenith', 70.60, 138, 97, 36, 5, '7.0%', '4.5%', '6.0%', '4.0%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1001, 2002, 'Org Apex', 89.50, 71, 64, 6, 1, '2.0%', '1.5%', '1.5%', '1.0%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1002, 2003, 'Org Brick', 78.40, 109, 86, 19, 4, '5.5%', '3.5%', '4.0%', '2.5%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1003, 2004, 'Org Crest', 94.60, 44, 42, 2, 0, '0.5%', '0.5%', '0.5%', '0.0%', FALSE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1004, 2005, 'Org Drift', 81.10, 93, 76, 14, 3, '4.0%', '3.0%', '3.5%', '2.0%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1005, 2006, 'Org Echo', 68.70, 142, 97, 40, 5, '8.5%', '5.5%', '6.5%', '4.5%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1001, 2007, 'Org Flint', 90.80, 63, 57, 5, 1, '2.0%', '1.0%', '1.5%', '0.5%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1002, 2001, 'Org Gleam', 73.90, 122, 90, 27, 5, '6.5%', '4.0%', '5.5%', '3.5%', FALSE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1003, 2002, 'Org Halo', 86.90, 76, 66, 8, 2, '2.5%', '2.0%', '2.0%', '1.5%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1004, 2003, 'Org Ingot', 91.20, 59, 54, 4, 1, '1.5%', '1.0%', '1.0%', '0.5%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1005, 2004, 'Org Jolt', 77.60, 113, 88, 20, 5, '5.5%', '3.5%', '4.0%', '3.0%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1001, 2005, 'Org Kelp', 95.70, 32, 31, 1, 0, '0.5%', '0.0%', '0.5%', '0.0%', FALSE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1002, 2006, 'Org Loft', 84.40, 80, 68, 10, 2, '3.0%', '2.0%', '2.5%', '1.5%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1003, 2007, 'Org Mosaic', 67.20, 147, 99, 42, 6, '9.0%', '5.5%', '7.0%', '5.0%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1004, 2001, 'Org Nexus', 93.10, 47, 44, 3, 0, '1.0%', '0.5%', '1.0%', '0.0%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1005, 2002, 'Org Opal', 72.80, 128, 93, 30, 5, '6.5%', '4.5%', '5.5%', '3.5%', FALSE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1001, 2003, 'Org Prism', 87.00, 66, 57, 7, 2, '2.5%', '2.0%', '2.0%', '1.0%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1002, 2004, 'Org Quest', 80.30, 99, 80, 16, 3, '4.5%', '3.0%', '3.5%', '2.0%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1003, 2005, 'Org Radiant', 96.20, 37, 36, 1, 0, '0.5%', '0.0%', '0.5%', '0.0%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1004, 2006, 'Org Surge', 69.80, 132, 92, 35, 5, '7.5%', '4.5%', '6.0%', '4.0%', FALSE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1005, 2007, 'Org Titan', 89.00, 73, 65, 7, 1, '2.5%', '1.5%', '2.0%', '1.0%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1001, 2001, 'Org Umbra', 75.50, 120, 91, 24, 5, '6.0%', '4.0%', '5.0%', '3.0%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1002, 2002, 'Org Vortex', 94.30, 46, 43, 3, 0, '1.0%', '0.5%', '0.5%', '0.0%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1003, 2003, 'Org Wren', 81.70, 91, 74, 14, 3, '4.0%', '2.5%', '3.5%', '2.0%', FALSE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1004, 2004, 'Org Xray', 90.20, 64, 58, 5, 1, '1.5%', '1.0%', '1.0%', '0.5%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1005, 2005, 'Org Yonder', 71.00, 157, 112, 39, 6, '8.5%', '5.0%', '7.0%', '4.5%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1001, 2006, 'Org Zeal', 85.30, 77, 66, 9, 2, '3.0%', '2.0%', '2.5%', '1.5%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1002, 2007, 'Org Aster', 97.30, 41, 40, 1, 0, '0.5%', '0.0%', '0.5%', '0.0%', FALSE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1003, 2001, 'Org Boron', 70.20, 140, 98, 37, 5, '7.5%', '4.5%', '6.0%', '4.0%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1004, 2002, 'Org Cobalt', 88.60, 67, 59, 7, 1, '2.5%', '1.5%', '2.0%', '1.0%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1005, 2003, 'Org Decor', 77.90, 111, 87, 20, 4, '5.5%', '3.5%', '4.5%', '3.0%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1001, 2004, 'Org Ember', 95.20, 33, 31, 2, 0, '0.5%', '0.5%', '0.5%', '0.0%', FALSE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1002, 2005, 'Org Fable', 83.60, 82, 69, 11, 2, '3.5%', '2.0%', '3.0%', '2.0%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1003, 2006, 'Org Glyph', 68.40, 144, 98, 41, 5, '9.0%', '5.5%', '7.0%', '4.5%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1004, 2007, 'Org Helix', 92.00, 57, 52, 4, 1, '1.5%', '1.0%', '1.0%', '0.5%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1005, 2001, 'Org Inlay', 74.10, 126, 93, 28, 5, '6.5%', '4.0%', '5.5%', '3.5%', FALSE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1001, 2002, 'Org Jasper', 87.50, 65, 57, 7, 1, '2.5%', '2.0%', '2.0%', '1.0%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1002, 2003, 'Org Knoll', 79.60, 108, 86, 18, 4, '5.0%', '3.0%', '4.0%', '2.5%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1003, 2004, 'Org Lustre', 94.00, 43, 40, 3, 0, '1.0%', '0.5%', '0.5%', '0.0%', TRUE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1004, 2005, 'Org Matrix', 81.50, 95, 77, 15, 3, '4.5%', '3.0%', '3.5%', '2.0%', FALSE);
INSERT INTO indiceentregas (responsable, cliente, organizacion, indice, totalcompromiso, cumplidos, nocumplidos, noconsiderados, incumnoentregados, incumporcalidad, incumporfecha, incumporcantidad, estado) VALUES (1005, 2006, 'Org Nimbus', 69.50, 136, 94, 37, 5, '8.0%', '5.0%', '6.5%', '4.0%', TRUE);

-- PEDIDOS: 100 registros
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1001, 2001, 'POS-0001', 'OC-0001', 50, 'Cables HDMI 2.0 pack x10', 400001, 50, '2024-02-10', '2024-02-08', 'Entregado completo', TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1002, 2002, 'POS-0002', 'OC-0002', 30, 'Mouse inalambrico ergonomico', 400002, 28, '2024-02-11', '2024-02-09', 'Faltaron 2 unidades', TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1003, 2003, 'POS-0003', 'OC-0003', 100, 'Teclado mecanico USB', 400003, 100, '2024-02-12', '2024-02-10', NULL, TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1004, 2004, 'POS-0004', 'OC-0004', 20, 'Monitor 24 pulgadas Full HD', 400004, 20, '2024-02-13', '2024-02-11', 'Sin novedades', TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1005, 2005, 'POS-0005', 'OC-0005', 75, 'Memorias RAM DDR4 8GB', 400005, 70, '2024-02-14', '2024-02-12', 'Pendiente 5 unidades', FALSE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1001, 2006, 'POS-0006', 'OC-0006', 40, 'Disco SSD 500GB', 400006, 40, '2024-02-15', '2024-02-13', NULL, TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1002, 2007, 'POS-0007', 'OC-0007', 60, 'Impresora laser monocromo', 400007, 60, '2024-02-16', '2024-02-14', 'Entregado sin problemas', TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1003, 2001, 'POS-0008', 'OC-0008', 25, 'Switch de red 24 puertos', 400008, 25, '2024-02-17', '2024-02-15', NULL, TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1004, 2002, 'POS-0009', 'OC-0009', 80, 'Auriculares USB con microfono', 400009, 75, '2024-02-18', '2024-02-16', 'Incidencia en transporte', TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1005, 2003, 'POS-0010', 'OC-0010', 15, 'Proyector HDMI 3000 lumenes', 400010, 15, '2024-02-19', '2024-02-17', 'Verificado en destino', FALSE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1001, 2004, 'POS-0011', 'OC-0011', 55, 'Webcam 1080p Full HD', 400011, 55, '2024-02-20', '2024-02-18', NULL, TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1002, 2005, 'POS-0012', 'OC-0012', 90, 'Cable UTP cat6 rollo 300m', 400012, 90, '2024-02-21', '2024-02-19', 'OK', TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1003, 2006, 'POS-0013', 'OC-0013', 35, 'Patch panel 24 puertos cat6', 400013, 35, '2024-02-22', '2024-02-20', NULL, TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1004, 2007, 'POS-0014', 'OC-0014', 12, 'UPS 1500VA torre', 400014, 12, '2024-02-23', '2024-02-21', 'Sin observaciones', TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1005, 2001, 'POS-0015', 'OC-0015', 70, 'Rack de pared 12U', 400015, 65, '2024-02-24', '2024-02-22', 'Entrega parcial', FALSE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1001, 2002, 'POS-0016', 'OC-0016', 45, 'Tablet Android 10 pulgadas', 400016, 45, '2024-02-25', '2024-02-23', NULL, TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1002, 2003, 'POS-0017', 'OC-0017', 20, 'Laptop i5 16GB 512SSD', 400017, 20, '2024-02-26', '2024-02-24', 'Revision de calidad OK', TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1003, 2004, 'POS-0018', 'OC-0018', 65, 'Cargador universal 65W', 400018, 65, '2024-02-27', '2024-02-25', NULL, TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1004, 2005, 'POS-0019', 'OC-0019', 10, 'Router WiFi 6 doble banda', 400019, 10, '2024-02-28', '2024-02-26', 'Configurado en origen', TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1005, 2006, 'POS-0020', 'OC-0020', 85, 'Toner HP LaserJet 85A', 400020, 85, '2024-03-01', '2024-02-27', NULL, FALSE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1001, 2007, 'POS-0021', 'OC-0021', 50, 'Hub USB 3.0 7 puertos', 400021, 50, '2024-03-02', '2024-02-28', 'OK completo', TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1002, 2001, 'POS-0022', 'OC-0022', 30, 'Disco duro externo 2TB', 400022, 30, '2024-03-03', '2024-03-01', NULL, TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1003, 2002, 'POS-0023', 'OC-0023', 100, 'Memoria USB 64GB', 400023, 98, '2024-03-04', '2024-03-02', 'Faltaron 2 piezas', TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1004, 2003, 'POS-0024', 'OC-0024', 18, 'Scanner de documentos ADF', 400024, 18, '2024-03-05', '2024-03-03', NULL, TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1005, 2004, 'POS-0025', 'OC-0025', 40, 'Teclado inalambrico slim', 400025, 40, '2024-03-06', '2024-03-04', 'Entregado puntual', FALSE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1001, 2005, 'POS-0026', 'OC-0026', 22, 'Soporte monitor doble brazo', 400026, 22, '2024-03-07', '2024-03-05', NULL, TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1002, 2006, 'POS-0027', 'OC-0027', 60, 'Parlante Bluetooth portatil', 400027, 60, '2024-03-08', '2024-03-06', 'Sin incidencias', TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1003, 2007, 'POS-0028', 'OC-0028', 95, 'Resma papel A4 500 hojas', 400028, 95, '2024-03-09', '2024-03-07', NULL, TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1004, 2001, 'POS-0029', 'OC-0029', 14, 'Silla ergonomica de oficina', 400029, 14, '2024-03-10', '2024-03-08', 'Armado incluido', TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1005, 2002, 'POS-0030', 'OC-0030', 78, 'Lapicero borrable gel azul', 400030, 78, '2024-03-11', '2024-03-09', NULL, FALSE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1001, 2003, 'POS-0031', 'OC-0031', 50, 'Archivador palanca oficio', 400031, 50, '2024-03-12', '2024-03-10', NULL, TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1002, 2004, 'POS-0032', 'OC-0032', 33, 'Cinta adhesiva transparente x12', 400032, 33, '2024-03-13', '2024-03-11', 'OK', TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1003, 2005, 'POS-0033', 'OC-0033', 200, 'Sobre manila carta x50', 400033, 200, '2024-03-14', '2024-03-12', NULL, TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1004, 2006, 'POS-0034', 'OC-0034', 16, 'Calculadora cientifica', 400034, 16, '2024-03-15', '2024-03-13', 'Sin observaciones', TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1005, 2007, 'POS-0035', 'OC-0035', 88, 'Corrector liquido blanco x12', 400035, 85, '2024-03-16', '2024-03-14', 'Falto 3 unidades', FALSE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1001, 2001, 'POS-0036', 'OC-0036', 42, 'Cartucho tinta Epson color', 400036, 42, '2024-03-17', '2024-03-15', NULL, TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1002, 2002, 'POS-0037', 'OC-0037', 27, 'Extensión electrica 5 tomas', 400037, 27, '2024-03-18', '2024-03-16', 'Verificado', TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1003, 2003, 'POS-0038', 'OC-0038', 55, 'Marcador permanente negro x12', 400038, 55, '2024-03-19', '2024-03-17', NULL, TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1004, 2004, 'POS-0039', 'OC-0039', 11, 'Telefono IP VoIP PoE', 400039, 11, '2024-03-20', '2024-03-18', 'OK', TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1005, 2005, 'POS-0040', 'OC-0040', 68, 'Cuaderno universitario 100h', 400040, 68, '2024-03-21', '2024-03-19', NULL, FALSE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1001, 2006, 'POS-0041', 'OC-0041', 50, 'Cable de poder 1.5m', 400041, 50, '2024-03-22', '2024-03-20', NULL, TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1002, 2007, 'POS-0042', 'OC-0042', 38, 'Ventilador escritorio USB', 400042, 38, '2024-03-23', '2024-03-21', 'OK', TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1003, 2001, 'POS-0043', 'OC-0043', 20, 'Mochila para laptop 15.6', 400043, 20, '2024-03-24', '2024-03-22', NULL, TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1004, 2002, 'POS-0044', 'OC-0044', 72, 'Bateria recargable AA x4', 400044, 72, '2024-03-25', '2024-03-23', 'Sin incidencias', TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1005, 2003, 'POS-0045', 'OC-0045', 13, 'Pantalla tactil 10 pulgadas', 400045, 13, '2024-03-26', '2024-03-24', NULL, FALSE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1001, 2004, 'POS-0046', 'OC-0046', 46, 'Almohadilla mouse con reposamuñecas', 400046, 46, '2024-03-27', '2024-03-25', 'OK', TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1002, 2005, 'POS-0047', 'OC-0047', 82, 'Post-it notas adhesivas x100', 400047, 82, '2024-03-28', '2024-03-26', NULL, TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1003, 2006, 'POS-0048', 'OC-0048', 24, 'Pizarron blanco magnetico', 400048, 24, '2024-03-29', '2024-03-27', 'Entregado OK', TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1004, 2007, 'POS-0049', 'OC-0049', 59, 'Organizador escritorio plastico', 400049, 59, '2024-03-30', '2024-03-28', NULL, TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1005, 2001, 'POS-0050', 'OC-0050', 17, 'Servidor NAS 4 bahias', 400050, 17, '2024-04-01', '2024-03-30', NULL, FALSE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1001, 2002, 'POS-0051', 'OC-0051', 50, 'Cable HDMI 5m premium', 400051, 50, '2024-04-02', '2024-03-31', NULL, TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1002, 2003, 'POS-0052', 'OC-0052', 36, 'Mouse gaming RGB', 400052, 36, '2024-04-03', '2024-04-01', 'OK', TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1003, 2004, 'POS-0053', 'OC-0053', 90, 'Teclado numerico USB', 400053, 90, '2024-04-04', '2024-04-02', NULL, TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1004, 2005, 'POS-0054', 'OC-0054', 25, 'Monitor 27 4K UHD', 400054, 25, '2024-04-05', '2024-04-03', 'Revision calidad OK', TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1005, 2006, 'POS-0055', 'OC-0055', 60, 'Memoria RAM DDR5 16GB', 400055, 58, '2024-04-06', '2024-04-04', 'Faltaron 2', FALSE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1001, 2007, 'POS-0056', 'OC-0056', 45, 'SSD NVMe 1TB', 400056, 45, '2024-04-07', '2024-04-05', NULL, TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1002, 2001, 'POS-0057', 'OC-0057', 70, 'Impresora de etiquetas termicas', 400057, 70, '2024-04-08', '2024-04-06', 'OK', TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1003, 2002, 'POS-0058', 'OC-0058', 28, 'Access point WiFi exterior', 400058, 28, '2024-04-09', '2024-04-07', NULL, TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1004, 2003, 'POS-0059', 'OC-0059', 85, 'Auriculares gaming 7.1', 400059, 85, '2024-04-10', '2024-04-08', 'Verificado', TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1005, 2004, 'POS-0060', 'OC-0060', 19, 'Camara IP exterior PoE', 400060, 19, '2024-04-11', '2024-04-09', NULL, FALSE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1001, 2005, 'POS-0061', 'OC-0061', 53, 'Licencia antivirus anual', 400061, 53, '2024-04-12', '2024-04-10', 'Activado', TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1002, 2006, 'POS-0062', 'OC-0062', 95, 'USB-C a HDMI adaptador', 400062, 95, '2024-04-13', '2024-04-11', NULL, TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1003, 2007, 'POS-0063', 'OC-0063', 37, 'Regleta metalica 8 tomas', 400063, 37, '2024-04-14', '2024-04-12', 'OK', TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1004, 2001, 'POS-0064', 'OC-0064', 14, 'Tablet graficadora XL', 400064, 14, '2024-04-15', '2024-04-13', NULL, TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1005, 2002, 'POS-0065', 'OC-0065', 66, 'Cable de fibra optica 10m', 400065, 66, '2024-04-16', '2024-04-14', 'Entregado OK', FALSE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1001, 2003, 'POS-0066', 'OC-0066', 43, 'Laptop i7 32GB 1TB SSD', 400066, 43, '2024-04-17', '2024-04-15', NULL, TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1002, 2004, 'POS-0067', 'OC-0067', 78, 'Funda protectora laptop 14', 400067, 78, '2024-04-18', '2024-04-16', 'Sin incidencias', TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1003, 2005, 'POS-0068', 'OC-0068', 11, 'Servidor rack 2U 16GB RAM', 400068, 11, '2024-04-19', '2024-04-17', NULL, TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1004, 2006, 'POS-0069', 'OC-0069', 55, 'Disco duro NAS 4TB', 400069, 55, '2024-04-20', '2024-04-18', 'OK', TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1005, 2007, 'POS-0070', 'OC-0070', 83, 'Toner Samsung MLT-D111S', 400070, 80, '2024-04-21', '2024-04-19', 'Faltaron 3', FALSE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1001, 2001, 'POS-0071', 'OC-0071', 50, 'Pantalla interactiva 65 pulgadas', 400071, 50, '2024-04-22', '2024-04-20', NULL, TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1002, 2002, 'POS-0072', 'OC-0072', 29, 'Controlador DMX iluminacion', 400072, 29, '2024-04-23', '2024-04-21', 'Verificado', TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1003, 2003, 'POS-0073', 'OC-0073', 97, 'Carpeta de argollas oficio', 400073, 97, '2024-04-24', '2024-04-22', NULL, TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1004, 2004, 'POS-0074', 'OC-0074', 15, 'Estabilizador de voltaje 1000VA', 400074, 15, '2024-04-25', '2024-04-23', 'OK', TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1005, 2005, 'POS-0075', 'OC-0075', 73, 'Puntero laser presentacion', 400075, 73, '2024-04-26', '2024-04-24', NULL, FALSE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1001, 2006, 'POS-0076', 'OC-0076', 44, 'Microfono de condensador USB', 400076, 44, '2024-04-27', '2024-04-25', 'Listo', TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1002, 2007, 'POS-0077', 'OC-0077', 62, 'Bracket pared TV 55 a 75', 400077, 62, '2024-04-28', '2024-04-26', NULL, TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1003, 2001, 'POS-0078', 'OC-0078', 21, 'Escritorio esquinero ejecutivo', 400078, 21, '2024-04-29', '2024-04-27', 'Armado OK', TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1004, 2002, 'POS-0079', 'OC-0079', 88, 'Etiquetas adhesivas A4 x100', 400079, 88, '2024-04-30', '2024-04-28', NULL, TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1005, 2003, 'POS-0080', 'OC-0080', 16, 'Fuente de poder 650W modular', 400080, 16, '2024-05-01', '2024-04-29', 'OK', FALSE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1001, 2004, 'POS-0081', 'OC-0081', 51, 'Gabinete ATX torre media', 400081, 51, '2024-05-02', '2024-04-30', NULL, TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1002, 2005, 'POS-0082', 'OC-0082', 34, 'Tarjeta de red PCIe 1Gbps', 400082, 34, '2024-05-03', '2024-05-01', 'Verificado', TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1003, 2006, 'POS-0083', 'OC-0083', 79, 'Caja archivadora carton reforzado', 400083, 79, '2024-05-04', '2024-05-02', NULL, TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1004, 2007, 'POS-0084', 'OC-0084', 23, 'Telefono celular empresarial', 400084, 23, '2024-05-05', '2024-05-03', 'OK', TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1005, 2001, 'POS-0085', 'OC-0085', 67, 'Cable VGA 3m macho-macho', 400085, 67, '2024-05-06', '2024-05-04', NULL, FALSE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1001, 2002, 'POS-0086', 'OC-0086', 48, 'Filtro polarizador monitor 24', 400086, 48, '2024-05-07', '2024-05-05', 'Sin novedades', TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1002, 2003, 'POS-0087', 'OC-0087', 91, 'Cargador inalambrico 15W', 400087, 91, '2024-05-08', '2024-05-06', NULL, TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1003, 2004, 'POS-0088', 'OC-0088', 57, 'Supresor picos 6 tomas', 400088, 57, '2024-05-09', '2024-05-07', 'OK', TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1004, 2005, 'POS-0089', 'OC-0089', 18, 'Videoconferencia Polycom', 400089, 18, '2024-05-10', '2024-05-08', NULL, TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1005, 2006, 'POS-0090', 'OC-0090', 84, 'Porta documentos ejecutivo', 400090, 84, '2024-05-11', '2024-05-09', 'Entregado OK', FALSE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1001, 2007, 'POS-0091', 'OC-0091', 52, 'Cinta doble cara industrial', 400091, 52, '2024-05-12', '2024-05-10', NULL, TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1002, 2001, 'POS-0092', 'OC-0092', 39, 'Cámara de seguridad IP indoor', 400092, 39, '2024-05-13', '2024-05-11', 'Configurada', TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1003, 2002, 'POS-0093', 'OC-0093', 77, 'Kit de herramientas de red', 400093, 77, '2024-05-14', '2024-05-12', NULL, TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1004, 2003, 'POS-0094', 'OC-0094', 14, 'Base enfriadora laptop 17', 400094, 14, '2024-05-15', '2024-05-13', 'OK', TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1005, 2004, 'POS-0095', 'OC-0095', 69, 'Organizador cables velcro x10', 400095, 69, '2024-05-16', '2024-05-14', NULL, FALSE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1001, 2005, 'POS-0096', 'OC-0096', 47, 'Soporte celular escritorio ajustable', 400096, 47, '2024-05-17', '2024-05-15', 'Sin observaciones', TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1002, 2006, 'POS-0097', 'OC-0097', 86, 'Perforadora metalica 30h', 400097, 86, '2024-05-18', '2024-05-16', NULL, TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1003, 2007, 'POS-0098', 'OC-0098', 31, 'Engrapadora metalica 26/6', 400098, 31, '2024-05-19', '2024-05-17', 'OK', TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1004, 2001, 'POS-0099', 'OC-0099', 93, 'Rollo termico 80x80mm x10', 400099, 93, '2024-05-20', '2024-05-18', NULL, TRUE);
INSERT INTO pedido (responsable, cliente, pos, oc, cantidadsolicitada, descripcion, codigo, cantidadenviada, fechaentregada, fechaconfirmadaenvio, comentarios, estado) VALUES (1005, 2002, 'POS-0100', 'OC-0100', 26, 'Licencia Office 365 anual', 400100, 26, '2024-05-21', '2024-05-19', 'Activado', FALSE);

-- HISTORIAL USUARIO: 500 registros
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Inicio de sesion', 'PC-ADMIN-SV001', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Cierre de sesion', 'LAPTOP-ANA-002', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Creacion de pedido', 'DESK-LUIS-003', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Modificacion de cliente', 'WS-DIEGO-004', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Consulta de estado de cuenta', 'PC-SOFIA-005', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Actualizacion de pedido', 'PC-ADMIN-SV001', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Consulta de indices', 'LAPTOP-ANA-002', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Eliminacion de registro', 'DESK-LUIS-003', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Alta de nuevo cliente', 'WS-DIEGO-004', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Cambio de clave', 'PC-SOFIA-005', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Reporte generado', 'PC-ADMIN-SV001', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Inicio de sesion', 'LAPTOP-ANA-002', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Cierre de sesion', 'DESK-LUIS-003', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Consulta de pedido', 'WS-DIEGO-004', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Actualizacion de divisa', 'PC-SOFIA-005', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Inicio de sesion', 'NB-CARLOS-006', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Modificacion de pedido', 'WORKST-ANA-007', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Consulta de cliente', 'PC-RAMIREZ-008', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Alta de sociedad', 'LAPTOP-CAST-009', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Reporte de entregas', 'DESKTOP-SOF-010', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Cierre de sesion', 'NB-CARLOS-006', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Inicio de sesion', 'WORKST-ANA-007', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Actualizacion de estado', 'PC-RAMIREZ-008', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Consulta de historial', 'LAPTOP-CAST-009', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Modificacion de sociedad', 'DESKTOP-SOF-010', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Creacion de pedido', 'PC-ADMIN-SV001', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Cambio de correo', 'LAPTOP-ANA-002', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Alta de administrador', 'DESK-LUIS-003', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Bloqueo de cliente', 'WS-DIEGO-004', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Desbloqueo de cuenta', 'PC-SOFIA-005', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Exportacion CSV', 'NB-CARLOS-006', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Consulta de sociedad', 'WORKST-ANA-007', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Inicio de sesion', 'PC-RAMIREZ-008', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Reporte mensual', 'LAPTOP-CAST-009', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Modificacion de telefono', 'DESKTOP-SOF-010', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Consulta de pedido', 'PC-ADMIN-SV001', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Cierre de sesion', 'LAPTOP-ANA-002', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Actualizacion de indice', 'DESK-LUIS-003', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Consulta de divisa', 'WS-DIEGO-004', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Inicio de sesion', 'PC-SOFIA-005', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Alta de pedido urgente', 'NB-CARLOS-006', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Modificacion de estado cuenta', 'WORKST-ANA-007', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Cierre de sesion', 'PC-RAMIREZ-008', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Reporte semanal', 'LAPTOP-CAST-009', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Consulta de historial admin', 'DESKTOP-SOF-010', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Inicio de sesion', 'PC-HQ-SV011', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Actualizacion de datos', 'LAPTOP-MKTG-012', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Consulta global', 'WS-TECH-013', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Modificacion masiva', 'PC-HQ-SV014', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Cierre de sesion', 'NB-CONTAB-015', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Consulta de indices', 'PC-HQ-SV011', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Inicio de sesion', 'LAPTOP-MKTG-012', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Alta de pedido', 'WS-TECH-013', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Consulta de clientes', 'PC-HQ-SV014', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Actualizacion de clave', 'NB-CONTAB-015', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Cierre de sesion', 'PC-HQ-SV011', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Reporte de pedidos', 'LAPTOP-MKTG-012', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Modificacion de correo', 'WS-TECH-013', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Inicio de sesion', 'PC-HQ-SV014', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Eliminacion de sociedad', 'NB-CONTAB-015', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Consulta de estado cuenta', 'PC-ADMIN-SV001', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Alta de indice entrega', 'LAPTOP-ANA-002', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Inicio de sesion', 'DESK-LUIS-003', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Cierre de sesion', 'WS-DIEGO-004', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Reporte anual', 'PC-SOFIA-005', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Cambio de usuario', 'NB-CARLOS-006', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Consulta de pedido', 'WORKST-ANA-007', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Actualizacion masiva estados', 'PC-RAMIREZ-008', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Inicio de sesion', 'LAPTOP-CAST-009', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Modificacion de pedido', 'DESKTOP-SOF-010', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Cierre de sesion', 'PC-ADMIN-SV001', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Consulta global clientes', 'LAPTOP-ANA-002', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Alta de estado cuenta', 'DESK-LUIS-003', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Reporte de clientes', 'WS-DIEGO-004', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Inicio de sesion', 'PC-SOFIA-005', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Modificacion de sociedad', 'NB-CARLOS-006', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Actualizacion de indice', 'WORKST-ANA-007', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Cierre de sesion', 'PC-RAMIREZ-008', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Consulta de sociedad', 'LAPTOP-CAST-009', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Alta de pedido', 'DESKTOP-SOF-010', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Inicio de sesion', 'PC-HQ-SV011', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Consulta de estado', 'LAPTOP-MKTG-012', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Modificacion de cliente', 'WS-TECH-013', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Cierre de sesion', 'PC-HQ-SV014', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Reporte de indices', 'NB-CONTAB-015', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Exportacion PDF', 'PC-ADMIN-SV001', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Inicio de sesion', 'LAPTOP-ANA-002', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Consulta de pedidos masiva', 'DESK-LUIS-003', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Actualizacion de admin', 'WS-DIEGO-004', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Cierre de sesion', 'PC-SOFIA-005', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Consulta divisa', 'NB-CARLOS-006', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Modificacion de telefono', 'WORKST-ANA-007', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Inicio de sesion', 'PC-RAMIREZ-008', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Alta de indice', 'LAPTOP-CAST-009', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Reporte de pedidos', 'DESKTOP-SOF-010', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Modificacion de pedido', 'PC-HQ-SV011', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Consulta de historial', 'LAPTOP-MKTG-012', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Cierre de sesion', 'WS-TECH-013', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Inicio de sesion', 'PC-HQ-SV014', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Consulta masiva', 'NB-CONTAB-015', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Alta de sociedad nueva', 'PC-ADMIN-SV001', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Actualizacion masiva pedidos', 'LAPTOP-ANA-002', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Reporte completo', 'DESK-LUIS-003', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Consulta de estado cuenta', 'WS-DIEGO-004', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Inicio de sesion', 'PC-SOFIA-005', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Cierre de sesion', 'NB-CARLOS-006', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Modificacion de estado', 'WORKST-ANA-007', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Alta de cliente', 'PC-RAMIREZ-008', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Consulta de divisas', 'LAPTOP-CAST-009', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Reporte de estados', 'DESKTOP-SOF-010', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Inicio de sesion', 'PC-HQ-SV011', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Exportacion XLSX', 'LAPTOP-MKTG-012', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Inicio de sesion', 'WS-TECH-013', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Modificacion de sociedad', 'PC-HQ-SV014', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Alta de pedido express', 'NB-CONTAB-015', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Consulta de pedidos', 'PC-ADMIN-SV001', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Cierre de sesion', 'LAPTOP-ANA-002', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Reporte de clientes activos', 'DESK-LUIS-003', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Actualizacion de datos cliente', 'WS-DIEGO-004', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Consulta de pedido', 'PC-SOFIA-005', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Inicio de sesion', 'NB-CARLOS-006', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Alta de indice entrega', 'WORKST-ANA-007', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Modificacion de indice', 'PC-RAMIREZ-008', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Cierre de sesion', 'LAPTOP-CAST-009', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Inicio de sesion', 'DESKTOP-SOF-010', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Reporte de ventas', 'PC-HQ-SV011', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Consulta masiva de estados', 'LAPTOP-MKTG-012', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Alta de divisa', 'WS-TECH-013', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Modificacion de correo admin', 'PC-HQ-SV014', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Cierre de sesion', 'NB-CONTAB-015', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Consulta de clientes activos', 'PC-ADMIN-SV001', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Inicio de sesion', 'LAPTOP-ANA-002', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Actualizacion de estado cuenta', 'DESK-LUIS-003', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Alta de pedido', 'WS-DIEGO-004', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Consulta de sociedad', 'PC-SOFIA-005', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Cierre de sesion', 'NB-CARLOS-006', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Modificacion de admin', 'WORKST-ANA-007', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Reporte de estados cuenta', 'PC-RAMIREZ-008', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Inicio de sesion', 'LAPTOP-CAST-009', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Exportacion de reporte', 'DESKTOP-SOF-010', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Consulta de pedido urgente', 'PC-HQ-SV011', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Alta de cliente nuevo', 'LAPTOP-MKTG-012', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Cierre de sesion', 'WS-TECH-013', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Modificacion de indice entrega', 'PC-HQ-SV014', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Consulta de historial usuario', 'NB-CONTAB-015', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Inicio de sesion', 'PC-ADMIN-SV001', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Actualizacion de sociedad', 'LAPTOP-ANA-002', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Alta de estado cuenta', 'DESK-LUIS-003', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Reporte ejecutivo', 'WS-DIEGO-004', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Consulta de pedido express', 'PC-SOFIA-005', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Modificacion de correo', 'NB-CARLOS-006', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Cierre de sesion', 'WORKST-ANA-007', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Inicio de sesion', 'PC-RAMIREZ-008', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Consulta de indices entrega', 'LAPTOP-CAST-009', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Actualizacion de clave admin', 'DESKTOP-SOF-010', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Alta de pedido nuevo', 'PC-HQ-SV011', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Modificacion de cliente', 'LAPTOP-MKTG-012', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Reporte de pedidos entregados', 'WS-TECH-013', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Cierre de sesion', 'PC-HQ-SV014', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Inicio de sesion', 'NB-CONTAB-015', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Consulta de admin activos', 'PC-ADMIN-SV001', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Alta de pedido masivo', 'LAPTOP-ANA-002', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Consulta de estado cuenta activo', 'DESK-LUIS-003', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Inicio de sesion', 'WS-DIEGO-004', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Modificacion de divisa', 'PC-SOFIA-005', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Cierre de sesion', 'NB-CARLOS-006', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Reporte final', 'WORKST-ANA-007', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Actualizacion datos admin', 'PC-RAMIREZ-008', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Consulta de pedido', 'LAPTOP-CAST-009', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Alta de nuevo pedido', 'DESKTOP-SOF-010', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Inicio de sesion', 'PC-HQ-SV011', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Modificacion de estado', 'LAPTOP-MKTG-012', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Consulta de historial cliente', 'WS-TECH-013', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Cierre de sesion', 'PC-HQ-SV014', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Exportacion de datos', 'NB-CONTAB-015', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Actualizacion general', 'PC-ADMIN-SV001', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Inicio de sesion', 'LAPTOP-ANA-002', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Modificacion masiva pedidos', 'DESK-LUIS-003', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Alta de estado cuenta', 'WS-DIEGO-004', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Cierre de sesion', 'PC-SOFIA-005', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Consulta de pedidos activos', 'NB-CARLOS-006', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Reporte de clientes inactivos', 'WORKST-ANA-007', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Inicio de sesion', 'PC-RAMIREZ-008', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Actualizacion de estado pedido', 'LAPTOP-CAST-009', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Consulta de sociedad activa', 'DESKTOP-SOF-010', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Cierre de sesion', 'PC-HQ-SV011', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Alta de nuevo admin', 'LAPTOP-MKTG-012', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Modificacion de tipo admin', 'WS-TECH-013', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Inicio de sesion', 'PC-HQ-SV014', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Reporte de indices cumplidos', 'NB-CONTAB-015', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Consulta de pedido reciente', 'PC-ADMIN-SV001', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Actualizacion de indice cumplidos', 'LAPTOP-ANA-002', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Alta de divisa nueva', 'DESK-LUIS-003', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Cierre de sesion', 'WS-DIEGO-004', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Modificacion de fecha clave', 'PC-SOFIA-005', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Inicio de sesion', 'NB-CARLOS-006', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Consulta de estados cuenta', 'WORKST-ANA-007', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Reporte de entregas vencidas', 'PC-RAMIREZ-008', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Alta de pedido express', 'LAPTOP-CAST-009', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Inicio de sesion', 'DESKTOP-SOF-010', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Modificacion de estado cuenta', 'PC-HQ-SV011', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Cierre de sesion', 'LAPTOP-MKTG-012', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Consulta de indices nocumplidos', 'WS-TECH-013', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Alta de usuario cliente', 'PC-HQ-SV014', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Reporte ejecutivo mensual', 'NB-CONTAB-015', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Cierre de sesion', 'PC-ADMIN-SV001', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Inicio de sesion', 'LAPTOP-ANA-002', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Consulta de administradores', 'DESK-LUIS-003', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Modificacion de direccion', 'WS-DIEGO-004', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Alta de cliente corporativo', 'PC-SOFIA-005', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Consulta de indices totales', 'NB-CARLOS-006', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Actualizacion de pedido urgente', 'WORKST-ANA-007', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Cierre de sesion', 'PC-RAMIREZ-008', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Inicio de sesion', 'LAPTOP-CAST-009', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Reporte de pedidos pendientes', 'DESKTOP-SOF-010', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Modificacion de datos pedido', 'PC-HQ-SV011', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Consulta de sociedad', 'LAPTOP-MKTG-012', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Alta de pedido cliente VIP', 'WS-TECH-013', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Cierre de sesion', 'PC-HQ-SV014', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Inicio de sesion', 'NB-CONTAB-015', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1001, 'Consulta general del sistema', 'PC-ADMIN-SV001', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1002, 'Reporte de cumplimiento', 'LAPTOP-ANA-002', 'Linux');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1003, 'Inicio de sesion', 'DESK-LUIS-003', 'Windows 10 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1004, 'Actualizacion masiva clientes', 'WS-DIEGO-004', 'Windows 11 Pro');
INSERT INTO historialusuario (usuario, accion, dispositivo, sistema) VALUES (1005, 'Cierre de sesion final', 'PC-SOFIA-005', 'Linux');

-- HISTORIAL CLIENTE: 500 registros
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2001, 'Inicio de sesion', 'CLI-PC-MKT-001', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2002, 'Consulta de estado de cuenta', 'CLI-NB-VENTAS-002', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2003, 'Cierre de sesion', 'CLI-DESK-OP-003', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2004, 'Descarga de reporte', 'CLI-WS-FIN-004', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2005, 'Consulta de pedidos', 'CLI-PC-ADM-005', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2006, 'Inicio de sesion', 'CLI-NB-LOG-006', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2007, 'Actualizacion de datos', 'CLI-DESK-IT-007', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2001, 'Consulta de indice entrega', 'CLI-PC-MKT-001', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2002, 'Cierre de sesion', 'CLI-NB-VENTAS-002', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2003, 'Inicio de sesion', 'CLI-DESK-OP-003', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2004, 'Consulta de sociedad', 'CLI-WS-FIN-004', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2005, 'Cambio de clave', 'CLI-PC-ADM-005', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2006, 'Descarga de reporte PDF', 'CLI-NB-LOG-006', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2007, 'Inicio de sesion', 'CLI-DESK-IT-007', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2001, 'Consulta de pedido', 'CLI-WS-CORP-008', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2002, 'Actualizacion de correo', 'CLI-NB-OFC-009', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2003, 'Cierre de sesion', 'CLI-DESK-GER-010', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2004, 'Inicio de sesion', 'CLI-PC-ADM-005', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2005, 'Consulta estado cuenta', 'CLI-WS-FIN-004', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2006, 'Descarga de indices', 'CLI-NB-LOG-006', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2007, 'Consulta de pedidos activos', 'CLI-DESK-IT-007', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2001, 'Cierre de sesion', 'CLI-PC-MKT-001', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2002, 'Inicio de sesion', 'CLI-NB-VENTAS-002', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2003, 'Actualizacion de telefono', 'CLI-DESK-OP-003', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2004, 'Consulta de estado cuenta', 'CLI-WS-FIN-004', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2005, 'Cierre de sesion', 'CLI-PC-ADM-005', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2006, 'Inicio de sesion', 'CLI-NB-LOG-006', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2007, 'Reporte de pedidos', 'CLI-DESK-IT-007', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2001, 'Consulta de indice', 'CLI-WS-CORP-008', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2002, 'Inicio de sesion', 'CLI-NB-OFC-009', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2003, 'Descarga de estado cuenta', 'CLI-DESK-GER-010', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2004, 'Cierre de sesion', 'CLI-PC-ADM-005', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2005, 'Consulta de sociedad activa', 'CLI-WS-FIN-004', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2006, 'Inicio de sesion', 'CLI-NB-LOG-006', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2007, 'Actualizacion de empresa', 'CLI-DESK-IT-007', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2001, 'Cierre de sesion', 'CLI-PC-MKT-001', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2002, 'Consulta de indices', 'CLI-NB-VENTAS-002', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2003, 'Inicio de sesion', 'CLI-DESK-OP-003', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2004, 'Reporte de pedidos mes', 'CLI-WS-FIN-004', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2005, 'Consulta estado cuenta activo', 'CLI-PC-ADM-005', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2006, 'Cierre de sesion', 'CLI-NB-LOG-006', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2007, 'Inicio de sesion', 'CLI-DESK-IT-007', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2001, 'Cambio de usuario', 'CLI-WS-CORP-008', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2002, 'Consulta de pedido urgente', 'CLI-NB-OFC-009', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2003, 'Cierre de sesion', 'CLI-DESK-GER-010', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2004, 'Inicio de sesion', 'CLI-PC-ADM-005', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2005, 'Descarga de reporte mensual', 'CLI-WS-FIN-004', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2006, 'Consulta de indice entrega', 'CLI-NB-LOG-006', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2007, 'Inicio de sesion', 'CLI-DESK-IT-007', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2001, 'Actualizacion de clave', 'CLI-PC-MKT-001', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2002, 'Cierre de sesion', 'CLI-NB-VENTAS-002', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2003, 'Consulta de estado cuenta', 'CLI-DESK-OP-003', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2004, 'Inicio de sesion', 'CLI-WS-FIN-004', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2005, 'Reporte de indices cumplidos', 'CLI-PC-ADM-005', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2006, 'Consulta de pedidos mes', 'CLI-NB-LOG-006', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2007, 'Cierre de sesion', 'CLI-DESK-IT-007', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2001, 'Inicio de sesion', 'CLI-WS-CORP-008', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2002, 'Consulta de sociedad', 'CLI-NB-OFC-009', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2003, 'Actualizacion de correo', 'CLI-DESK-GER-010', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2004, 'Cierre de sesion', 'CLI-PC-ADM-005', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2005, 'Inicio de sesion', 'CLI-WS-FIN-004', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2006, 'Descarga de PDF estado cuenta', 'CLI-NB-LOG-006', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2007, 'Consulta de pedido activo', 'CLI-DESK-IT-007', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2001, 'Cierre de sesion', 'CLI-PC-MKT-001', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2002, 'Inicio de sesion', 'CLI-NB-VENTAS-002', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2003, 'Consulta de pedidos historico', 'CLI-DESK-OP-003', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2004, 'Actualizacion de empresa', 'CLI-WS-FIN-004', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2005, 'Cierre de sesion', 'CLI-PC-ADM-005', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2006, 'Inicio de sesion', 'CLI-NB-LOG-006', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2007, 'Consulta de estado cuenta', 'CLI-DESK-IT-007', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2001, 'Inicio de sesion', 'CLI-WS-CORP-008', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2002, 'Reporte de pedidos descarga', 'CLI-NB-OFC-009', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2003, 'Inicio de sesion', 'CLI-DESK-GER-010', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2004, 'Consulta de indice reciente', 'CLI-PC-ADM-005', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2005, 'Cierre de sesion', 'CLI-WS-FIN-004', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2006, 'Actualizacion de telefono', 'CLI-NB-LOG-006', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2007, 'Inicio de sesion', 'CLI-DESK-IT-007', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2001, 'Descarga reporte anual', 'CLI-PC-MKT-001', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2002, 'Cierre de sesion', 'CLI-NB-VENTAS-002', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2003, 'Consulta de sociedad asignada', 'CLI-DESK-OP-003', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2004, 'Inicio de sesion', 'CLI-WS-FIN-004', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2005, 'Actualizacion de usuario', 'CLI-PC-ADM-005', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2006, 'Reporte de entregas', 'CLI-NB-LOG-006', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2007, 'Cierre de sesion', 'CLI-DESK-IT-007', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2001, 'Inicio de sesion', 'CLI-WS-CORP-008', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2002, 'Consulta de estado', 'CLI-NB-OFC-009', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2003, 'Inicio de sesion', 'CLI-DESK-GER-010', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2004, 'Cierre de sesion', 'CLI-PC-ADM-005', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2005, 'Descarga estado cuenta PDF', 'CLI-WS-FIN-004', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2006, 'Consulta de pedido reciente', 'CLI-NB-LOG-006', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2007, 'Inicio de sesion', 'CLI-DESK-IT-007', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2001, 'Cierre de sesion', 'CLI-PC-MKT-001', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2002, 'Consulta de indices generales', 'CLI-NB-VENTAS-002', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2003, 'Actualizacion de estado', 'CLI-DESK-OP-003', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2004, 'Inicio de sesion', 'CLI-WS-FIN-004', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2005, 'Consulta de pedido express', 'CLI-PC-ADM-005', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2006, 'Cierre de sesion', 'CLI-NB-LOG-006', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2007, 'Inicio de sesion', 'CLI-DESK-IT-007', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2001, 'Reporte de pedidos activos', 'CLI-WS-CORP-008', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2002, 'Inicio de sesion', 'CLI-NB-OFC-009', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2003, 'Consulta de historial', 'CLI-DESK-GER-010', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2004, 'Cierre de sesion', 'CLI-PC-ADM-005', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2005, 'Actualizacion de clave cliente', 'CLI-WS-FIN-004', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2006, 'Inicio de sesion', 'CLI-NB-LOG-006', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2007, 'Descarga reporte semanal', 'CLI-DESK-IT-007', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2001, 'Inicio de sesion', 'CLI-PC-MKT-001', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2002, 'Cierre de sesion', 'CLI-NB-VENTAS-002', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2003, 'Consulta de estado cuenta reciente', 'CLI-DESK-OP-003', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2004, 'Inicio de sesion', 'CLI-WS-FIN-004', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2005, 'Reporte de entrega cumplida', 'CLI-PC-ADM-005', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2006, 'Actualizacion empresa cliente', 'CLI-NB-LOG-006', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2007, 'Cierre de sesion', 'CLI-DESK-IT-007', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2001, 'Consulta de pedido nuevo', 'CLI-WS-CORP-008', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2002, 'Inicio de sesion', 'CLI-NB-OFC-009', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2003, 'Cierre de sesion', 'CLI-DESK-GER-010', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2004, 'Consulta de indice general', 'CLI-PC-ADM-005', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2005, 'Inicio de sesion', 'CLI-WS-FIN-004', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2006, 'Descarga de reporte indice', 'CLI-NB-LOG-006', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2007, 'Inicio de sesion', 'CLI-DESK-IT-007', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2001, 'Cierre de sesion', 'CLI-PC-MKT-001', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2002, 'Consulta general de pedidos', 'CLI-NB-VENTAS-002', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2003, 'Inicio de sesion', 'CLI-DESK-OP-003', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2004, 'Actualizacion de sociedad', 'CLI-WS-FIN-004', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2005, 'Cierre de sesion', 'CLI-PC-ADM-005', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2006, 'Inicio de sesion', 'CLI-NB-LOG-006', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2007, 'Consulta de estado cuenta activo', 'CLI-DESK-IT-007', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2001, 'Inicio de sesion', 'CLI-WS-CORP-008', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2002, 'Reporte final del mes', 'CLI-NB-OFC-009', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2003, 'Cierre de sesion', 'CLI-DESK-GER-010', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2004, 'Inicio de sesion', 'CLI-PC-ADM-005', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2005, 'Consulta de indices historicos', 'CLI-WS-FIN-004', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2006, 'Actualizacion de datos empresa', 'CLI-NB-LOG-006', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2007, 'Cierre de sesion', 'CLI-DESK-IT-007', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2001, 'Descarga de estado cuenta', 'CLI-PC-MKT-001', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2002, 'Inicio de sesion', 'CLI-NB-VENTAS-002', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2003, 'Consulta de pedido reciente', 'CLI-DESK-OP-003', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2004, 'Cierre de sesion', 'CLI-WS-FIN-004', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2005, 'Inicio de sesion', 'CLI-PC-ADM-005', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2006, 'Consulta de pedido express', 'CLI-NB-LOG-006', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2007, 'Inicio de sesion', 'CLI-DESK-IT-007', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2001, 'Cierre de sesion', 'CLI-WS-CORP-008', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2002, 'Consulta de sociedad empresa', 'CLI-NB-OFC-009', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2003, 'Inicio de sesion', 'CLI-DESK-GER-010', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2004, 'Actualizacion de telefono', 'CLI-PC-ADM-005', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2005, 'Consulta de estado cuenta', 'CLI-WS-FIN-004', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2006, 'Cierre de sesion', 'CLI-NB-LOG-006', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2007, 'Reporte de pedidos entregados', 'CLI-DESK-IT-007', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2001, 'Inicio de sesion', 'CLI-PC-MKT-001', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2002, 'Descarga indices mensuales', 'CLI-NB-VENTAS-002', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2003, 'Cierre de sesion', 'CLI-DESK-OP-003', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2004, 'Inicio de sesion', 'CLI-WS-FIN-004', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2005, 'Consulta de pedidos pendientes', 'CLI-PC-ADM-005', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2006, 'Inicio de sesion', 'CLI-NB-LOG-006', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2007, 'Actualizacion de clave', 'CLI-DESK-IT-007', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2001, 'Consulta de indice historico', 'CLI-WS-CORP-008', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2002, 'Cierre de sesion', 'CLI-NB-OFC-009', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2003, 'Inicio de sesion', 'CLI-DESK-GER-010', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2004, 'Reporte de estados cuenta', 'CLI-PC-ADM-005', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2005, 'Consulta de sociedad', 'CLI-WS-FIN-004', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2006, 'Descarga de reporte PDF', 'CLI-NB-LOG-006', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2007, 'Cierre de sesion', 'CLI-DESK-IT-007', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2001, 'Inicio de sesion', 'CLI-PC-MKT-001', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2002, 'Consulta de pedido detalle', 'CLI-NB-VENTAS-002', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2003, 'Actualizacion de correo', 'CLI-DESK-OP-003', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2004, 'Cierre de sesion', 'CLI-WS-FIN-004', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2005, 'Inicio de sesion', 'CLI-PC-ADM-005', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2006, 'Consulta de pedido nuevo', 'CLI-NB-LOG-006', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2007, 'Inicio de sesion', 'CLI-DESK-IT-007', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2001, 'Cierre de sesion', 'CLI-WS-CORP-008', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2002, 'Reporte de indice entrega', 'CLI-NB-OFC-009', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2003, 'Inicio de sesion', 'CLI-DESK-GER-010', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2004, 'Consulta de estado cuenta vencido', 'CLI-PC-ADM-005', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2005, 'Cierre de sesion', 'CLI-WS-FIN-004', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2006, 'Inicio de sesion', 'CLI-NB-LOG-006', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2007, 'Actualizacion de datos empresa', 'CLI-DESK-IT-007', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2001, 'Consulta de pedido historico', 'CLI-PC-MKT-001', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2002, 'Inicio de sesion', 'CLI-NB-VENTAS-002', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2003, 'Cierre de sesion', 'CLI-DESK-OP-003', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2004, 'Inicio de sesion', 'CLI-WS-FIN-004', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2005, 'Descarga de reporte indices', 'CLI-PC-ADM-005', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2006, 'Consulta estado cuenta activo', 'CLI-NB-LOG-006', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2007, 'Cierre de sesion', 'CLI-DESK-IT-007', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2001, 'Inicio de sesion', 'CLI-WS-CORP-008', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2002, 'Consulta de pedido activo mes', 'CLI-NB-OFC-009', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2003, 'Inicio de sesion', 'CLI-DESK-GER-010', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2004, 'Actualizacion de empresa', 'CLI-PC-ADM-005', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2005, 'Cierre de sesion', 'CLI-WS-FIN-004', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2006, 'Inicio de sesion', 'CLI-NB-LOG-006', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2007, 'Reporte de pedidos completos', 'CLI-DESK-IT-007', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2001, 'Cierre de sesion', 'CLI-PC-MKT-001', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2002, 'Consulta de indice reciente', 'CLI-NB-VENTAS-002', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2003, 'Inicio de sesion', 'CLI-DESK-OP-003', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2004, 'Consulta de pedidos semana', 'CLI-WS-FIN-004', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2005, 'Inicio de sesion', 'CLI-PC-ADM-005', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2006, 'Actualizacion de clave empresa', 'CLI-NB-LOG-006', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2007, 'Inicio de sesion', 'CLI-DESK-IT-007', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2001, 'Consulta de estado cuenta mes', 'CLI-WS-CORP-008', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2002, 'Cierre de sesion', 'CLI-NB-OFC-009', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2003, 'Descarga reporte completo', 'CLI-DESK-GER-010', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2004, 'Inicio de sesion', 'CLI-PC-ADM-005', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2005, 'Consulta de sociedad activa', 'CLI-WS-FIN-004', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2006, 'Inicio de sesion', 'CLI-NB-LOG-006', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2007, 'Cierre de sesion', 'CLI-DESK-IT-007', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2001, 'Reporte de entrega nocumplida', 'CLI-PC-MKT-001', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2002, 'Inicio de sesion', 'CLI-NB-VENTAS-002', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2003, 'Actualizacion de datos cliente', 'CLI-DESK-OP-003', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2004, 'Cierre de sesion', 'CLI-WS-FIN-004', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2005, 'Inicio de sesion', 'CLI-PC-ADM-005', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2006, 'Consulta de pedido urgente', 'CLI-NB-LOG-006', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2007, 'Inicio de sesion', 'CLI-DESK-IT-007', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2001, 'Cierre de sesion', 'CLI-WS-CORP-008', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2002, 'Descarga de reporte semanal', 'CLI-NB-OFC-009', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2003, 'Inicio de sesion', 'CLI-DESK-GER-010', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2004, 'Consulta de pedidos historicos', 'CLI-PC-ADM-005', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2005, 'Cierre de sesion', 'CLI-WS-FIN-004', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2006, 'Actualizacion empresa activa', 'CLI-NB-LOG-006', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2007, 'Consulta de indice cumplido', 'CLI-DESK-IT-007', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2001, 'Inicio de sesion', 'CLI-PC-MKT-001', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2002, 'Consulta de estado activo', 'CLI-NB-VENTAS-002', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2003, 'Cierre de sesion', 'CLI-DESK-OP-003', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2004, 'Inicio de sesion', 'CLI-WS-FIN-004', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2005, 'Reporte final trimestral', 'CLI-PC-ADM-005', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2006, 'Inicio de sesion', 'CLI-NB-LOG-006', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2007, 'Cierre de sesion', 'CLI-DESK-IT-007', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2001, 'Consulta general del sistema', 'CLI-WS-CORP-008', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2002, 'Inicio de sesion', 'CLI-NB-OFC-009', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2003, 'Actualizacion de usuario', 'CLI-DESK-GER-010', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2004, 'Cierre de sesion', 'CLI-PC-ADM-005', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2005, 'Inicio de sesion', 'CLI-WS-FIN-004', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2006, 'Descarga de estado cuenta final', 'CLI-NB-LOG-006', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2007, 'Inicio de sesion', 'CLI-DESK-IT-007', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2001, 'Cierre de sesion final', 'CLI-PC-MKT-001', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2002, 'Consulta de pedido final mes', 'CLI-NB-VENTAS-002', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2003, 'Inicio de sesion', 'CLI-DESK-OP-003', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2004, 'Actualizacion de estado final', 'CLI-WS-FIN-004', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2005, 'Cierre de sesion', 'CLI-PC-ADM-005', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2006, 'Inicio de sesion', 'CLI-NB-LOG-006', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2007, 'Reporte final anual', 'CLI-DESK-IT-007', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2001, 'Inicio de sesion', 'CLI-WS-CORP-008', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2002, 'Cierre de sesion', 'CLI-NB-OFC-009', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2003, 'Consulta final de pedidos', 'CLI-DESK-GER-010', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2004, 'Inicio de sesion', 'CLI-PC-ADM-005', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2005, 'Consulta de indice final', 'CLI-WS-FIN-004', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2006, 'Cierre de sesion', 'CLI-NB-LOG-006', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2007, 'Actualizacion final de datos', 'CLI-DESK-IT-007', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2001, 'Cierre de sesion', 'CLI-PC-MKT-001', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2002, 'Reporte de cumplimiento final', 'CLI-NB-VENTAS-002', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2003, 'Inicio de sesion', 'CLI-DESK-OP-003', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2004, 'Consulta de pedidos finales', 'CLI-WS-FIN-004', 'Linux');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2005, 'Inicio de sesion', 'CLI-PC-ADM-005', 'Windows 10 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2006, 'Descarga reporte anual final', 'CLI-NB-LOG-006', 'Windows 11 Pro');
INSERT INTO historialcliente (usuario, accion, dispositivo, sistema) VALUES (2007, 'Cierre de sesion final sistema', 'CLI-DESK-IT-007', 'Linux');