
show con_name;
alter session set container=xepdb1;
alter session set "_ORACLE_SCRIPT"=true;

--------------CREAR USUARIO-------------------------
CREATE USER CHILETEL IDENTIFIED BY N1234
       DEFAULT TABLESPACE system 
       QUOTA UNLIMITED ON system;
       
-----------------CREAR ROLE-----------------------
CREATE ROLE DESARROLLADOR;
GRANT CREATE SESSION, CREATE TABLE, ALTER ANY TABLE,UPDATE ANY TABLE, DROP ANY TABLE,CREATE SEQUENCE, INSERT ANY TABLE,CREATE TRIGGER, CREATE PROCEDURE, DELETE ANY TABLE, SELECT ANY TABLE TO DESARROLLADOR;  
       
-----------ASIGNAR ROLE A USUARIO-----------------

GRANT DESARROLLADOR TO CHILETEL;


------Permiso a usuario para usar dbms_lock-------
grant execute on sys.dbms_lock to CHILETEL;


--------------------------------------------------------------------------------
disc;

conn CHILETEL/N1234@localhost:1521/xepdb1

---crear tablas e y datos
@mainV2.sql

exit;