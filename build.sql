
-------------CREAR BASE DE DATOS-------------------
CREATE DATABASE chiletel; 

--------------CREAR USUARIO-------------------------
CREATE USER chiletel WITH PASSWORD 'N1234';
       
-----------------CREAR ROLE-----------------------
CREATE ROLE desarrollador;

--GRANT CREATE SESSION, CREATE TABLE, ALTER ANY TABLE,UPDATE ANY TABLE, DROP ANY TABLE,CREATE SEQUENCE, INSERT ANY TABLE,CREATE TRIGGER, CREATE PROCEDURE, DELETE ANY TABLE, SELECT ANY TABLE TO DESARROLLADOR;  
     
-----------ASIGNAR ROLE A USUARIO-----------------

GRANT desarrollador TO chiletel;


------Permiso a usuario para usar dbms_lock-------
--grant execute on sys.dbms_lock to CHILETEL;


--------------------------------------------------------------------------------


\! psql postgresql://chiletel:N1234@localhost:5432/chiletel

---crear tablas e y datos
--\i mainV2.sql

\q