------------------SECUANCIAS
CREATE SEQUENCE USUARIOS_SEQ
  MINVALUE 1
  MAXVALUE 9999999999
  NOCACHE
  START WITH 1
  INCREMENT BY 1;
-----------------------------------
CREATE SEQUENCE ROLES_SEQ
  MINVALUE 1
  MAXVALUE 9999999999
  NOCACHE
  START WITH 1
  INCREMENT BY 1;
  ---------------------------------
  CREATE SEQUENCE TIPOS_CLIENTE_SEQ
  MINVALUE 1
  MAXVALUE 9999999999
  NOCACHE
  START WITH 1
  INCREMENT BY 1; 
 -------------------------------------- 
  CREATE SEQUENCE ZONAS_SEQ
  MINVALUE 1
  MAXVALUE 9999999999
  NOCACHE
  START WITH 1
  INCREMENT BY 1;
  -----------------------------------
  CREATE SEQUENCE CLIENTES_SEQ
  MINVALUE 1
  MAXVALUE 9999999999
  NOCACHE
  START WITH 1
  INCREMENT BY 1;
  ---------------------------------
  CREATE SEQUENCE TIPOS_INCIDENCIA_SEQ
  MINVALUE 1
  MAXVALUE 9999999999
  NOCACHE
  START WITH 1
  INCREMENT BY 1;
  ---------------------------------
  CREATE SEQUENCE INCIDENCIAS_seq
  MINVALUE 1
  MAXVALUE 9999999999
  NOCACHE
  START WITH 1
  INCREMENT BY 1;
  ---------------------------------
  CREATE SEQUENCE ORDENES_ATENCION_seq
  MINVALUE 1
  MAXVALUE 9999999999
  NOCACHE
  START WITH 1
  INCREMENT BY 1;
  ---------------------------------------
  CREATE SEQUENCE CUADRILLAS_seq
  MINVALUE 1
  MAXVALUE 9999999999
  NOCACHE
  START WITH 1
  INCREMENT BY 1;
  ----------------------------------------
  CREATE SEQUENCE TECNICOS_seq
  MINVALUE 1
  MAXVALUE 9999999999
  NOCACHE
  START WITH 1
  INCREMENT BY 1;
  -------------------------------------
  CREATE SEQUENCE AGENDAS_seq
  MINVALUE 1
  MAXVALUE 9999999999
  NOCACHE
  START WITH 1
  INCREMENT BY 1;
-------------------TABLAS--------------------------------
--------------------------------------------------------------
CREATE TABLE agendas (
    id_agenda          NUMBER(10) DEFAULT AGENDAS_SEQ.NEXTVAL NOT NULL,
    id_orden_atencion  NUMBER(10) NOT NULL,
    id_tecnico         NUMBER(10),
    t_atencion         NUMBER(2),
    h_inicio           TIMESTAMP(0),
    h_final            TIMESTAMP(0),
    fecha              DATE NOT NULL 
);

CREATE INDEX idx_agendas_01 ON agendas (id_tecnico);
CREATE INDEX idx_agendas_02 ON agendas (fecha);
CREATE UNIQUE INDEX uk_agendas_01 ON agendas (id_orden_atencion);

ALTER TABLE agendas
    ADD CONSTRAINT agendas_pk PRIMARY KEY ( id_agenda );

ALTER TABLE agendas
    ADD CONSTRAINT uk_agendas_01 UNIQUE ( id_orden_atencion );


---------------------------------------------------------------------
CREATE TABLE clientes (
    id_cliente       NUMBER(10) NOT NULL,
    nombre           VARCHAR2(50 CHAR),
    apellido         VARCHAR2(50 CHAR),
    identificacion   NUMBER(20),
    id_tipo_cliente  NUMBER(10) NOT NULL,
    email            VARCHAR2(100 CHAR),
    telefono         VARCHAR2(20 CHAR),
    direccion        VARCHAR2(40 CHAR),
    id_zona          NUMBER(10) NOT NULL
);

CREATE UNIQUE INDEX idx_clientes_01 ON clientes (identificacion);

ALTER TABLE clientes
    ADD CONSTRAINT clientes_pk PRIMARY KEY ( id_cliente );

ALTER TABLE clientes
    ADD CONSTRAINT idx_clientes_01 UNIQUE ( identificacion )
        USING INDEX idx_clientes_01;


-------------------------------------------------------------
CREATE TABLE cuadrillas (
    nombre        VARCHAR2(20 CHAR),
    id_cuadrilla  NUMBER(10) NOT NULL,
    borrado       NUMBER(1) DEFAULT 0 NOT NULL
);

CREATE UNIQUE INDEX idx_cuadrillas_01 ON cuadrillas (nombre);

ALTER TABLE cuadrillas
    ADD CONSTRAINT cuadrillas_pk PRIMARY KEY ( id_cuadrilla );

ALTER TABLE cuadrillas
    ADD CONSTRAINT idx_cuadrillas_01 UNIQUE ( nombre )
        USING INDEX idx_cuadrillas_01;



----------------------------------------------------------------
CREATE TABLE incidencias (
    id_incidencia       NUMBER(10) NOT NULL,
    id_cliente          NUMBER(10) NOT NULL,
    id_tipo_incidencia  NUMBER(10) NOT NULL,
    descripcion         VARCHAR2(150 CHAR),
    fecha_registro      DATE NOT NULL 
);

CREATE UNIQUE INDEX idx_incidencias_01 ON
    incidencias (fecha_registro);

ALTER TABLE incidencias
    ADD CONSTRAINT incidencias_pk PRIMARY KEY ( id_incidencia );

ALTER TABLE incidencias
    ADD CONSTRAINT idx_incidencias_01 UNIQUE ( fecha_registro )
        USING INDEX idx_incidencias_01;


-----------------------------------------------------------------
CREATE TABLE ordenes_atencion (
    id_orden_atencion  NUMBER(10) NOT NULL,
    id_incidencia      NUMBER(10) NOT NULL,
    numero_orden       VARCHAR2(100 CHAR),
    agendado           NUMBER(1)
);

CREATE UNIQUE INDEX idx_tordenes_atencion_01 ON
    ordenes_atencion ( id_incidencia);

ALTER TABLE ordenes_atencion
    ADD CONSTRAINT ordenes_atencion_pk PRIMARY KEY ( id_orden_atencion );

ALTER TABLE ordenes_atencion
    ADD CONSTRAINT idx_tordenes_atencion_01 UNIQUE ( id_incidencia )
        USING INDEX idx_tordenes_atencion_01;


-------------------------------------------------------------
CREATE TABLE roles (
    id_role  NUMBER(10) NOT NULL,
    nombre   VARCHAR2(255 CHAR)
);
ALTER TABLE roles
    ADD CONSTRAINT roles_pk PRIMARY KEY ( id_role );


--------------------------------------------------------------
CREATE TABLE tecnicos (
    id_tecnico      NUMBER(10) NOT NULL,
    nombre          VARCHAR2(50 CHAR),
    apellido        VARCHAR2(50 CHAR),
    identificacion  NUMBER(20),
    email           VARCHAR2(100 CHAR),
    telefono        VARCHAR2(20 CHAR),
    direccion       VARCHAR2(40 CHAR),
    id_cuadrilla    NUMBER(10) NOT NULL,
    borrado         NUMBER(1) DEFAULT 0 NOT NULL
);

CREATE UNIQUE INDEX idx_tecnicos_01 ON tecnicos (identificacion);

ALTER TABLE tecnicos
    ADD CONSTRAINT tecnicos_pk PRIMARY KEY ( id_tecnico );

ALTER TABLE tecnicos
    ADD CONSTRAINT idx_tecnicos_01 UNIQUE ( identificacion )
        USING INDEX idx_tecnicos_01;


--------------------------------------------------------------
CREATE TABLE tipos_cliente (
    id_tipo_cliente  NUMBER(10) NOT NULL,
    nombre           VARCHAR2(40 CHAR),
    prioridad        NUMBER(10)
);

ALTER TABLE tipos_cliente
    ADD CONSTRAINT tipos_cliente_pk PRIMARY KEY ( id_tipo_cliente );
    
ALTER TABLE tipos_cliente
  add constraint UK_tipos_cliente_01
  unique (prioridad);

--------------------------------------
CREATE TABLE tipos_incidencia (
    id_tipo_incidencia  NUMBER(10) NOT NULL,
    nombre               VARCHAR2(40 CHAR),
    prioridad            NUMBER(10),
    tiempo_atencion      NUMBER(10) NOT NULL
);

ALTER TABLE tipos_incidencia
    ADD CONSTRAINT tipos_incidencia_pk PRIMARY KEY ( id_tipos_incidencia );
ALTER TABLE tipos_incidencia
  add constraint UK_tipos_incidencia_01
  unique (prioridad);
-----------------------------------------------------------------------------
CREATE TABLE tipos_incidencia_tecnicos (
    id_tecnico          NUMBER(10) NOT NULL,
    id_tipo_incidencia  NUMBER(10) NOT NULL
);

ALTER TABLE tipos_incidencia_tecnicos
    ADD CONSTRAINT tipos_incidencia_tecnicos_pk PRIMARY KEY ( id_tecnico,
                                                              id_tipo_incidencia );
------------------------------------------------
CREATE TABLE usuarios (
    id_usuario      NUMBER(10) NOT NULL,
    nombre          VARCHAR2(20 CHAR),
    nombre_usuario  VARCHAR2(255 CHAR),
    email           VARCHAR2(100 CHAR),
    password        VARCHAR2(100 CHAR)
);

CREATE UNIQUE INDEX idx_usuarios_01 ON usuarios (nombre_usuario);

ALTER TABLE usuarios
    ADD CONSTRAINT usuarios_pk PRIMARY KEY ( id_usuario );

ALTER TABLE usuarios
    ADD CONSTRAINT idx_usuarios_01 UNIQUE ( nombre_usuario )
        USING INDEX idx_usuarios_01;


-------------------------------------------------
CREATE TABLE usuarios_roles (
    id_usuario  NUMBER(10) NOT NULL,
    id_rol      NUMBER(10) NOT NULL
);

ALTER TABLE usuarios_roles
    ADD CONSTRAINT usuarios_roles_pk PRIMARY KEY ( id_usuario,
                                                   id_rol );
------------------------------------------------
CREATE TABLE zonas (
    nombre   VARCHAR2(40 CHAR),
    id_zona  NUMBER(10) NOT NULL
);

CREATE UNIQUE INDEX idx_zonas_01 ON zonas (nombre);

ALTER TABLE zonas
    ADD CONSTRAINT zonas_pk PRIMARY KEY ( id_zona );

ALTER TABLE zonas
    ADD CONSTRAINT idx_zonas_01 UNIQUE ( nombre )
        USING INDEX idx_zonas_01;

-----------------------------------------------------
CREATE TABLE zonas_cuadrillas (
    id_zona       NUMBER(10) NOT NULL,
    id_cuadrilla  NUMBER(10) NOT NULL
);

ALTER TABLE zonas_cuadrillas
    ADD CONSTRAINT zonas_cuadrillas_pk PRIMARY KEY ( id_zona,
                                                     id_cuadrilla );


---------------------------FORANEAS-------------------------------------
ALTER TABLE agendas
    ADD CONSTRAINT fk_agendas_ordenes_atencion_01 FOREIGN KEY ( id_orden_atencion )
        REFERENCES ordenes_atencion ( id_orden_atencion )
    NOT DEFERRABLE;

ALTER TABLE clientes
    ADD CONSTRAINT fk_cliente_tipo_cliente_01 FOREIGN KEY ( id_tipo_cliente )
        REFERENCES tipos_cliente ( id_tipo_cliente )
    NOT DEFERRABLE;

ALTER TABLE clientes
    ADD CONSTRAINT fk_cliente_zonas_02 FOREIGN KEY ( id_zona )
        REFERENCES zonas ( id_zona )
    NOT DEFERRABLE;

ALTER TABLE incidencias
    ADD CONSTRAINT fk_incidencias_clientes_01 FOREIGN KEY ( id_cliente )
        REFERENCES clientes ( id_cliente )
    NOT DEFERRABLE;

ALTER TABLE incidencias
    ADD CONSTRAINT fk_incidencias_tipos_incidencia_02 FOREIGN KEY ( id_tipo_incidencia )
        REFERENCES tipos_incidencia ( id_tipos_incidencia )
    NOT DEFERRABLE;

ALTER TABLE ordenes_atencion
    ADD CONSTRAINT fk_ordenes_atencion_incidencias_01 FOREIGN KEY ( id_incidencia )
        REFERENCES incidencias ( id_incidencia )
    NOT DEFERRABLE;

ALTER TABLE tecnicos
    ADD CONSTRAINT fk_tecnico_cuadrilla_01 FOREIGN KEY ( id_cuadrilla )
        REFERENCES cuadrillas ( id_cuadrilla )
    NOT DEFERRABLE;

ALTER TABLE tipos_incidencia_tecnicos
    ADD CONSTRAINT fk_tipos_incidencia_tecnicos_01 FOREIGN KEY ( id_tipo_incidencia )
        REFERENCES tipos_incidencia ( id_tipos_incidencia )
    NOT DEFERRABLE;

ALTER TABLE tipos_incidencia_tecnicos
    ADD CONSTRAINT fk_tipos_incidencia_tecnicos_02 FOREIGN KEY ( id_tecnico )
        REFERENCES tecnicos ( id_tecnico )
    NOT DEFERRABLE;

ALTER TABLE usuarios_roles
    ADD CONSTRAINT fk_usuarios_roles_roles_02 FOREIGN KEY ( id_rol )
        REFERENCES roles ( id_role )
    NOT DEFERRABLE;

ALTER TABLE usuarios_roles
    ADD CONSTRAINT fk_usuarios_roles_usuarios_01 FOREIGN KEY ( id_usuario )
        REFERENCES usuarios ( id_usuario )
    NOT DEFERRABLE;

ALTER TABLE zonas_cuadrillas
    ADD CONSTRAINT fk_zonas_cuadrillas_01 FOREIGN KEY ( id_cuadrilla )
        REFERENCES cuadrillas ( id_cuadrilla )
    NOT DEFERRABLE;

ALTER TABLE zonas_cuadrillas
    ADD CONSTRAINT fk_zonas_cuadrillas_02 FOREIGN KEY ( id_zona )
        REFERENCES zonas ( id_zona )
    NOT DEFERRABLE;


